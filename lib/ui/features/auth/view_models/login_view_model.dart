import 'dart:async';

import 'package:flutter/foundation.dart';
import "../../../../data/repositories_dcl/auth_repository_dcl.dart";
import '../../../../data/services/firebase_auth_service.dart';

/// Possible navigation targets after login
enum LoginNavigationTarget { mainNavigation }

/// ViewModel for handling user login.
///
/// Implements two production-hardening features:
///   1. **Email verification enforcement** – if the Firebase user's email
///      is not yet verified, login is blocked and the caller is informed via
///      [needsEmailVerification] so the UI can offer a re-send link.
///   2. **Client-side brute-force protection** – after
///      [maxFailedAttempts] consecutive failures the VM enters a locked
///      state for [lockoutDuration].  During the lockout period
///      [isLockedOut] is `true` and [lockoutSecondsRemaining] counts down.
class LoginViewModel extends ChangeNotifier {
  // ── Dependencies ────────────────────────────────────────────────────────────

  final AuthRepository _repository;
  final FirebaseAuthService _authService;

  // ── Brute-force protection constants ────────────────────────────────────────

  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(seconds: 30);

  // ── State ────────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _errorMessage;
  LoginNavigationTarget? _navigationTarget;

  int _failedAttempts = 0;
  DateTime? _lockedUntil;
  Timer? _lockoutTimer;
  int _lockoutSecondsRemaining = 0;

  /// Whether the last failed login was due to an unverified email.
  bool _needsEmailVerification = false;

  // ── Getters ──────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginNavigationTarget? get navigationTarget => _navigationTarget;
  bool get needsEmailVerification => _needsEmailVerification;

  /// True when the account is temporarily locked due to too many failures.
  bool get isLockedOut =>
      _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  /// Seconds remaining in the current lockout period (0 when not locked).
  int get lockoutSecondsRemaining => _lockoutSecondsRemaining;

  // ── Constructor ──────────────────────────────────────────────────────────────

  LoginViewModel(this._repository, {FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService();

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Perform login with given email and password.
  ///
  /// Returns immediately (with an error message) if the account is currently
  /// locked out.  Increments the failure counter on every bad credential and
  /// starts the lockout countdown once [maxFailedAttempts] is reached.
  Future<void> login(String email, String password) async {
    // Reject while locked out.
    if (isLockedOut) {
      _errorMessage =
          'Too many failed attempts. Please wait $_lockoutSecondsRemaining seconds.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _navigationTarget = null;
    _needsEmailVerification = false;
    notifyListeners();

    try {
      final user = await _repository.login(email, password);

      if (user != null) {
        // ── Email verification check ───────────────────────────────────────
        if (!user.emailVerified) {
          _needsEmailVerification = true;
          _errorMessage = 'Please verify your email address before signing in. '
              'Check your inbox for a verification link.';
          _recordFailure();
        } else {
          // Successful login — reset the failure counter.
          _failedAttempts = 0;
          _lockedUntil = null;
          _lockoutTimer?.cancel();
          _navigationTarget = LoginNavigationTarget.mainNavigation;
        }
      } else {
        _errorMessage = 'Invalid email or password';
        _recordFailure();
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _recordFailure();
      debugPrint('Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send (or resend) the verification email for the currently signed-in but
  /// unverified Firebase account.
  Future<void> resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      debugPrint('LoginViewModel: resend verification failed – $e');
    }
  }

  /// Clear navigation target after handling.
  void clearNavigationTarget() {
    _navigationTarget = null;
  }

  /// Clear error message.
  void clearError() {
    _errorMessage = null;
    _needsEmailVerification = false;
    notifyListeners();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  void _recordFailure() {
    _failedAttempts++;
    if (_failedAttempts >= maxFailedAttempts) {
      _lockedUntil = DateTime.now().add(lockoutDuration);
      _lockoutSecondsRemaining = lockoutDuration.inSeconds;
      _lockoutTimer?.cancel();
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final remaining = _lockedUntil!.difference(DateTime.now()).inSeconds;
        if (remaining <= 0) {
          _lockoutTimer?.cancel();
          _failedAttempts = 0;
          _lockedUntil = null;
          _lockoutSecondsRemaining = 0;
        } else {
          _lockoutSecondsRemaining = remaining;
        }
        notifyListeners();
      });
    }
  }
}
