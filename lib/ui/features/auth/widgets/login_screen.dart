import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../../../routing/route_names.dart';
import '../../../../domain/models/user_model.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/navigation/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final UserModel? user = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "Enter Email" : null,
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
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Enter Password"
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.forgotPassword);
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
                    onPressed: _login,
                    isBusy: _isLoading,
                    backgroundColor: KenwellColors.primaryGreen,
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
  }
}
