import 'package:flutter/foundation.dart';
import "../../../../data/repositories_dcl/auth_repository_dcl.dart";
import '../../../../domain/models/user_model.dart';

enum LoginNavigationTarget { mainNavigation }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  LoginNavigationTarget? _navigationTarget;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginNavigationTarget? get navigationTarget => _navigationTarget;

  LoginViewModel(this._repository);

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _navigationTarget = null;
    notifyListeners();

    try {
      final user = await _repository.login(email, password);

      if (user != null) {
        _navigationTarget = LoginNavigationTarget.mainNavigation;
      } else {
        _errorMessage = 'Invalid email or password';
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      debugPrint('Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNavigationTarget() {
    _navigationTarget = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
