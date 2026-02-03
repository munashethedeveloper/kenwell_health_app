import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/models/user_model.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseAuthService {
  /// Real-time stream of all users (admin function)
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((querySnapshot) =>
        querySnapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  /// Update the emailVerified field in Firestore for the current user
  Future<void> syncCurrentUserEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      await _firestore.collection('users').doc(user.uid).update({
        'emailVerified': user.emailVerified,
      });
    }
  }

  /// Sync email verification status for the current logged-in user
  /// Note: Firebase Auth client SDK can only check the current user's verification.
  /// Other users' verification status is updated when they log in.
  /// This method is named for consistency with the UI action "Sync All Users"
  /// which actually syncs the current admin user's status.
  Future<void> syncAllUsersEmailVerification() async {
    try {
      debugPrint('FirebaseAuth: Syncing current user verification status');
      
      // Sync the current user's verification status
      await syncCurrentUserEmailVerified();
      
      debugPrint('FirebaseAuth: Verification sync completed');
    } catch (e, stackTrace) {
      debugPrint('FirebaseAuth: Error syncing verification status: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Check if current user's email is verified
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

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

      // Reload user to get latest verification status
      await user.reload();
      final updatedUser = _auth.currentUser;
      final emailVerified = updatedUser?.emailVerified ?? false;

      // Fetch additional user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        debugPrint('FirebaseAuth: User document not found for ${user.uid}');
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          role: '',
          firstName: '',
          lastName: '',
          phoneNumber: '',
          emailVerified: emailVerified,
        );
      }

      // Update Firestore with latest email verification status
      await _firestore.collection('users').doc(user.uid).update({
        'emailVerified': emailVerified,
      });
      debugPrint('FirebaseAuth: Updated emailVerified to $emailVerified for ${user.uid}');

      // Return user model with updated verification status
      final userData = doc.data()!;
      userData['emailVerified'] = emailVerified;
      
      debugPrint('FirebaseAuth: User data from Firestore: $userData');
      return UserModel.fromMap(userData);
    } on FirebaseAuthException catch (e, stackTrace) {
      // Handle Firebase Auth specific errors
      debugPrint('Firebase Auth error during login: ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    } on FirebaseException catch (e, stackTrace) {
      // Handle Firestore specific errors (e.g., during verification status update)
      debugPrint('Firestore error during login (verification sync may have failed): ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    } catch (e, stackTrace) {
      // Handle any other errors
      debugPrint('Login error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  /// Register a new user with extra fields
  /// Uses a secondary Firebase app to avoid logging out the current admin user
  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    //required String username,
    required String firstName,
    required String lastName,
    emailVerified = false,
    required String phoneNumber,
  }) async {
    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    try {
      debugPrint('FirebaseAuth: Starting registration for $email');

      // Create a secondary Firebase app to avoid logging out the current user
      // This is necessary because createUserWithEmailAndPassword automatically
      // signs in the newly created user, which would log out the admin
      // Check if the app already exists
      secondaryApp = Firebase.apps
          .where((app) => app.name == 'userRegistration')
          .firstOrNull;

      if (secondaryApp != null) {
        debugPrint('FirebaseAuth: Using existing secondary app');
      } else {
        // App doesn't exist, create it
        debugPrint(
            'FirebaseAuth: Creating new secondary app for user registration');
        secondaryApp = await Firebase.initializeApp(
          name: 'userRegistration',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Use the secondary app's auth instance
      secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        debugPrint('FirebaseAuth: User creation failed - user is null');
        return null;
      }

      debugPrint('FirebaseAuth: User created with UID: ${user.uid}');

      // Send email verification
      await user.sendEmailVerification();

      // Create UserModel
      final userModel = UserModel(
        id: user.uid,
        email: email,
        role: role,
        // username: username,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        emailVerified: emailVerified,
      );

      debugPrint(
          'FirebaseAuth: Saving user data to Firestore: ${userModel.toMap()}');

      // Save extra fields to Firestore (using the main app's firestore)
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        debugPrint('FirebaseAuth: User data saved successfully to Firestore');
      } catch (firestoreError, firestoreStackTrace) {
        debugPrint('FirebaseAuth: ERROR saving to Firestore: $firestoreError');
        debugPrintStack(stackTrace: firestoreStackTrace);
        // Note: User account was created in Firebase Auth even if Firestore fails
        // This could lead to inconsistent state, but we still return the user model
        // so the caller knows the user was created
      }

      return userModel;
    } catch (e, stackTrace) {
      debugPrint('Registration error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    } finally {
      // Always clean up the secondary app session
      // This ensures the admin's session remains active regardless of success or failure
      if (secondaryAuth != null) {
        try {
          await secondaryAuth.signOut();
          debugPrint(
              'FirebaseAuth: Signed out from secondary app, main session preserved');
        } catch (signOutError) {
          debugPrint(
              'FirebaseAuth: Error signing out from secondary app: $signOutError');
        }
      }
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get currently logged in user (optional)
  Future<UserModel?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('FirebaseAuth: No user currently logged in');
      return null;
    }

    debugPrint('FirebaseAuth: Fetching user data for ${user.uid}');
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      debugPrint('FirebaseAuth: User document not found for ${user.uid}');
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        role: '',
        // username: '',
        firstName: '',
        lastName: '',
        phoneNumber: '',
        emailVerified: user.emailVerified,
      );
    }
    debugPrint('FirebaseAuth: Current user data: ${doc.data()}');
    return UserModel.fromMap(doc.data()!);
  }

  /// Update user profile in Firestore
  /// Note: Email updates may require recent authentication
  Future<UserModel?> updateUserProfile({
    required String id,
    required String email,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != id) {
        debugPrint('User not authenticated or ID mismatch');
        return null;
      }

      // Update email if changed - may require recent authentication
      if (user.email != email) {
        try {
          await user.verifyBeforeUpdateEmail(email);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            debugPrint(
                'Email update requires recent login. User needs to re-authenticate.');
            rethrow; // Re-throw so caller can handle re-authentication
          }
          rethrow;
        }
      }

      // Create updated UserModel
      final userModel = UserModel(
        id: id,
        email: email,
        role: role,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        emailVerified: user.emailVerified,
      );

      // Update Firestore document
      await _firestore.collection('users').doc(id).update(userModel.toMap());

      return userModel;
    } catch (e, stackTrace) {
      debugPrint('Update profile error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  /// Update user password
  /// Note: May require recent authentication for security
  Future<bool> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('No user logged in');
        return false;
      }

      try {
        await user.updatePassword(newPassword);
        debugPrint('Password updated successfully');
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          debugPrint(
              'Password update requires recent login. User needs to re-authenticate.');
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      debugPrint('Update password error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Re-authenticate user with their current password
  /// Required before sensitive operations like email/password changes
  Future<bool> reauthenticateUser(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        debugPrint('No user logged in or email is null');
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      debugPrint('Re-authentication successful');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Re-authentication error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('Password reset email sent to: $email');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Password reset error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Get all users (admin function)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Get all users error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  /// Delete user (admin function)
  /// Deletes the user and all related data using cascade deletion
  /// This includes: user document, user_events, and wellness_sessions
  Future<bool> deleteUser(String userId) async {
    try {
      debugPrint('FirebaseAuth: Starting deletion for user $userId');

      // Firestore batch limit is 500 operations per batch
      const int batchLimit = 500;
      final List<WriteBatch> batches = [];
      WriteBatch currentBatch = _firestore.batch();
      int operationCount = 0;

      // Helper function to manage batch operations
      void addDeleteOperation(DocumentReference docRef) {
        if (operationCount >= batchLimit) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationCount = 0;
        }
        currentBatch.delete(docRef);
        operationCount++;
      }

      // 1. Delete the user's main document
      addDeleteOperation(_firestore.collection('users').doc(userId));
      debugPrint('FirebaseAuth: Queued user document deletion');

      // 2. Query all related data concurrently
      final results = await Future.wait([
        _firestore
            .collection('user_events')
            .where('userId', isEqualTo: userId)
            .get(),
        _firestore
            .collection('wellness_sessions')
            .where('nurseUserId', isEqualTo: userId)
            .get(),
      ]);

      final userEventsQuery = results[0];
      final wellnessSessionsQuery = results[1];

      // 3. Add user_events to batch
      for (var doc in userEventsQuery.docs) {
        addDeleteOperation(doc.reference);
      }
      debugPrint(
          'FirebaseAuth: Queued ${userEventsQuery.docs.length} user_events for deletion');

      // 4. Add wellness_sessions to batch
      for (var doc in wellnessSessionsQuery.docs) {
        addDeleteOperation(doc.reference);
      }
      debugPrint(
          'FirebaseAuth: Queued ${wellnessSessionsQuery.docs.length} wellness_sessions for deletion');

      // Add the final batch if it has operations
      if (operationCount > 0) {
        batches.add(currentBatch);
      }

      // Commit all batches concurrently
      final totalDeletions =
          1 + userEventsQuery.docs.length + wellnessSessionsQuery.docs.length;
      debugPrint(
          'FirebaseAuth: Committing ${batches.length} batch(es) with total $totalDeletions deletions');

      await Future.wait(batches.map((batch) => batch.commit()));

      debugPrint(
          'FirebaseAuth: Successfully deleted user $userId and all related data');

      // Note: Deleting Firebase Auth user requires admin SDK or the user to be logged in
      // For admin delete, you would typically use Firebase Admin SDK on backend
      // Or use Firebase Extensions like "Delete User Data"
      // For now, we've deleted the Firestore documents and related data
      // The auth account can be deleted via Firebase Console or Admin SDK

      return true;
    } catch (e, stackTrace) {
      debugPrint('Delete user error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Reset user password (admin function)
  /// Sends password reset email to the user
  Future<bool> resetUserPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('FirebaseAuth: Password reset email sent to $email');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Reset password error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Admin: Directly reset user password to a specific value
  /// Note: This requires Firebase Admin SDK on backend
  /// For client-side, we can only send password reset emails
  /// This is a placeholder that sends reset email
  Future<bool> adminResetPassword(String email, String newPassword) async {
    // Firebase client SDK doesn't support setting passwords for other users
    // This would require Firebase Admin SDK on a backend server
    // For now, send a password reset email
    debugPrint(
        'FirebaseAuth: Client SDK cannot set passwords for other users. Sending reset email instead.');
    return await resetUserPassword(email);
  }
}
