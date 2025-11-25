import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/auth/widgets/login_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../view_models/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _roleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authViewModel = context.read<AuthViewModel>();
      final user = await authViewModel.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _roleController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
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
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KenwellAppBar(
        title: 'Register',
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
                    title: "Register Account",
                    subtitle:
                        "Complete your details or continue with social media",
                  ),
                  KenwellFormCard(
                    title: 'Personal Information',
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        KenwellTextField(
                          label: "First Name",
                          controller: _firstNameController,
                          inputFormatters: AppTextInputFormatters.lettersOnly(
                            allowHyphen: true,
                          ),
                          padding: EdgeInsets.zero,
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Enter First Name"
                              : null,
                        ),
                        const SizedBox(height: 24),
                        KenwellTextField(
                          label: "Last Name",
                          controller: _lastNameController,
                          inputFormatters: AppTextInputFormatters.lettersOnly(
                            allowHyphen: true,
                          ),
                          padding: EdgeInsets.zero,
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Enter Last Name"
                              : null,
                        ),
                        const SizedBox(height: 24),
                        KenwellTextField(
                          label: "Username",
                          controller: _usernameController,
                          padding: EdgeInsets.zero,
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Enter Username"
                              : null,
                        ),
                        const SizedBox(height: 24),
                        KenwellTextField(
                          label: "Role",
                          controller: _roleController,
                          padding: EdgeInsets.zero,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "Enter Role" : null,
                        ),
                        const SizedBox(height: 24),
                        KenwellTextField(
                          label: "Phone Number",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: AppTextInputFormatters.numbersOnly(),
                          padding: EdgeInsets.zero,
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Enter Phone Number"
                              : null,
                        ),
                      ],
                    ),
                  ),
                  KenwellFormCard(
                    title: 'Account Credentials',
                    margin: const EdgeInsets.only(bottom: 24),
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
                        const SizedBox(height: 24),
                        KenwellTextField(
                          label: "Confirm Password",
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          padding: EdgeInsets.zero,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Enter Confirm Password"
                              : null,
                        ),
                      ],
                    ),
                  ),
                  CustomPrimaryButton(
                    label: "Register",
                    onPressed: _register,
                    isBusy: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Click here to Log In",
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
