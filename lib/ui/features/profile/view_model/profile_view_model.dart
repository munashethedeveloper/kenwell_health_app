import 'package:flutter/material.dart';
import '../../../../data/repositories_dcl/auth_repository_dcl.dart';
import '../../../../domain/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // User fields
  String email = '';
  String password = '';
  String role = '';
  String phoneNumber = '';
  String username = '';
  String firstName = '';
  String lastName = '';

  bool isLoading = false;
  UserModel? user;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    // to do: Fetch profile from AuthRepository if you store user details persistently
    // For now, this could pull from a logged-in user cache or Firebase

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile() async {
    if (email.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      // Simulate update or save logic here
      user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        role: role,
        username: username,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      // In a real app: push update to Firestore or your backend here

      debugPrint("Profile updated successfully");
    } catch (e) {
      debugPrint("Error updating profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
