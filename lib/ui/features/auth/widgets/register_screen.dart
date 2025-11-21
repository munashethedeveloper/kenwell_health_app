import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/form_input_borders.dart';
import 'package:kenwell_health_app/ui/features/auth/widgets/login_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../../data/services/auth_service.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';

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
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Register Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Complete your details or continue with social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    _firstNameController,
                    "First Name",
                    inputFormatters:
                        AppTextInputFormatters.lettersOnly(allowHyphen: true),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _lastNameController,
                    "Last Name",
                    inputFormatters:
                        AppTextInputFormatters.lettersOnly(allowHyphen: true),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_usernameController, "Username"),
                  const SizedBox(height: 16),
                  _buildTextField(_roleController, "Role"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _phoneController,
                    "Phone Number",
                    keyboardType: TextInputType.phone,
                    inputFormatters: AppTextInputFormatters.numbersOnly(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, "Email",
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                      _passwordController, "Password", _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  const SizedBox(height: 16),
                  _buildPasswordField(_confirmPasswordController,
                      "Confirm Password", _obscureConfirmPassword, () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  }),
                  const SizedBox(height: 24),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (v) => (v == null || v.isEmpty) ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: "Enter $label",
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
            borderSide: const BorderSide(color: Color(0xFFFF7643))),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggleObscure) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (v) => (v == null || v.isEmpty) ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: "Enter $label",
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
            borderSide: const BorderSide(color: Color(0xFFFF7643))),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleObscure,
        ),
      ),
    );
  }
}
