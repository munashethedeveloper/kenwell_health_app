import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_modern_section_header.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // Reset password method
  void _resetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    setState(() => _isLoading = true);

    // Call AuthService to send reset email
    try {
      final bool success = await AuthService().forgotPassword(
        _emailController.text.trim(),
      );

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Show success or error message
      if (success) {
        AppSnackbar.showSuccess(
          context,
          'If an account exists with this email, a password reset link has been sent. '
          'Please check your email and follow the instructions to reset your password.',
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        );

        // Close the screen after success - check mounted again
        if (mounted) {
          context.pop();
        }
      } else {
        // Show error if something went wrong - check mounted first
        if (mounted) {
          AppSnackbar.showError(context,
              'Unable to send password reset email. Please try again later.',
              duration: const Duration(seconds: 4));
        }
      }
    } catch (e) {
      // Show generic error message
      if (!mounted) return;
      AppSnackbar.showError(context, 'An error occurred: \${e.toString()}',
          duration: const Duration(seconds: 5));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'KenWell365',
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: KenwellColors.neutralBackground,
      body: Column(
        children: [
          const SizedBox(height: 10),
          const AppLogo(size: 200),
          /*  // ── Gradient section header ───────────────────────────────
          const KenwellGradientHeader(
            label: 'ACCOUNT RECOVERY',
            title: 'Forgot\nPassword?',
            subtitle: 'Enter your email and we\'ll send you a reset link.',
          ), */

          // ── Form section ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*  const Text(
                      'Enter the email associated with your account.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 28), */

                    // Section header
                    const KenwellModernSectionHeader(
                      title: 'Forgot Password',
                      subtitle:
                          'Enter your email and we\'ll send you a reset link.',
                      icon: Icons.lock_reset,
                    ),
                    const SizedBox(height: 40),

                    // Email field
                    KenwellTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      padding: EdgeInsets.zero,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 24),
                    // Reset button
                    CustomPrimaryButton(
                      label: 'Send Reset Link',
                      onPressed: _resetPassword,
                      isBusy: _isLoading,
                      backgroundColor: KenwellColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
