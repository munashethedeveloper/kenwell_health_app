bool isValidEmail(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 8;
}

class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  static final RegExp _strongPasswordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');

  static bool isValidEmail(String email) =>
      _emailRegex.hasMatch(email.trim().toLowerCase());

  static bool isStrongPassword(String password) =>
      _strongPasswordRegex.hasMatch(password);

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePasswordPresence(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isStrongPassword(value)) {
      return 'Password must be 8+ chars and include upper, lower, number, and special character';
    }
    return null;
  }
}
