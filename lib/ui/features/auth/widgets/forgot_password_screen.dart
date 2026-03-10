import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/form/custom_text_field.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'If an account exists with this email, a password reset link has been sent. '
              'Please check your email and follow the instructions to reset your password.',
            ),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                // Check if context is still valid before using it
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
            ),
          ),
        );

        // Close the screen after success - check mounted again
        if (mounted) {
          context.pop();
        }
      } else {
        // Show error if something went wrong - check mounted first
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to send password reset email. Please try again later.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Show generic error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
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
      backgroundColor: KenwellColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Back button row
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),

            // Hero section — icon + title + subtitle on navy background
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const KenwellSectionLabel(label: 'ACCOUNT'),
                  const SizedBox(height: 10),
                  const Text(
                    'Forgot Password?',
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
                    'Enter your email and we\'ll send\nyou a reset link.',
                    textAlign: TextAlign.center,
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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF201C58),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enter the email associated with your account.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 28),
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
            ),
          ],
        ),
      ),
    );
  }
}
