import 'package:flutter/foundation.dart';
import "../../../../data/repositories_dcl/auth_repository_dcl.dart";

/// Possible navigation targets after login
enum LoginNavigationTarget { mainNavigation }

/// ViewModel for handling user login
class LoginViewModel extends ChangeNotifier {
  // Repository for authentication operations
  final AuthRepository _repository;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  LoginNavigationTarget? _navigationTarget;

  // Getters for state variables
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginNavigationTarget? get navigationTarget => _navigationTarget;

  // Constructor
  LoginViewModel(this._repository);

  /// Perform login with given email and password
  Future<void> login(String email, String password) async {
    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    _navigationTarget = null;
    // Notify listeners about state changes
    notifyListeners();

    try {
      // Attempt to login via repository
      final user = await _repository.login(email, password);

      // On successful login, set navigation target
      if (user != null) {
        _navigationTarget = LoginNavigationTarget.mainNavigation;
      } else {
        // On failure, set error message
        _errorMessage = 'Invalid email or password';
      }
      // Handle exceptions during login
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      debugPrint('Login error: $e');
    } finally {
      // Reset loading state
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear navigation target after handling
  void clearNavigationTarget() {
    _navigationTarget = null;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
