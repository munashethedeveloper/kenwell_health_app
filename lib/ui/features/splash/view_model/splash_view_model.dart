import 'package:flutter/material.dart';
import '../../auth/view_models/auth_view_model.dart';

enum SplashNavigationTarget { authWrapper, mainNavigation }

class SplashViewModel extends ChangeNotifier {
  bool _isInitializing = true;
  SplashNavigationTarget? _navigationTarget;

  bool get isInitializing => _isInitializing;
  SplashNavigationTarget? get navigationTarget => _navigationTarget;

  Future<void> initializeApp(AuthViewModel authViewModel) async {
    _isInitializing = true;
    notifyListeners();

    // Simulate splash delay
    await Future.delayed(const Duration(seconds: 3));

    // Check login status
    await authViewModel.checkLoginStatus();

    // Determine navigation target based on auth status
    _navigationTarget = authViewModel.isLoggedIn
        ? SplashNavigationTarget.mainNavigation
        : SplashNavigationTarget.authWrapper;

    _isInitializing = false;
    notifyListeners();
  }

  void clearNavigationTarget() {
    _navigationTarget = null;
  }
}
