import 'package:drift/drift.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';

class AuthService {
  AuthService(this._database);

  final AppDatabase _database;

  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final existing = await _database.getUserByEmail(email);
    if (existing != null) {
      return null;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserModel(
      id: id,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );

    await _database.upsertUser(
      _toCompanion(user, password, isCurrent: false),
    );
    return user;
  }

  Future<UserModel?> login(String email, String password) async {
    final entry = await _database.getUserByEmail(email);
    if (entry == null || entry.password != password) {
      return null;
    }

    await _database.setCurrentUser(entry.id);
    return _mapEntry(entry);
  }

  Future<UserModel?> getCurrentUser() async {
    final entry = await _database.getCurrentUserEntry();
    return entry == null ? null : _mapEntry(entry);
  }

  Future<String?> getStoredPassword() async {
    final entry = await _database.getCurrentUserEntry();
    return entry?.password;
  }

  Future<UserModel> saveUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final user = UserModel(
      id: id,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );

    await _database.upsertUser(
      _toCompanion(user, password, isCurrent: true),
    );
    await _database.setCurrentUser(id);
    return user;
  }

  Future<void> logout() => _database.clearCurrentUser();

  Future<bool> isLoggedIn() async =>
      (await _database.getCurrentUserEntry()) != null;

  Future<bool> forgotPassword(String email) async =>
      (await _database.getUserByEmail(email)) != null;

  UserEntriesCompanion _toCompanion(
    UserModel user,
    String password, {
    required bool isCurrent,
  }) {
    return UserEntriesCompanion(
      id: Value(user.id),
      email: Value(user.email),
      password: Value(password),
      role: Value(user.role),
      phoneNumber: Value(user.phoneNumber),
      username: Value(user.username),
      firstName: Value(user.firstName),
      lastName: Value(user.lastName),
      isCurrent: Value(isCurrent),
    );
  }

  UserModel _mapEntry(UserEntry entry) {
    return UserModel(
      id: entry.id,
      email: entry.email,
      role: entry.role,
      phoneNumber: entry.phoneNumber,
      username: entry.username,
      firstName: entry.firstName,
      lastName: entry.lastName,
    );
  }
}
