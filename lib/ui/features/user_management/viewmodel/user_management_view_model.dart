import 'package:flutter/material.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../domain/constants/user_roles.dart';
import '../../../../domain/models/user_model.dart';

enum UserManagementNavigationTarget { loginScreen }

class UserManagementViewModel extends ChangeNotifier {
  // Email verification helpers
  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    return await _authService.isEmailVerified();
  }

  final FirebaseAuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserManagementNavigationTarget? _navigationTarget;
  List<UserModel> _users = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserManagementNavigationTarget? get navigationTarget => _navigationTarget;
  List<String> get availableRoles => UserRoles.values;
  List<UserModel> get users => _users;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  List<UserModel> get filteredUsers {
    var filtered = _users;

    // Apply role filter
    if (_selectedFilter != 'all') {
      filtered =
          filtered.where((user) => user.role == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        final firstName = user.firstName.toLowerCase();
        final lastName = user.lastName.toLowerCase();
        final email = user.email.toLowerCase();
        return firstName.contains(query) ||
            lastName.contains(query) ||
            email.contains(query);
      }).toList();
    }

    return filtered;
  }

  UserManagementViewModel({FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService();

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
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
  String? validatePasswordMatch(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateRequiredField(String fieldName, String? value) {
    final sanitized = _sanitizeString(value);
    if (sanitized.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Search and filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Load all users
  Future<void> loadUsers() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final fetchedUsers = await _authService.getAllUsers();
      _users = fetchedUsers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load users. Please try again.');
      debugPrint('Load users error: $e');
    }
  }

  // Register user
  Future<bool> registerUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    // Validate passwords match
    final passwordError = validatePasswordMatch(password, confirmPassword);
    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    _setLoading(true);
    _successMessage = null;
    _navigationTarget = null;

    try {
      final user = await _authService.register(
        email: _sanitizeString(email),
        password: _sanitizeString(password),
        role: role,
        phoneNumber: _sanitizeString(phoneNumber),
        firstName: _sanitizeString(firstName),
        lastName: _sanitizeString(lastName),
      );

      if (user != null) {
        _setSuccess('User registered successfully! Verification email sent.');
        // Reload users list to include new user
        await loadUsers();
        return true;
      } else {
        _setError(
          'Registration failed. This email address may already be in use.\n\n'
          'If you recently deleted a user with this email, the Firebase '
          'Authentication account may still exist. Please delete it from:\n'
          'Firebase Console > Authentication > Users'
        );
        return false;
      }
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('email-already-in-use') || 
          errorMessage.contains('already exists')) {
        _setError(
          'This email address is already registered.\n\n'
          'If you recently deleted this user, the Firebase Authentication '
          'account may still exist. To reuse this email:\n'
          '1. Go to Firebase Console > Authentication > Users\n'
          '2. Find and delete the user with this email\n'
          '3. Try registration again'
        );
      } else {
        _setError('Registration failed. Please try again.\n\nError: $e');
      }
      debugPrint('Registration error: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId, String userName) async {
    _setLoading(true);

    try {
      final success = await _authService.deleteUser(userId);

      if (success) {
        _setSuccess(
          'User $userName deleted from database.\n\n'
          'IMPORTANT: The Firebase Authentication account still exists. '
          'To allow re-registration with this email, you must also delete '
          'the user from Firebase Console:\n'
          '1. Go to Firebase Console > Authentication > Users\n'
          '2. Find the user by email and delete manually\n\n'
          'Otherwise, the email address cannot be reused for new registrations.'
        );
        // Reload users list
        await loadUsers();
        return true;
      } else {
        _setError('Failed to delete user');
        return false;
      }
    } catch (e) {
      _setError('Error deleting user. Please try again.');
      debugPrint('Delete user error: $e');
      return false;
    }
  }

  // Reset user password
  Future<bool> resetUserPassword(String email, String userName) async {
    _setLoading(true);

    try {
      final success = await _authService.resetUserPassword(email);

      if (success) {
        _setSuccess('Password reset email sent to $email');
        return true;
      } else {
        _setError('Failed to send password reset email');
        return false;
      }
    } catch (e) {
      _setError('Error sending reset email. Please try again.');
      debugPrint('Reset password error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNavigationTarget() {
    _navigationTarget = null;
    notifyListeners();
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
