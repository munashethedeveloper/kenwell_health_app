import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _checkLoginStatus();
  }

  // Private method
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    _isLoading = false;
    notifyListeners();
  }

  // PUBLIC method for SplashScreen
  Future<void> checkLoginStatus() async {
    await _checkLoginStatus();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    final storedPassword = prefs.getString('password');

    if (storedEmail == email && storedPassword == password) {
      _isLoggedIn = true;
      await prefs.setBool('isLoggedIn', true);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    _isLoggedIn = false;
    await prefs.setBool('isLoggedIn', false);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isLoggedIn = false;

    _isLoading = false;
    notifyListeners();
  }
}
