import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/data/services/firebase_auth_service.dart';

// ViewModel for Authentication
class AuthViewModel extends ChangeNotifier {
  // Constructor with optional dependency injection
  AuthViewModel({FirebaseAuthService? authService})
      // Initializes the AuthViewModel with an optional FirebaseAuthService.
      : _authService = authService ?? FirebaseAuthService() {
    // Initial check for login status
    _checkLoginStatus();
  }

  // Firebase Authentication Service
  final FirebaseAuthService _authService;

  // Internal state variables
  bool _isLoggedIn = false;
  bool _isLoading = true;

  // Public getters for state variables
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // Private method to check login status
  Future<void> _checkLoginStatus() async {
    // Check if the user is currently logged in
    _setLoading(true);
    // Set loading state to true before checking login status
    try {
      // Update login status based on AuthService
      _isLoggedIn = _authService.isLoggedIn();
    } finally {
      // Set loading state to false after checking login status
      _setLoading(false);
    }
  }

  // Public method to check login status
  Future<void> checkLoginStatus() => _checkLoginStatus();

  // Public method to log in a user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    // Set loading state to true before attempting login
    try {
      final user = await _authService.login(email, password);
      _isLoggedIn = user != null;
      return _isLoggedIn;
    } finally {
      // Set loading state to false after login attempt
      _setLoading(false);
    }
  }

  // Public method to log out the current user
  Future<void> logout() async {
    _setLoading(true);
    try {
      // Log out the user using AuthService
      await _authService.logout();
      _isLoggedIn = false;
    } finally {
      // Set loading state to false after logout
      _setLoading(false);
    }
  }

  // Private method to update loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
