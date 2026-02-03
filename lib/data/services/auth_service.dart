import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_auth_service.dart';

class AuthService {
  AuthService({
    AppDatabase? database,
    Future<SharedPreferences>? preferences,
  })  : _database = database ?? AppDatabase.instance,
        _prefsFuture = preferences ?? SharedPreferences.getInstance();

  static const _currentUserPrefsKey = 'current_user_id';

  final AppDatabase _database;
  final Future<SharedPreferences> _prefsFuture;

  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedPassword = password.trim();
    final sanitizedRole = role.trim();
    final sanitizedPhone = phoneNumber.trim();
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();

    // Register with FirebaseAuth
    final firebaseAuthService = FirebaseAuthService();
    final firebaseUser = await firebaseAuthService.register(
      email: sanitizedEmail,
      password: sanitizedPassword,
      role: sanitizedRole,
      firstName: sanitizedFirstName,
      lastName: sanitizedLastName,
      phoneNumber: sanitizedPhone,
    );
    if (firebaseUser == null) return null;

    // Store user in local DB with Firebase UID
    final newUser = await _database.createUser(
      id: firebaseUser.id, // Firebase UID
      email: sanitizedEmail,
      password: sanitizedPassword,
      role: sanitizedRole,
      phoneNumber: sanitizedPhone,
      firstName: sanitizedFirstName,
      lastName: sanitizedLastName,
    );
    return _mapToUserModel(newUser);
  }

  Future<UserModel?> login(String email, String password) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedPassword = password.trim();

    debugPrint('AuthService: Login attempt for email: $sanitizedEmail');

    // Login with FirebaseAuth
    final firebaseAuthService = FirebaseAuthService();
    final firebaseUser =
        await firebaseAuthService.login(sanitizedEmail, sanitizedPassword);
    
    if (firebaseUser == null) {
      debugPrint('AuthService: Firebase login failed, returning null');
      return null;
    }

    debugPrint('AuthService: Firebase login successful, UID: ${firebaseUser.id}');

    // Fetch user from local DB by Firebase UID, or create if not found
    var user = await _database.getUserById(firebaseUser.id);
    
    if (user == null) {
      debugPrint('AuthService: User not found in local DB, creating new entry');
      user = await _database.createUser(
        id: firebaseUser.id,
        email: firebaseUser.email,
        password: sanitizedPassword,
        role: firebaseUser.role,
        phoneNumber: firebaseUser.phoneNumber,
        firstName: firebaseUser.firstName,
        lastName: firebaseUser.lastName,
      );
      debugPrint('AuthService: User created in local DB');
    } else {
      debugPrint('AuthService: User found in local DB');
    }

    final prefs = await _prefsFuture;
    await prefs.setString(_currentUserPrefsKey, user.id);
    debugPrint('AuthService: User ID saved to SharedPreferences');

    return _mapToUserModel(user);
  }

  Future<UserModel?> getCurrentUser() async {
    // Always get the current FirebaseAuth user
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    // Try to fetch user data from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (!doc.exists) {
      // If not found, return minimal user info with UID
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        role: '',
        phoneNumber: '',
        firstName: '',
        lastName: '',
        emailVerified: firebaseUser.emailVerified,
      );
    }
    final data = doc.data()!;
    // Ensure the id is always the FirebaseAuth UID
    data['id'] = firebaseUser.uid;
    return UserModel.fromMap(data);
  }

  Future<String?> getStoredPassword() async {
    final entity = await _getCurrentUserEntity();
    return entity?.password;
  }

  Future<UserModel> saveUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    //required String username,
    required String firstName,
    required String lastName,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedPassword = password.trim();
    final sanitizedRole = role.trim();
    final sanitizedPhone = phoneNumber.trim();
    // final sanitizedUsername = username.trim();
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();

    final existingWithEmail = await _database.getUserByEmail(sanitizedEmail);
    if (existingWithEmail != null && existingWithEmail.id != id) {
      throw StateError('Email already registered');
    }

    final updated = await _database.updateUser(
      id: id,
      email: sanitizedEmail,
      password: sanitizedPassword,
      role: sanitizedRole,
      phoneNumber: sanitizedPhone,
      // username: sanitizedUsername,
      firstName: sanitizedFirstName,
      lastName: sanitizedLastName,
    );

    final entity = updated ??
        await _database.createUser(
          id: id,
          email: sanitizedEmail,
          password: sanitizedPassword,
          role: sanitizedRole,
          phoneNumber: sanitizedPhone,
          //    username: sanitizedUsername,
          firstName: sanitizedFirstName,
          lastName: sanitizedLastName,
        );

    final prefs = await _prefsFuture;
    await prefs.setString(_currentUserPrefsKey, entity.id);

    return _mapToUserModel(entity);
  }

  Future<void> logout() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_currentUserPrefsKey);
  }

  Future<bool> isLoggedIn() async {
    final entity = await _getCurrentUserEntity();
    return entity != null;
  }

  Future<bool> forgotPassword(String email) async {
    // Use FirebaseAuthService to send password reset email
    // Import if not already: import 'firebase_auth_service.dart';
    final firebaseAuthService = FirebaseAuthService();
    return await firebaseAuthService.sendPasswordResetEmail(email);
  }

  Future<List<UserModel>> getAllUsers() async {
    final entities = await _database.getAllUsers();
    return entities.map(_mapToUserModel).toList();
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final rowsDeleted = await _database.deleteUserById(userId);
      return rowsDeleted > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      final user = await _database.getUserById(userId);
      if (user == null) return false;

      await _database.updateUser(
        id: userId,
        email: user.email,
        password: newPassword,
        role: user.role,
        phoneNumber: user.phoneNumber,
        firstName: user.firstName,
        lastName: user.lastName,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  UserModel _mapToUserModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      role: entity.role,
      phoneNumber: entity.phoneNumber,
      firstName: entity.firstName,
      lastName: entity.lastName,
      emailVerified: false,
    );
  }

  Future<UserEntity?> _getCurrentUserEntity() async {
    final prefs = await _prefsFuture;
    final userId = prefs.getString(_currentUserPrefsKey);
    if (userId == null) {
      return null;
    }

    final user = await _database.getUserById(userId);
    if (user == null) {
      await prefs.remove(_currentUserPrefsKey);
    }

    return user;
  }
}
