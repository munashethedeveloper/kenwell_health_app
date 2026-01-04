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
        debugPrint("Cannot update profile: User not logged in");
        // In a real app, you might want to notify the UI about this error
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

      // Update password if changed and not empty
      if (password.isNotEmpty) {
        try {
          final success = await _authService.updatePassword(password);
          if (!success) {
            debugPrint("Password update failed - may require re-authentication");
            // In production, you should handle this by prompting user to re-authenticate
          }
        } catch (e) {
          debugPrint("Password update error: $e");
          // Handle re-authentication requirement here if needed
          rethrow;
        }
      }

      debugPrint("Profile updated successfully");
    } catch (e) {
      debugPrint("Error updating profile: $e");
      rethrow; // Re-throw so UI can display appropriate error message
    } finally {
      isSavingProfile = false;
      notifyListeners();
    }
  }
}
