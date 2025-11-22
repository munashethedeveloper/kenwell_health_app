import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';

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

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bool success = await AuthService().forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset link sent! Please check your email.',
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found with this email.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Forgot Password',
        automaticallyImplyLeading: true,
      ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const AppLogo(size: 250),
                const SizedBox(height: 24),
                const KenwellSectionHeader(
                  title: 'Reset Password',
                  subtitle:
                      'Enter the email associated with your account and we will send a reset link.',
                ),
                KenwellFormCard(
                  child: KenwellTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: KenwellFormStyles.decoration(
                      label: 'Email',
                      hint: 'Enter your email',
                    ),
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Please enter your email' : null,
                  ),
                ),
                const SizedBox(height: 20),
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
