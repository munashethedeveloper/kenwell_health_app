class Validators {
  Validators._();

  // Regex patterns
  static final RegExp _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  static final RegExp _strongPasswordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');

  // Check if valid email
  static bool isValidEmail(String email) =>
      _emailRegex.hasMatch(email.trim().toLowerCase());

  // Check if password is strong
  static bool isStrongPassword(String password) =>
      _strongPasswordRegex.hasMatch(password);

  // Validators for forms
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!isValidEmail(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePasswordPresence(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!isStrongPassword(value)) {
      return 'Password must be 8+ chars and include upper, lower, number, and special character';
    }
    return null;
  }

  // ------------------ SA Phone validation ------------------
  static String? validateSouthAfricanPhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter phone number';

    final cleaned = value.replaceAll(RegExp(r'\D'), '');

    if (!(cleaned.length == 10 ||
        (cleaned.length == 11 && cleaned.startsWith('27')))) {
      return 'Invalid South African phone number';
    }

    final prefix = cleaned.length == 11
        ? cleaned.substring(2, 3)
        : cleaned.substring(1, 2);
    if (!['6', '7', '8', '1', '2'].contains(prefix)) {
      return 'Invalid South African phone number';
    }

    return null;
  }

  // ------------------ International Phone validation ------------------
  static String? validateInternationalPhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter phone number';

    // Remove all non-digit characters except +
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if the number starts with + (international format)
    if (!cleaned.startsWith('+')) {
      return 'Phone number must include country code (e.g., +27)';
    }

    // Remove the + for digit counting
    final digitsOnly = cleaned.substring(1);

    // International phone numbers typically range from 7 to 15 digits (E.164 standard)
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'Phone number must be between 7 and 15 digits';
    }

    return null;
  }

  // ------------------ SA ID validation ------------------
  static String? validateSouthAfricanId(String? id) {
    if (id == null || id.isEmpty) return 'Please enter ID Number';
    if (id.length != 13) return 'SA ID must be 13 digits';
    if (!RegExp(r'^[0-9]{13}$').hasMatch(id)) {
      return 'SA ID must contain only digits';
    }

    try {
      getDateOfBirthFromId(id); // Throws if invalid DOB
    } catch (_) {
      return 'Invalid date of birth in ID';
    }

    if (!_isValidCheckDigit(id)) return 'Invalid South African ID Number';

    return null;
  }

  // ------------------ Extract DOB from ID ------------------
  static DateTime getDateOfBirthFromId(String id) {
    final yy = int.parse(id.substring(0, 2));
    final mm = int.parse(id.substring(2, 4));
    final dd = int.parse(id.substring(4, 6));

    final currentYear = DateTime.now().year % 100;
    final century = (yy <= currentYear ? 2000 : 1900);
    final fullYear = century + yy;

    final birthDate = DateTime(fullYear, mm, dd);

    if (birthDate.year != fullYear ||
        birthDate.month != mm ||
        birthDate.day != dd) {
      throw Exception('Invalid DOB in ID');
    }

    return birthDate;
  }

  // ------------------ Extract gender from ID ------------------
  static String getGenderFromId(String id) {
    final genderDigits = int.parse(id.substring(6, 10));
    return genderDigits >= 5000 ? 'Male' : 'Female';
  }

  // ------------------ Internal check digit ------------------
  static bool _isValidCheckDigit(String id) {
    int sum = 0;
    for (int i = 0; i < 12; i += 2) {
      sum += int.parse(id[i]);
    }

    String evenConcat = '';
    for (int i = 1; i < 12; i += 2) {
      evenConcat += id[i];
    }
    int evenNumber = int.parse(evenConcat) * 2;
    int evenSum =
        evenNumber.toString().split('').map(int.parse).fold(0, (a, b) => a + b);
    sum += evenSum;

    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(id[12]);
  }

  // ------------------ Generic required field validators ------------------
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateRequiredWithMessage(
      String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  // ------------------ Password match validator ------------------
  static String? validatePasswordMatch(String? value, String? passwordToMatch) {
    final message = validatePasswordPresence(value);
    if (message != null) return message;
    if (value != passwordToMatch) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ------------------ Name validators ------------------
  static String? validateName(String? value, [String fieldName = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $fieldName';
    }
    return null;
  }

  static String? validateFirstName(String? value) =>
      validateName(value, 'First Name');

  static String? validateLastName(String? value) =>
      validateName(value, 'Last Name');
}
