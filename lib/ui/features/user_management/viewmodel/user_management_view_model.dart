import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../data/services/firebase_auth_exceptions.dart';
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
  StreamSubscription<List<UserModel>>? _usersStreamSubscription;
  Timer? _verificationSyncTimer;
  bool _isSyncingVerification = false; // Flag to prevent concurrent syncs

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

  // Verification statistics
  int get verifiedUsersCount => _users.where((u) => u.emailVerified).length;
  int get unverifiedUsersCount => _users.where((u) => !u.emailVerified).length;

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
      : _authService = authService ?? FirebaseAuthService() {
    // Start listening to user updates immediately
    _startListeningToUsers();
    // Start periodic verification sync for current user
    _startPeriodicVerificationSync();
  }

  @override
  void dispose() {
    _usersStreamSubscription?.cancel();
    _verificationSyncTimer?.cancel();
    super.dispose();
  }

  /// Start listening to real-time user updates from Firestore
  void _startListeningToUsers() {
    _setLoading(true);
    _usersStreamSubscription = _authService.getAllUsersStream().listen(
      (users) {
        _users = users;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load users. Please try again.');
        _isLoading = false; // Ensure loading state is reset on error
        notifyListeners();
        debugPrint('Users stream error: $error');
      },
    );
  }

  /// Start periodic sync of current user's email verification status
  /// This ensures that when a user verifies their email, it's reflected in the UI
  void _startPeriodicVerificationSync() {
    // Check every 30 seconds
    _verificationSyncTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        // Atomically check and set flag to prevent race condition
        if (_isSyncingVerification) {
          debugPrint(
              'UserManagementViewModel: Skipping sync - already in progress');
          return;
        }

        // Set flag before async operation
        _isSyncingVerification = true;

        try {
          // Use the wrapper method for consistency
          await _authService.syncCurrentUserEmailVerification();
          debugPrint(
              'UserManagementViewModel: Synced current user verification status');
        } catch (e) {
          debugPrint('UserManagementViewModel: Error syncing verification: $e');
        } finally {
          // Always reset flag in finally block
          _isSyncingVerification = false;
        }
      },
    );
  }

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

  // Load all users - performs a one-time fetch
  // This is kept for manual refresh functionality
  // The stream subscription (_startListeningToUsers) provides continuous updates
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

  /// Sync email verification status for the current logged-in user
  /// This triggers Firebase Auth to check if the user has verified their email
  Future<void> syncCurrentUserVerificationStatus() async {
    // Check if sync is already in progress to prevent race conditions
    if (_isSyncingVerification) {
      debugPrint(
          'UserManagementViewModel: Skipping manual sync - already in progress');
      return;
    }

    // Set flag before async operation
    _isSyncingVerification = true;

    try {
      await _authService.syncCurrentUserEmailVerification();
      _setSuccess('Your verification status has been synced');
    } catch (e) {
      _setError('Failed to sync verification status');
      debugPrint('Sync verification error: $e');
    } finally {
      // Always reset flag in finally block
      _isSyncingVerification = false;
    }
  }

  // Register user
  /// Registers a new user account with the provided details.
  /// 
  /// Returns:
  /// - `true` if both user creation AND password reset email succeed
  /// - `false` if the process doesn't complete successfully (see behavior below)
  /// 
  /// Behavior when failures occur:
  /// - If user creation fails: Returns false, user list NOT reloaded (user doesn't exist)
  /// - If user creation succeeds but password reset email fails: 
  ///   Returns false (incomplete success), user list IS reloaded (user exists)
  /// 
  /// Note: Even when returning false, check the error message to understand 
  /// what failed and what action is needed.
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
        _setSuccess(
            'User registered successfully! Password reset email sent to ${user.email}. User can set their own password using the link in the email.');
        // Reload users list to include new user
        await loadUsers();
        return true;
      } else {
        _setError('Registration failed. Email may already exist.');
        return false;
      }
    } on PasswordResetEmailFailedException catch (e) {
      // User was created successfully but password reset email failed
      _setError(e.message);
      // Reload users list to include new user even though password reset failed
      await loadUsers();
      return false; // Return false because password reset email failed (user exists but requires manual password reset)
    } catch (e) {
      _setError('Registration failed. Please try again.');
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
        _setSuccess('User $userName deleted successfully');
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

  // Reset user password by sending them a password reset email
  Future<bool> resetUserPassword(String email, String userName) async {
    _setLoading(true);

    try {
      final success = await _authService.resetUserPassword(email);

      if (success) {
        _setSuccess('Password reset email sent to $userName ($email). '
            'The user will receive an email with a link to set a new password. '
            'After setting their new password, they can login immediately with it.');
        return true;
      } else {
        _setError(
            'Failed to send password reset email. User may not exist with this email address.');
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
