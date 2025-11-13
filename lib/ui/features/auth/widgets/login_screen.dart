import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../../routing/route_names.dart';
import '../../../shared/ui/navigation/main_navigation_screen.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatelessWidget {
  const _LoginScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final formKey = GlobalKey<FormState>();

    Future<void> _onLogin() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final user = await vm.login();
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const KenwellMainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Login',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const KenwellAppLogo(size: 250),
              const SizedBox(height: 30),
              // Email
              KenwellTextField(
                label: 'Email',
                controller: vm.emailController,
              ),
              // Password
              KenwellTextField(
                label: 'Password',
                controller: vm.passwordController,
                obscureText: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.forgotPassword);
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomPrimaryButton(
                label: 'Login',
                onPressed: _onLogin,
                isBusy: vm.isLoading,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteNames.register);
                },
                child: const Text(
                  'Don’t have an account? Register',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ]
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: w,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
