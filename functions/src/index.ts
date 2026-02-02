import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Cloud Function to completely delete a user
 * Deletes both Firestore data and Firebase Authentication account
 * 
 * This function can only be called by authenticated admin users
 * 
 * @param {object} data - Contains userId to delete
 * @param {object} context - Contains auth information
 * @returns {Promise<object>} - Success status and message
 */
export const deleteUserCompletely = functions.https.onCall(
  async (data: {userId: string}, context) => {
    // Check if user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to delete users"
      );
    }

    // Get the calling user's role from Firestore
    const callingUserId = context.auth.uid;
    const callingUserDoc = await admin
      .firestore()
      .collection("users")
      .doc(callingUserId)
      .get();

    if (!callingUserDoc.exists) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Calling user not found in database"
      );
    }

    const callingUserRole = callingUserDoc.data()?.role?.toUpperCase();

    // Check if calling user is admin or has permission
    const allowedRoles = ["ADMIN", "TOP MANAGEMENT"];
    if (!allowedRoles.includes(callingUserRole)) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only administrators can delete users"
      );
    }

    const userId = data.userId;

    if (!userId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "userId is required"
      );
    }

    // Prevent self-deletion
    if (userId === callingUserId) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "You cannot delete your own account"
      );
    }

    try {
      functions.logger.info(`Starting deletion for user ${userId}`);

      // Use a batch for Firestore deletions
      const db = admin.firestore();
      const batch = db.batch();
      let deletionCount = 0;

      // 1. Delete user document
      const userRef = db.collection("users").doc(userId);
      batch.delete(userRef);
      deletionCount++;
      functions.logger.info("Queued user document deletion");

      // 2. Query and delete user_events
      const userEventsQuery = await db
        .collection("user_events")
        .where("userId", "==", userId)
        .get();

      userEventsQuery.forEach((doc) => {
        batch.delete(doc.ref);
        deletionCount++;
      });
      functions.logger.info(
        `Queued ${userEventsQuery.size} user_events for deletion`
      );

      // 3. Query and delete wellness_sessions
      const wellnessSessionsQuery = await db
        .collection("wellness_sessions")
        .where("nurseUserId", "==", userId)
        .get();

      wellnessSessionsQuery.forEach((doc) => {
        batch.delete(doc.ref);
        deletionCount++;
      });
      functions.logger.info(
        `Queued ${wellnessSessionsQuery.size} wellness_sessions for deletion`
      );

      // Commit Firestore deletions
      await batch.commit();
      functions.logger.info(
        `Successfully deleted ${deletionCount} Firestore documents`
      );

      // 4. Delete Firebase Auth account
      await admin.auth().deleteUser(userId);
      functions.logger.info(
        `Successfully deleted Firebase Auth account for user ${userId}`
      );

      return {
        success: true,
        message: "User deleted completely (Firestore data + Auth account)",
        deletedDocuments: deletionCount,
      };
    } catch (error: any) {
      functions.logger.error("Delete user error:", error);

      // Provide specific error messages
      if (error.code === "auth/user-not-found") {
        throw new functions.https.HttpsError(
          "not-found",
          "User authentication account not found"
        );
      }

      throw new functions.https.HttpsError(
        "internal",
        `Failed to delete user: ${error.message}`
      );
    }
  }
);

/**
 * HTTP function for health check
 * Useful for testing deployment
 */
export const healthCheck = functions.https.onRequest((request, response) => {
  response.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    message: "Kenwell Health App Cloud Functions are running",
  });
});
