import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/logo/app_logo.dart';

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

      // Hide loading indicator
      if (!mounted) return;

      // Show success or error message
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset link sent! Please check your email.',
            ),
          ),
        );

        // Close the screen after success
        context.pop();
      } else {
        // Show error if email not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found with this email.'),
          ),
        );
      }
      // Hide loading indicator
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
      //App bar
      appBar: const KenwellAppBar(
        title: 'Forgot Password',
        automaticallyImplyLeading: true,
      ),
      // Body with form
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Form fields and buttons
            children: [
              const SizedBox(height: 40),
              //Custom app logo
              const AppLogo(size: 250),
              const SizedBox(height: 24),
              // Section header
              const KenwellSectionHeader(
                title: 'Reset Password',
                subtitle:
                    'Enter the email associated with your account and we will send a reset link.',
              ),
              // Email field
              KenwellFormCard(
                child: KenwellTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Email',
                    hint: 'Enter your email',
                  ),
                  validator: Validators.validateEmail,
                ),
              ),
              const SizedBox(height: 20),
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
    );
  }
}
