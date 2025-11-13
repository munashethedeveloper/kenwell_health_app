import 'package:flutter/material.dart';
import '../../../../data/services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Returns true if reset link was sent successfully
  Future<bool> sendResetLink() async {
    setLoading(true);
    try {
      final success =
          await AuthService().forgotPassword(emailController.text.trim());
      return success;
    } catch (_) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
