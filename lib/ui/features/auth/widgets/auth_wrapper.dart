import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../../../shared/ui/navigation/main_navigation_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    //Check if the user is logged in
    if (authVM.isLoggedIn) {
      // ✅ After login, show main navigation screen
      return const MainNavigationScreen();
    } else {
      //Else show login screen again if user is not logged in
      return const LoginScreen();
    }
  }
}
