import '../services/firebase_auth_service.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();

  /// Login user
  Future<UserModel?> login(String email, String password) {
    return _authService.login(email, password);
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
    return _authService.register(
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
  Future<void> logout() => _authService.logout();

  /// Get current user
  Future<UserModel?> getCurrentUser() => _authService.currentUser();
}
