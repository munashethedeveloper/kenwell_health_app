import 'package:flutter/material.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../domain/constants/user_roles.dart';

enum UserManagementNavigationTarget { loginScreen }

class UserManagementViewModel extends ChangeNotifier {
  final FirebaseAuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserManagementNavigationTarget? _navigationTarget;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserManagementNavigationTarget? get navigationTarget => _navigationTarget;
  List<String> get availableRoles => UserRoles.values;

  UserManagementViewModel({FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService();

  Future<void> registerUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    // Validate passwords match
    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _navigationTarget = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email.trim(),
        password: password.trim(),
        role: role,
        phoneNumber: phoneNumber.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );

      if (user != null) {
        _successMessage = 'Registration successful! Please log in.';
        _navigationTarget = UserManagementNavigationTarget.loginScreen;
      } else {
        _errorMessage = 'Registration failed. Email may already exist.';
      }
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      debugPrint('Registration error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNavigationTarget() {
    _navigationTarget = null;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
