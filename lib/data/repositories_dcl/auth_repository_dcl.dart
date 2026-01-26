import '../services/firebase_auth_service.dart';
import '../services/auth_service.dart';
import '../../domain/models/user_model.dart';
import '../../utils/logger.dart';

class AuthRepository {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final AuthService _localAuthService = AuthService();

  /// Login user - tries Firebase first, falls back to local database
  Future<UserModel?> login(String email, String password) async {
    // Try Firebase first
    try {
      final firebaseUser = await _firebaseAuthService.login(email, password);
      if (firebaseUser != null) {
        return firebaseUser;
      }
    } catch (e) {
      AppLogger.error('Firebase login failed', e);
    }

    // Fallback to local database
    try {
      final localUser = await _localAuthService.login(email, password);
      return localUser;
    } catch (e) {
      AppLogger.error('Local login failed', e);
      return null;
    }
  }

  /// Register user with all required fields
  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    //required String username,
    required String firstName,
    required String lastName,
  }) {
    return _firebaseAuthService.register(
      email: email,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
      // username: username,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Logout user
  Future<void> logout() async {
    await _firebaseAuthService.logout();
    await _localAuthService.logout();
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    // Try Firebase first
    try {
      final firebaseUser = await _firebaseAuthService.currentUser();
      if (firebaseUser != null) {
        return firebaseUser;
      }
    } catch (e) {
      AppLogger.error('Firebase getCurrentUser failed', e);
    }

    // Fallback to local
    return await _localAuthService.getCurrentUser();
  }

  /// Update user profile
  Future<UserModel?> updateUser({
    required String userId,
    required String email,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    return _firebaseAuthService.updateUserProfile(
      id: userId,
      email: email,
      role: currentUser.role,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
