import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories_dcl/auth_repository_dcl.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../../../routing/route_names.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/navigation/main_navigation_screen.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(AuthRepository()),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatefulWidget {
  const _LoginScreenBody();

  @override
  State<_LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<_LoginScreenBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<LoginViewModel>();
    viewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(builder: (context, viewModel, _) {
      // Handle navigation
      if (viewModel.navigationTarget != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          viewModel.clearNavigationTarget();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        });
      }

      // Show error message
      if (viewModel.errorMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.errorMessage!)),
          );
          viewModel.clearError();
        });
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const KenwellAppBar(
          title: 'Login',
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const AppLogo(size: 200),
                    const SizedBox(height: 24),
                    const KenwellSectionHeader(
                      title: 'Welcome Back',
                      subtitle: 'Log in to access your wellness planner',
                    ),
                    KenwellFormCard(
                      title: 'Account Details',
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          KenwellTextField(
                            label: "Email",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            padding: EdgeInsets.zero,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 24),
                          KenwellTextField(
                            label: "Password",
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            padding: EdgeInsets.zero,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            validator: Validators.validatePasswordPresence,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, RouteNames.forgotPassword);
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                              color: Color(0xFF201C58)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomPrimaryButton(
                      label: "Login",
                      onPressed: _handleLogin,
                      isBusy: viewModel.isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, RouteNames.register);
                      },
                      child: const Text(
                        "Don’t have an account yet? Click here to Register",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                            color: Color(0xFF201C58)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
