import 'package:flutter/material.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/domain/constants/user_roles.dart';
import '../../../../domain/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel();

  final AuthService _authService = AuthService();

  // User fields
  String email = '';
  String password = '';
  String role = '';
  String phoneNumber = '';
  String username = '';
  String firstName = '';
  String lastName = '';

  List<String> get availableRoles => UserRoles.values;

  bool isLoadingProfile = false;
  bool isSavingProfile = false;
  UserModel? user;

  Future<void> loadProfile() async {
    isLoadingProfile = true;
    notifyListeners();

    try {
      user = await _authService.getCurrentUser();
      password = await _authService.getStoredPassword() ?? '';

      if (user != null) {
        email = user!.email;
        role = UserRoles.ifValid(user!.role) ?? '';
        phoneNumber = user!.phoneNumber;
        username = user!.username;
        firstName = user!.firstName;
        lastName = user!.lastName;
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    if (email.isEmpty) return;

    isSavingProfile = true;
    notifyListeners();

    try {
      final id = user?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      user = await _authService.saveUser(
        id: id,
        email: email,
        password: password,
        role: UserRoles.normalize(role),
        phoneNumber: phoneNumber,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );

      debugPrint("Profile updated successfully");
    } catch (e) {
      debugPrint("Error updating profile: $e");
    } finally {
      isSavingProfile = false;
      notifyListeners();
    }
  }
}
