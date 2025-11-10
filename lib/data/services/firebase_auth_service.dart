import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login with email & password
  Future<UserModel?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return null;
      }

      // Fetch additional user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          role: '',
          username: '',
          firstName: '',
          lastName: '',
          phoneNumber: '',
        );
      }

      return UserModel.fromMap(doc.data()!);
    } catch (e, stackTrace) {
      // Handle errors (FirebaseAuthException, network issues, etc.)
      debugPrint('Login error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  /// Register a new user with extra fields
  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String username,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return null;
      }

      // Create UserModel
      final userModel = UserModel(
        id: user.uid,
        email: email,
        role: role,
        username: username,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      // Save extra fields to Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } catch (e, stackTrace) {
      debugPrint('Registration error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get currently logged in user (optional)
  Future<UserModel?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        role: '',
        username: '',
        firstName: '',
        lastName: '',
        phoneNumber: '',
      );
    }
    return UserModel.fromMap(doc.data()!);
  }
}
