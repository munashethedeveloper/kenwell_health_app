import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/models/user_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseFunctions _functions;

  FirebaseAuthService() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _functions = FirebaseFunctions.instance;
  }

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
      bool emailVerified = user.emailVerified;
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

      debugPrint('FirebaseAuth: User data from Firestore: ${doc.data()}');
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
    //required String username,
    required String firstName,
    required String lastName,
    emailVerified = false,
    required String phoneNumber,
  }) async {
    try {
      debugPrint('FirebaseAuth: Starting registration for $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
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

      // Save extra fields to Firestore
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        debugPrint('FirebaseAuth: User data saved successfully to Firestore');
      } catch (firestoreError) {
        debugPrint('FirebaseAuth: ERROR saving to Firestore: $firestoreError');
        // Even if Firestore save fails, return the user model
        // The user account was created in Firebase Auth
        rethrow;
      }

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
  /// Deletes the user completely including Firebase Auth account
  /// 
  /// This method uses a Cloud Function to delete both Firestore data and Auth account.
  /// If Cloud Function fails, it falls back to Firestore-only deletion.
  /// 
  /// Cloud Function advantages:
  /// - Deletes both Firestore data AND Firebase Auth account
  /// - Email can be immediately reused for new registrations
  /// - Single operation, fully automated
  /// 
  /// Requirements:
  /// - Cloud Function must be deployed (see CLOUD_FUNCTIONS_SETUP.md)
  /// - Calling user must be authenticated
  /// - Calling user must have ADMIN or TOP MANAGEMENT role
  /// 
  /// If Cloud Function is not available or fails:
  /// - Falls back to Firestore-only deletion
  /// - Auth account remains (email cannot be reused)
  /// - Admin must manually delete from Firebase Console
  Future<bool> deleteUser(String userId) async {
    try {
      debugPrint('FirebaseAuth: Starting deletion for user $userId');

      // Try to use Cloud Function for complete deletion
      try {
        debugPrint('FirebaseAuth: Attempting Cloud Function deletion...');
        
        final callable = _functions.httpsCallable('deleteUserCompletely');
        final result = await callable.call<Map<String, dynamic>>({
          'userId': userId,
        });

        if (result.data['success'] == true) {
          debugPrint(
            'FirebaseAuth: Cloud Function successfully deleted user $userId '
            '(${result.data['deletedDocuments']} documents + Auth account)'
          );
          debugPrint('SUCCESS: Email can now be reused for new registrations!');
          return true;
        }
      } on FirebaseFunctionsException catch (e) {
        debugPrint('FirebaseAuth: Cloud Function error: ${e.code} - ${e.message}');
        debugPrint('FirebaseAuth: Falling back to Firestore-only deletion...');
        // Fall through to Firestore-only deletion
      } catch (e) {
        debugPrint('FirebaseAuth: Cloud Function call failed: $e');
        debugPrint('FirebaseAuth: Falling back to Firestore-only deletion...');
        // Fall through to Firestore-only deletion
      }

      // Fallback: Firestore-only deletion (original implementation)
      debugPrint('FirebaseAuth: Using Firestore-only deletion (Auth account will remain)');

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
          'FirebaseAuth: Successfully deleted user $userId Firestore data');
      
      debugPrint(
          'WARNING: Firebase Auth account for user $userId was NOT deleted. '
          'The email address cannot be reused until the Auth account is manually '
          'deleted from Firebase Console OR Cloud Function is deployed.');

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
