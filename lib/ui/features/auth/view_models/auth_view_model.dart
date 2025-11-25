import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _checkLoginStatus();
  }

  final AuthService _authService;

  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  Future<void> _checkLoginStatus() async {
    _setLoading(true);
    try {
      _isLoggedIn = await _authService.isLoggedIn();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkLoginStatus() => _checkLoginStatus();

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.login(email, password);
      _isLoggedIn = user != null;
      return _isLoggedIn;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
