import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../../../core/ui/navigation/main_navigation_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    if (authVM.isLoggedIn) {
      // ✅ After login, show main navigation screen
      return const MainNavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}
