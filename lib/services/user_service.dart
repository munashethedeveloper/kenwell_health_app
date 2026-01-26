import 'package:kenwell_health_app/models/user.dart';

class UserService {
  final List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  Future<bool> createUser(String name, String email, String role) async {
    // Check if email already exists
    if (_users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
      return false;
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
    );

    _users.add(newUser);
    return true;
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  bool deleteUser(String id) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index != -1) {
      _users.removeAt(index);
      return true;
    }
    return false;
  }
}
