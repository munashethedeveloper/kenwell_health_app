import 'package:flutter/material.dart';
import '../../../../data/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final roleController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Set loading state ---
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Form validation ---
  bool validatePasswords() {
    return passwordController.text == confirmPasswordController.text;
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  // --- Register method ---
  Future<bool> register() async {
    setLoading(true);
    try {
      final user = await AuthService().register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: roleController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        username: usernameController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );
      return user != null;
    } catch (_) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    roleController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
