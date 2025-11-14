import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/auth/widgets/login_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/logo/app_logo.dart';

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
      final user = await AuthService().register(
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
      appBar: const KenwellAppBar(
          title: 'Register', automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const AppLogo(size: 200),
                const SizedBox(height: 30),

                // ===== User Info Fields =====
                _buildTextField(_firstNameController, 'First Name',
                    validator: (val) =>
                        val!.isEmpty ? 'Enter first name' : null),
                const SizedBox(height: 12),
                _buildTextField(_lastNameController, 'Last Name',
                    validator: (val) =>
                        val!.isEmpty ? 'Enter last name' : null),
                const SizedBox(height: 12),
                _buildTextField(_usernameController, 'Username',
                    validator: (val) => val!.isEmpty ? 'Enter username' : null),
                const SizedBox(height: 12),
                _buildTextField(_roleController, 'Role',
                    validator: (val) => val!.isEmpty ? 'Enter role' : null),
                const SizedBox(height: 12),
                _buildTextField(_phoneController, 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (val) =>
                        val!.isEmpty ? 'Enter phone number' : null),
                const SizedBox(height: 12),
                _buildTextField(_emailController, 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Enter email' : null),
                const SizedBox(height: 12),

                // ===== Password Fields =====
                _buildPasswordField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    toggleObscure: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    validator: (val) => val!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null),
                const SizedBox(height: 12),
                _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    toggleObscure: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (val) =>
                        val!.isEmpty ? 'Confirm your password' : null),
                const SizedBox(height: 20),

                // Register Button
                CustomPrimaryButton(
                  label: 'Register',
                  onPressed: _register,
                  isBusy: _isLoading,
                ),
                const SizedBox(height: 10),

                // Navigate to Login
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helper Widgets =====
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggleObscure,
        ),
      ),
      validator: validator,
    );
  }
}
