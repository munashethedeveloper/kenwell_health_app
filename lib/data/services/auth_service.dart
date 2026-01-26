import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  AuthService({
    AppDatabase? database,
    Future<SharedPreferences>? preferences,
  })  : _database = database ?? AppDatabase.instance,
        _prefsFuture = preferences ?? SharedPreferences.getInstance();

  static const _currentUserPrefsKey = 'current_user_id';
  static const _uuid = Uuid();

  final AppDatabase _database;
  final Future<SharedPreferences> _prefsFuture;

  Future<UserModel?> register({
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
    //final sanitizedUsername = username.trim();
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();

    final existingUser = await _database.getUserByEmail(sanitizedEmail);
    if (existingUser != null) {
      return null;
    }

    final newUser = await _database.createUser(
      id: _uuid.v4(),
      email: sanitizedEmail,
      password: sanitizedPassword,
      role: sanitizedRole,
      phoneNumber: sanitizedPhone,
      //username: sanitizedUsername,
      firstName: sanitizedFirstName,
      lastName: sanitizedLastName,
    );

    return _mapToUserModel(newUser);
  }

  Future<UserModel?> login(String email, String password) async {
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedPassword = password.trim();

    final user =
        await _database.getUserByCredentials(sanitizedEmail, sanitizedPassword);
    if (user == null) return null;

    final prefs = await _prefsFuture;
    await prefs.setString(_currentUserPrefsKey, user.id);

    return _mapToUserModel(user);
  }

  Future<UserModel?> getCurrentUser() async {
    final entity = await _getCurrentUserEntity();
    return entity != null ? _mapToUserModel(entity) : null;
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
    final sanitizedEmail = email.trim().toLowerCase();
    final user = await _database.getUserByEmail(sanitizedEmail);
    return user != null;
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
      // username: entity.username,
      firstName: entity.firstName,
      lastName: entity.lastName,
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
