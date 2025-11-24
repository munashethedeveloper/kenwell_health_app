import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService) {
    _checkLoginStatus();
  }

  final AuthService _authService;

  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await _authService.isLoggedIn();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkLoginStatus() => _checkLoginStatus();

  Future<UserModel?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.login(email, password);
    _isLoggedIn = user != null;

    _isLoading = false;
    notifyListeners();
    return user;
  }

  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.register(
      email: email,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );

    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
    return user;
  }

  Future<bool> forgotPassword(String email) async {
    return _authService.forgotPassword(email);
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _isLoggedIn = false;

    _isLoading = false;
    notifyListeners();
  }
}
