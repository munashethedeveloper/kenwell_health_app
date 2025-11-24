import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';

class AuthService {
  AuthService(this._database)
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  final AppDatabase _database;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return null;
      }

      final user = UserModel(
        id: uid,
        email: email,
        role: role,
        phoneNumber: phoneNumber,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );

      await _usersCollection.doc(uid).set({
        'email': email,
        'role': role,
        'phoneNumber': phoneNumber,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _persistLocalUser(user,
          password: password, isCurrent: false, setCurrent: false);

      await _firebaseAuth.signOut();
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase register error: ${e.message}');
      rethrow;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;

      final doc = await _usersCollection.doc(uid).get();
      final data = doc.data() ?? {};
      final user = _userFromFirestore(
        uid,
        data,
        fallbackEmail: credential.user?.email ?? email,
      );

      await _persistLocalUser(user, password: password);
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase login error: ${e.message}');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final entry = await _database.getCurrentUserEntry();
    if (entry != null) {
      return _mapEntry(entry);
    }

    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _usersCollection.doc(firebaseUser.uid).get();
      final data = doc.data();
      if (data == null) return null;

      final user = _userFromFirestore(
        firebaseUser.uid,
        data,
        fallbackEmail: firebaseUser.email ?? '',
      );

      await _persistLocalUser(user, password: '');
      return user;
    } catch (e) {
      debugPrint('Failed to fetch remote profile: $e');
      return null;
    }
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

    try {
      await _usersCollection.doc(id).set({
        'email': email,
        'role': role,
        'phoneNumber': phoneNumber,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update Firestore profile: $e');
    }

    if (password.isNotEmpty) {
      try {
        await _firebaseAuth.currentUser?.updatePassword(password);
      } catch (e) {
        debugPrint('Failed to update password: $e');
      }
    }

    await _persistLocalUser(user, password: password);
    return user;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _database.clearCurrentUser();
  }

  Future<bool> isLoggedIn() async => _firebaseAuth.currentUser != null;

  Future<bool> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Forgot password error: ${e.message}');
      return false;
    }
  }

  Future<void> _persistLocalUser(
    UserModel user, {
    String password = '',
    bool isCurrent = true,
    bool setCurrent = true,
  }) async {
    await _database.upsertUser(
      _toCompanion(
        user,
        password,
        isCurrent: isCurrent,
      ),
    );
    if (setCurrent && isCurrent) {
      await _database.setCurrentUser(user.id);
    }
  }

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

  UserModel _userFromFirestore(
    String id,
    Map<String, dynamic> data, {
    required String fallbackEmail,
  }) {
    return UserModel(
      id: id,
      email: (data['email'] as String?) ?? fallbackEmail,
      role: data['role'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      username: data['username'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
    );
  }
}
