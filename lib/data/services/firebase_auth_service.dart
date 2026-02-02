import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  /// Real-time stream of all users (admin function)
  /// Excludes users marked as deleted
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore
        .collection('users')
        .where('deleted', isNotEqualTo: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
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
      bool emailVerified = user.emailVerified;
      
      if (!doc.exists) {
        debugPrint('FirebaseAuth: User document not found for ${user.uid}');
        // Sign out the user since their account is orphaned
        await _auth.signOut();
        return null;
      }

      final userData = doc.data()!;
      
      // Check if user is marked as deleted
      if (userData['deleted'] == true) {
        debugPrint('FirebaseAuth: User ${user.uid} is marked as deleted');
        await _auth.signOut();
        return null;
      }

      debugPrint('FirebaseAuth: User data from Firestore: $userData');
      return UserModel.fromMap(userData);
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

      UserCredential? userCredential;
      User? user;
      bool isReactivation = false;

      // Try to create a new user
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = userCredential.user;
      } on FirebaseAuthException catch (authError) {
        // Check if error is due to email already in use
        if (authError.code == 'email-already-in-use') {
          debugPrint('FirebaseAuth: Email already in use, checking if it\'s a deleted user');
          
          // Note: This approach has a potential security consideration regarding account enumeration.
          // An attacker could determine if an email is registered by observing different error patterns.
          // However, this is a necessary trade-off given Firebase client SDK limitations.
          // Consider implementing rate limiting and monitoring for registration attempts.
          
          // Try to sign in with the credentials to get the user
          try {
            userCredential = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            user = userCredential.user;
            
            if (user != null) {
              // Check if this is a deleted user
              final doc = await _firestore.collection('users').doc(user.uid).get();
              
              if (doc.exists && doc.data()?['deleted'] == true) {
                debugPrint('FirebaseAuth: Found deleted user, will reactivate');
                isReactivation = true;
              } else {
                // User exists and is not deleted - can't register
                debugPrint('FirebaseAuth: User already exists and is active');
                await _auth.signOut();
                return null;
              }
            }
          } catch (signInError) {
            // Wrong password or other error - can't proceed
            debugPrint('FirebaseAuth: Cannot verify deleted user status: $signInError');
            return null;
          }
        } else {
          // Other authentication error
          rethrow;
        }
      }

      if (user == null) {
        debugPrint('FirebaseAuth: User creation failed - user is null');
        return null;
      }

      debugPrint('FirebaseAuth: User ${isReactivation ? 'reactivated' : 'created'} with UID: ${user.uid}');

      // Send email verification for new users
      if (!isReactivation) {
        await user.sendEmailVerification();
      }

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

      // Save extra fields to Firestore (this will overwrite deleted user data if reactivating)
      try {
        final dataToSave = {
          ...userModel.toMap(),
          'deleted': false, // Explicitly mark as not deleted
          'reactivatedAt': isReactivation ? FieldValue.serverTimestamp() : null,
        };
        
        // Remove deletedAt timestamp if reactivating to keep audit trail clean
        if (isReactivation) {
          dataToSave.remove('deletedAt');
        }
        
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(dataToSave);
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
  /// Excludes users marked as deleted
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('deleted', isNotEqualTo: true)
          .get();
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
  /// Marks the user as deleted and removes all related data
  /// Uses soft delete for user document to prevent re-registration issues
  /// This includes: marking user as deleted, deleting user_events, and wellness_sessions
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

      // Helper function to manage update operations
      void addUpdateOperation(DocumentReference docRef, Map<String, dynamic> data) {
        if (operationCount >= batchLimit) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationCount = 0;
        }
        currentBatch.update(docRef, data);
        operationCount++;
      }

      // 1. Mark the user as deleted (soft delete) instead of removing the document
      // This prevents issues with orphaned Firebase Auth accounts
      addUpdateOperation(
        _firestore.collection('users').doc(userId),
        {
          'deleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        },
      );
      debugPrint('FirebaseAuth: Queued user document for soft delete');

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

      // 3. Delete user_events (hard delete - these are activity records)
      for (var doc in userEventsQuery.docs) {
        addDeleteOperation(doc.reference);
      }
      debugPrint('FirebaseAuth: Queued ${userEventsQuery.docs.length} user_events for deletion');

      // 4. Delete wellness_sessions (hard delete - these are session records)
      for (var doc in wellnessSessionsQuery.docs) {
        addDeleteOperation(doc.reference);
      }
      debugPrint('FirebaseAuth: Queued ${wellnessSessionsQuery.docs.length} wellness_sessions for deletion');

      // Add the final batch if it has operations
      if (operationCount > 0) {
        batches.add(currentBatch);
      }

      // Commit all batches concurrently
      final totalOperations = 1 + userEventsQuery.docs.length + wellnessSessionsQuery.docs.length;
      debugPrint('FirebaseAuth: Committing ${batches.length} batch(es) with total $totalOperations operations');
      
      await Future.wait(batches.map((batch) => batch.commit()));
      
      debugPrint('FirebaseAuth: Successfully deleted user $userId and all related data');

      // Note: We use soft delete for the user document to handle Firebase Auth limitations
      // The user document is marked as deleted but not removed
      // This allows detection and handling of deleted users during login and re-registration
      // Related activity data (user_events, wellness_sessions) is hard deleted

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
