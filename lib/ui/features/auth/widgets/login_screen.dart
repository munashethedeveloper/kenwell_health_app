import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories_dcl/auth_repository_dcl.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/login_view_model.dart';

// Login Screen Widget
class LoginScreen extends StatelessWidget {
  // Constructor
  const LoginScreen({super.key});

  // Build method
  @override
  Widget build(BuildContext context) {
    // Provide the LoginViewModel to the widget tree
    return ChangeNotifierProvider(
      // Initialize LoginViewModel with AuthRepository
      create: (_) => LoginViewModel(AuthRepository()),
      // Body of the login screen
      child: const _LoginScreenBody(),
    );
  }
}

// Private StatefulWidget for the login screen body
class _LoginScreenBody extends StatefulWidget {
  // Constructor
  const _LoginScreenBody();

  // Create state
  @override
  State<_LoginScreenBody> createState() => _LoginScreenBodyState();
}

// State class for the login screen body
class _LoginScreenBodyState extends State<_LoginScreenBody> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Handle login action
  void _handleLogin() {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Call login on the view model
    final viewModel = context.read<LoginViewModel>();
    // Trigger login with email and password
    viewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  // Dispose controllers
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    // Consume the LoginViewModel
    return Consumer<LoginViewModel>(builder: (context, viewModel, _) {
      // Handle navigation
      if (viewModel.navigationTarget != null) {
        // Navigate to main screen on successful login
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          // Load user profile data before navigation
          final profileVM = context.read<ProfileViewModel>();
          await profileVM.loadProfile();

          // Update AuthViewModel login status
          final authVM = context.read<AuthViewModel>();
          await authVM.checkLoginStatus();

          // Clear navigation target to prevent repeated navigation
          viewModel.clearNavigationTarget();

          // Navigate to main navigation screen
          if (mounted) {
            context.go('/');
          }
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

      // Build the login screen UI
      return Scaffold(
        backgroundColor: KenwellColors.primaryGreen,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  children: [
                    // Circular logo container
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/app_logo.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const KenwellSectionLabel(label: 'WELCOME'),
                    const SizedBox(height: 10),
                    const Text(
                      'KenWell365',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Supporting wellbeing, 365 days a year.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Form section — white panel with rounded top corners
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF201C58),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sign in to your account',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Email field
                          KenwellTextField(
                            label: "Email",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            padding: EdgeInsets.zero,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 20),
                          // Password field
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
                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.pushNamed('forgotPassword');
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                  color: Color(0xFF201C58),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Login button
                          CustomPrimaryButton(
                            label: "Login",
                            labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: _handleLogin,
                            isBusy: viewModel.isLoading,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
