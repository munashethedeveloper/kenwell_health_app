import 'package:flutter/material.dart';
import 'package:kenwell_health_app/services/user_service.dart';

class AppProvider with ChangeNotifier {
  final UserService _userService = UserService();

  UserService get userService => _userService;

  void notifyListenersManually() {
    notifyListeners();
  }
}
