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
        querySnapshot.docs.map((doc) {
          final userData = Map<String, dynamic>.from(doc.data());
          userData['id'] = doc.id;
          return UserModel.fromMap(userData);
        }).toList());
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
  /// Other users' verification status is automatically updated when they log in.
  Future<void> syncCurrentUserEmailVerification() async {
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
      try {
        final updateData = {
          'emailVerified': emailVerified,
          'lastLoginAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).update(updateData);
        debugPrint(
            'FirebaseAuth: Updated emailVerified to $emailVerified for ${user.uid}');
        debugPrint('FirebaseAuth: Updated lastLoginAt timestamp');
      } on FirebaseException catch (firestoreError) {
        // Log Firestore sync failure but don't fail the login
        debugPrint(
            'FirebaseAuth: Warning - Login succeeded but verification status sync failed: ${firestoreError.message}');
        debugPrint(
            'FirebaseAuth: Verification status will be synced on next login or manual sync');
        // Continue with login even if verification sync fails
      }

      // Return user model with updated verification status
      // Create a mutable copy of userData since Firestore returns an immutable Map
      final userData = Map<String, dynamic>.from(doc.data()!);
      userData['id'] = doc.id;
      userData['emailVerified'] = emailVerified;

      debugPrint('FirebaseAuth: User data from Firestore: $userData');
      return UserModel.fromMap(userData);
    } on FirebaseAuthException catch (e, stackTrace) {
      // Handle Firebase Auth specific errors
      debugPrint('Firebase Auth error during login: ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    } on FirebaseException catch (e, stackTrace) {
      // Handle Firestore specific errors (e.g., during user data fetch)
      debugPrint(
          'Firestore error during login (user data fetch failed): ${e.code} - ${e.message}');
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

      // Send password reset email so user can set their own password
      // This is important because the admin-set password is not communicated to the user
      try {
        // Use main app's auth instance for password reset email
        await _auth.sendPasswordResetEmail(email: email);
        debugPrint('FirebaseAuth: Password reset email sent to $email');
      } catch (passwordResetError) {
        debugPrint(
            'FirebaseAuth: Warning - Failed to send password reset email: $passwordResetError');
        // Continue even if password reset email fails - user can request it later
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
    final userData = Map<String, dynamic>.from(doc.data()!);
    userData['id'] = doc.id;
    return UserModel.fromMap(userData);
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
  /// Returns true if email was sent successfully
  /// After user clicks the link and sets new password:
  /// 1. Firebase Auth password is updated automatically
  /// 2. Firestore 'passwordResetAt' field is updated to track the reset
  /// 3. User can login with new password immediately
  /// 4. Local DB password syncs on next successful login
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      final sanitizedEmail = email.trim().toLowerCase();

      // Check if user exists in Firestore before sending reset email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: sanitizedEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Password reset: No user found with email $sanitizedEmail');
        return false;
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: sanitizedEmail);
      debugPrint('Password reset email sent to: $sanitizedEmail');

      // Update Firestore to track that a reset was requested
      final userId = querySnapshot.docs.first.id;
      await _firestore.collection('users').doc(userId).update({
        'passwordResetRequestedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Password reset request timestamp updated for user: $userId');

      return true;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
          'Firebase Auth error during password reset: ${e.code} - ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      return false;
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
      return querySnapshot.docs.map((doc) {
        final userData = Map<String, dynamic>.from(doc.data());
        userData['id'] = doc.id;
        return UserModel.fromMap(userData);
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Get all users error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  /// Delete user (admin function)
  /// Deletes the user from Firebase Auth and all related data using cascade deletion
  /// This includes: Firebase Auth account, user document, user_events, and wellness_sessions
  /// 
  /// Note: Firebase client SDK has limitations for deleting auth accounts:
  /// - Can only delete if we can authenticate as that user
  /// - Requires the user's current password
  /// - Password not stored in Firestore for security reasons
  /// 
  /// For reliable auth deletion, consider:
  /// 1. Firebase Admin SDK (backend/Cloud Functions)
  /// 2. Firebase Extensions "Delete User Data"
  /// 3. Manual deletion via Firebase Console
  Future<bool> deleteUser(String userId, {String? userPassword}) async {
    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    bool authAccountDeleted = false;
    
    try {
      debugPrint('FirebaseAuth: Starting deletion for user $userId');

      // Step 1: Fetch user data from Firestore to get email
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        debugPrint('FirebaseAuth: User document not found for $userId');
        // Continue with deletion anyway in case of orphaned auth account
      }
      
      final userData = userDoc.data();
      final userEmail = userData?['email'] as String?;
      
      // Step 2: Attempt to delete Firebase Auth account if password provided
      // Using a workaround: sign in as the user with a secondary app, then delete
      if (userEmail != null && userPassword != null && userPassword.isNotEmpty) {
        try {
          debugPrint('FirebaseAuth: Attempting to delete auth account for $userEmail');
          
          // Create a secondary Firebase app to avoid affecting the current admin session
          secondaryApp = Firebase.apps
              .where((app) => app.name == 'userDeletion')
              .firstOrNull;

          if (secondaryApp == null) {
            debugPrint('FirebaseAuth: Creating new secondary app for user deletion');
            secondaryApp = await Firebase.initializeApp(
              name: 'userDeletion',
              options: DefaultFirebaseOptions.currentPlatform,
            );
          } else {
            debugPrint('FirebaseAuth: Using existing secondary app for deletion');
          }

          secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
          
          debugPrint('FirebaseAuth: Attempting to sign in as user for deletion');
          
          try {
            // Sign in as the user
            final credential = await secondaryAuth.signInWithEmailAndPassword(
              email: userEmail,
              password: userPassword,
            );
            
            if (credential.user != null) {
              debugPrint('FirebaseAuth: Successfully signed in as user, deleting auth account');
              // Delete the authenticated user
              await credential.user!.delete();
              authAccountDeleted = true;
              debugPrint('FirebaseAuth: ✓ Firebase Auth account deleted successfully');
            }
          } on FirebaseAuthException catch (authError) {
            if (authError.code == 'wrong-password' || authError.code == 'user-not-found') {
              debugPrint('FirebaseAuth: Could not authenticate user for deletion: ${authError.code}');
              debugPrint('FirebaseAuth: Password may be incorrect or user may not exist in Auth');
              debugPrint('FirebaseAuth: Auth account will remain - manual deletion required');
            } else {
              debugPrint('FirebaseAuth: Auth error during user deletion: ${authError.code} - ${authError.message}');
            }
          }
          
        } catch (authError) {
          debugPrint('FirebaseAuth: Error during auth account deletion: $authError');
        }
      } else {
        debugPrint('FirebaseAuth: No password provided for auth account deletion');
        debugPrint('FirebaseAuth: Skipping Firebase Auth deletion, only removing Firestore data');
      }

      // Step 3: Delete Firestore data (existing logic)
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
          'FirebaseAuth: Successfully deleted user $userId Firestore data and related documents');
      
      // Summary of deletion results
      if (authAccountDeleted) {
        debugPrint('FirebaseAuth: ✓ COMPLETE DELETION - Both Auth and Firestore data removed');
      } else {
        debugPrint('');
        debugPrint('WARNING: PARTIAL DELETION - Firestore data removed, Auth account remains');
        debugPrint('  Reasons for partial deletion:');
        debugPrint('  - Password not provided or incorrect');
        debugPrint('  - User may have changed password via password reset');
        debugPrint('  - Auth account may have been previously deleted');
        debugPrint('');
        debugPrint('  To complete full deletion:');
        debugPrint('  1. Manually delete via Firebase Console > Authentication');
        debugPrint('  2. Setup Firebase Cloud Functions with Admin SDK');
        debugPrint('  3. Use Firebase Extensions "Delete User Data"');
        debugPrint('  4. Or call deleteUser() with the correct password parameter');
        debugPrint('');
        debugPrint('  Note: Deleted user can still log in but will have no data.');
        debugPrint('');
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('Delete user error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      // Always clean up the secondary app session
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
