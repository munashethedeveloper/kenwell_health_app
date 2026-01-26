import 'package:flutter/material.dart';
import 'package:kenwell_health_app/data/repositories_dcl/auth_repository_dcl.dart';
import 'package:kenwell_health_app/domain/constants/user_roles.dart';
import '../../../../domain/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel();

  final AuthRepository _authRepository = AuthRepository();

  // Private user fields
  String _email = '';
  String _role = '';
  String _phoneNumber = '';
  String _firstName = '';
  String _lastName = '';
  String _userId = '';

  // State management
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _user;

  // Getters
  String get email => _email;
  String get role => _role;
  String get phoneNumber => _phoneNumber;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get user => _user;
  List<String> get availableRoles => UserRoles.values;

  // Backward compatibility for screen
  bool get isLoadingProfile => _isLoading;
  bool get isSavingProfile => _isLoading;

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  String _sanitizeString(String? value) {
    return value?.trim() ?? '';
  }

  // Validation
  String? validateRequired(String? value, String fieldName) {
    final sanitized = _sanitizeString(value);
    if (sanitized.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final sanitized = _sanitizeString(value);
    if (sanitized.isEmpty) return 'Email is required';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(sanitized)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    final sanitized = _sanitizeString(value);
    if (sanitized.isEmpty) return 'Phone number is required';

    // South African phone number validation
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(sanitized.replaceAll(' ', ''))) {
      return 'Please enter a valid SA phone number';
    }
    return null;
  }

  // Load profile
  Future<void> loadProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _user = await _authRepository.getCurrentUser();

      if (_user != null) {
        _email = _user!.email;
        _role = UserRoles.ifValid(_user!.role) ?? '';
        _phoneNumber = _user!.phoneNumber;
        _firstName = _user!.firstName;
        _lastName = _user!.lastName;
        _userId = _user!.id;
      } else {
        _setError('Failed to load profile. User not found.');
        return;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load profile. Please try again.');
      debugPrint('Load profile error: $e');
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
  }) async {
    // Validate inputs
    final validationErrors = <String>[];

    if (validateRequired(firstName, 'First Name') != null) {
      validationErrors.add('First Name');
    }
    if (validateRequired(lastName, 'Last Name') != null) {
      validationErrors.add('Last Name');
    }
    if (validatePhone(phoneNumber) != null) {
      validationErrors.add('Phone Number');
    }
    if (validateEmail(email) != null) {
      validationErrors.add('Email');
    }

    if (validationErrors.isNotEmpty) {
      _setError('Please fix: ${validationErrors.join(", ")}');
      return false;
    }

    _setLoading(true);

    try {
      if (_user == null || _userId.isEmpty) {
        _setError('User not loaded. Please refresh.');
        return false;
      }

      // Update user data
      await _authRepository.updateUser(
        userId: _userId,
        email: _sanitizeString(email),
        phoneNumber: _sanitizeString(phoneNumber),
        firstName: _sanitizeString(firstName),
        lastName: _sanitizeString(lastName),
      );

      // Update local state
      _email = _sanitizeString(email);
      _phoneNumber = _sanitizeString(phoneNumber);
      _firstName = _sanitizeString(firstName);
      _lastName = _sanitizeString(lastName);

      _setSuccess('Profile updated successfully!');
      return true;
    } catch (e) {
      _setError('Failed to update profile. Please try again.');
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
