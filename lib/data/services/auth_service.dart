import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user exists
    final existingEmail = prefs.getString('email');
    if (existingEmail != null && existingEmail == email) {
      return null;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    return _persistUser(
      prefs: prefs,
      id: id,
      email: email,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );
  }

  Future<UserModel?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final storedEmail = prefs.getString('email');
    final storedPassword = prefs.getString('password');

    if (storedEmail != null &&
        storedPassword != null &&
        storedEmail == email &&
        storedPassword == password) {
      return getCurrentUser();
    }

    return null;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('id');
    final storedEmail = prefs.getString('email');

    if (storedId == null || storedEmail == null) {
      return null;
    }

    return UserModel(
      id: storedId,
      email: storedEmail,
      role: prefs.getString('role') ?? '',
      phoneNumber: prefs.getString('phoneNumber') ?? '',
      username: prefs.getString('username') ?? '',
      firstName: prefs.getString('firstName') ?? '',
      lastName: prefs.getString('lastName') ?? '',
    );
  }

  Future<String?> getStoredPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
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
    final prefs = await SharedPreferences.getInstance();
    return _persistUser(
      prefs: prefs,
      id: id,
      email: email,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') != null;
  }

  Future<bool> forgotPassword(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    return storedEmail != null && storedEmail == email;
  }

  Future<UserModel> _persistUser({
    required SharedPreferences prefs,
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    await prefs.setString('id', id);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('role', role);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('username', username);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);

    return UserModel(
      id: id,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
