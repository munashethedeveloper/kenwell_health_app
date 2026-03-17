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

    // Store user in local DB with Firebase UID.
    // NOTE: We deliberately do NOT store the plain-text password locally.
    // Firebase Auth is the sole source of truth for authentication.  The local
    // Drift DB is used only as an offline profile cache (role, name, etc.).
    // Storing a non-empty placeholder prevents schema constraint failures while
    // ensuring the raw password never resides in the on-device SQLite file.
    final newUser = await _database.createUser(
      id: firebaseUser.id, // Firebase UID
      email: sanitizedEmail,
      password: '***', // placeholder — never used for auth
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

    // Login with FirebaseAuth (this is the source of truth for authentication)
    final firebaseAuthService = FirebaseAuthService();
    final firebaseUser =
        await firebaseAuthService.login(sanitizedEmail, sanitizedPassword);
    if (firebaseUser == null) return null;

    // Fetch user from local DB by Firebase UID, or create if not found
    var user = await _database.getUserById(firebaseUser.id);

    if (user == null) {
      // User doesn't exist in local DB, create them.
      // Do NOT store the plain-text password; Firebase Auth is the source of
      // truth.  A placeholder is stored to satisfy the NOT-NULL schema
      // constraint on the password column.
      user = await _database.createUser(
        id: firebaseUser.id,
        email: firebaseUser.email,
        password: '***', // placeholder — never used for auth
        role: firebaseUser.role,
        phoneNumber: firebaseUser.phoneNumber,
        firstName: firebaseUser.firstName,
        lastName: firebaseUser.lastName,
      );
    } else {
      // User already exists locally — keep their profile data up to date but
      // never update the password field from the incoming plaintext value.
      await _database.updateUser(
        id: user.id,
        email: user.email,
        password: user.password, // keep existing placeholder unchanged
        role: user.role,
        phoneNumber: user.phoneNumber,
        firstName: user.firstName,
        lastName: user.lastName,
      );
    }

    final prefs = await _prefsFuture;
    await prefs.setString(_currentUserPrefsKey, user.id);

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
    // Never store the incoming plain-text password locally; keep any
    // existing placeholder (or write a new one if this is a first save).
    final sanitizedRole = role.trim();
    final sanitizedPhone = phoneNumber.trim();
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();

    final existingWithEmail = await _database.getUserByEmail(sanitizedEmail);
    if (existingWithEmail != null && existingWithEmail.id != id) {
      throw StateError('Email already registered');
    }

    // Preserve the existing password placeholder (if any) so we never
    // overwrite it with a plain-text value.
    final existingUser = await _database.getUserById(id);
    final storedPassword = existingUser?.password ?? '***';

    final updated = await _database.updateUser(
      id: id,
      email: sanitizedEmail,
      password: storedPassword,
      role: sanitizedRole,
      phoneNumber: sanitizedPhone,
      firstName: sanitizedFirstName,
      lastName: sanitizedLastName,
    );

    final entity = updated ??
        await _database.createUser(
          id: id,
          email: sanitizedEmail,
          password: storedPassword,
          role: sanitizedRole,
          phoneNumber: sanitizedPhone,
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
    final firebaseAuthService = FirebaseAuthService();
    return await firebaseAuthService.sendPasswordResetEmail(email);
  }

  /// Admin function: Reset user password by sending them a reset email
  /// This does NOT set a specific password, it sends a reset link
  Future<bool> resetUserPassword(String email) async {
    // Use FirebaseAuthService to send password reset email
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

  /// Admin function: Reset user password by sending them a reset email.
  ///
  /// This does NOT set a specific password in the local database.
  /// It delegates entirely to Firebase Auth (password reset email).
  Future<bool> resetPassword(String userId) async {
    // Plain-text passwords are never stored locally.  Delegate to Firebase
    // Auth to handle the actual password change securely.
    try {
      final user = await _database.getUserById(userId);
      if (user == null) return false;
      // Send a password-reset email via Firebase Auth so the user can set
      // their new password securely through the Firebase-hosted flow.
      return await resetUserPassword(user.email);
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
