import 'package:flutter/material.dart';
import 'package:kenwell_health_app/data/services/firebase_auth_service.dart';
import 'package:kenwell_health_app/domain/constants/user_roles.dart';
import '../../../../domain/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel();

  final FirebaseAuthService _authService = FirebaseAuthService();

  // User fields
  String email = '';
  String password = '';
  String role = '';
  String phoneNumber = '';
  // String username = '';
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
      user = await _authService.currentUser();

      if (user != null) {
        email = user!.email;
        role = UserRoles.ifValid(user!.role) ?? '';
        phoneNumber = user!.phoneNumber;
        // username = user!.username;
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
      final id = user?.id;
      if (id == null) {
        debugPrint("No user ID found");
        return;
      }

      // Update profile in Firestore
      user = await _authService.updateUserProfile(
        id: id,
        email: email,
        role: UserRoles.normalize(role),
        phoneNumber: phoneNumber,
        // username: username,
        firstName: firstName,
        lastName: lastName,
      );

      // Update password if changed
      if (password.isNotEmpty) {
        await _authService.updatePassword(password);
      }

      debugPrint("Profile updated successfully");
    } catch (e) {
      debugPrint("Error updating profile: $e");
    } finally {
      isSavingProfile = false;
      notifyListeners();
    }
  }
}
