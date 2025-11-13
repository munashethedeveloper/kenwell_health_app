import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../view_models/register_view_model.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const _RegisterScreenBody(),
    );
  }
}

class _RegisterScreenBody extends StatelessWidget {
  const _RegisterScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();
    final formKey = GlobalKey<FormState>();

    void _onRegister() async {
      if (!vm.validateForm(formKey)) return;
      if (!vm.validatePasswords()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final success = await vm.register();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please log in.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration failed. Email may already exist.')),
        );
      }
    }

    return Scaffold(
      appBar: const KenwellAppBar(
          title: 'Register', automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const KenwellAppLogo(size: 250),
              const SizedBox(height: 30),
              // ===== Form Fields =====
              KenwellTextField(
                label: 'First Name',
                controller: vm.firstNameController,
              ),
              KenwellTextField(
                label: 'Last Name',
                controller: vm.lastNameController,
              ),
              KenwellTextField(
                label: 'Username',
                controller: vm.usernameController,
              ),
              KenwellTextField(
                label: 'Role',
                controller: vm.roleController,
              ),
              KenwellTextField(
                label: 'Phone Number',
                controller: vm.phoneController,
                keyboardType: TextInputType.phone,
              ),
              KenwellTextField(
                label: 'Email',
                controller: vm.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              KenwellTextField(
                label: 'Password',
                controller: vm.passwordController,
                obscureText: true,
              ),
              KenwellTextField(
                label: 'Confirm Password',
                controller: vm.confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomPrimaryButton(
                label: 'Register',
                onPressed: _onRegister,
                isBusy: vm.isLoading,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Already have an account? Log in',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
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
