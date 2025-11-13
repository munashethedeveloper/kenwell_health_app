import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../view_models/forgot_password_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: const _ForgotPasswordScreenBody(),
    );
  }
}

class _ForgotPasswordScreenBody extends StatelessWidget {
  const _ForgotPasswordScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final formKey = GlobalKey<FormState>();

    Future<void> _sendResetLink() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final success = await vm.sendResetLink();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Please check your email.'),
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
    }

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Forgot Password',
        automaticallyImplyLeading: true,
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
              KenwellTextField(
                label: 'Email',
                controller: vm.emailController,
              ),
              const SizedBox(height: 20),
              CustomPrimaryButton(
                label: 'Send Reset Link',
                onPressed: _sendResetLink,
                isBusy: vm.isLoading,
                backgroundColor: KenwellColors.primaryGreen,
              ),
            ]
                .map((widget) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: widget,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
