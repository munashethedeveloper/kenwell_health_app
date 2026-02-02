# User Deletion Guide for Administrators

## Important Notice About User Deletion

When you delete a user through the app's "View Users" tab, the deletion is **partial** due to Firebase's security architecture. This guide explains what happens and how to completely delete users.

## What Gets Deleted from the App

When you click "Delete" on a user in the app, the following data is removed:

✅ **Firestore Data:**
- User profile document (`users` collection)
- User event assignments (`user_events` collection)
- Wellness session records (`wellness_sessions` collection)

## What Does NOT Get Deleted

❌ **Firebase Authentication Account:**
- The user's authentication account remains active
- The email address remains registered in Firebase Auth
- The user CANNOT be re-registered with the same email

## Why This Limitation Exists

Firebase security model prevents client-side apps from deleting authentication accounts directly. This requires either:
- Firebase Admin SDK (server-side)
- Cloud Functions with admin privileges
- Manual deletion via Firebase Console

## How to Completely Delete a User

To allow the email to be reused for new registrations, follow these steps:

### Step 1: Delete from App
1. Open the app
2. Go to "View Users" tab
3. Find the user you want to delete
4. Click the delete button
5. Confirm deletion

**Result:** Firestore data deleted ✅, but auth account remains ❌

### Step 2: Delete from Firebase Console (REQUIRED)
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click "Authentication" in the left menu
4. Click "Users" tab
5. Find the user by email or UID
6. Click the three-dot menu (⋮) next to the user
7. Click "Delete user"
8. Confirm deletion

**Result:** Both Firestore data AND auth account deleted ✅✅

### Step 3: Verify Deletion
1. Try to register a new user with the same email
2. Registration should now work successfully

## Common Issues and Solutions

### Issue: "Email already in use" error when re-registering

**Cause:** Firebase Auth account was not deleted in Step 2

**Solution:**
1. Go back to Firebase Console > Authentication > Users
2. Search for the email address
3. If the user still exists, delete it
4. Try registration again

### Issue: Cannot find user in Firebase Console

**Cause:** User might have been deleted or you're looking in the wrong project

**Solution:**
1. Verify you're in the correct Firebase project
2. Use the search box to search by email
3. Check the "Deleted" filter if your project has it enabled
4. If user doesn't exist in Auth, the email should be available for re-registration

## Automated Solution (Future Enhancement)

To implement automatic deletion of both Firestore and Auth accounts, you can:

### Option 1: Cloud Functions (Recommended)
Create a callable Cloud Function:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteUserCompletely = functions.https.onCall(async (data, context) => {
  // Check if requester is admin
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Must be admin');
  }
  
  const userId = data.userId;
  
  try {
    // Delete Firestore data
    await admin.firestore().collection('users').doc(userId).delete();
    // ... delete related data ...
    
    // Delete Auth account
    await admin.auth().deleteUser(userId);
    
    return { success: true, message: 'User deleted completely' };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
```

### Option 2: Firebase Extensions
Install the "Delete User Data" extension:
1. Go to Firebase Console > Extensions
2. Search for "Delete User Data"
3. Install and configure the extension
4. It will automatically delete both Auth and Firestore data

### Option 3: Backend API
Create a backend service with Firebase Admin SDK:
- Node.js, Python, or any server-side language
- Use Firebase Admin SDK to delete users
- Call it from your Flutter app

## Quick Reference

| Action | Firestore Data | Auth Account | Email Reusable |
|--------|---------------|--------------|----------------|
| Delete in app only | ✅ Deleted | ❌ Remains | ❌ No |
| Delete in app + Console | ✅ Deleted | ✅ Deleted | ✅ Yes |
| Cloud Function | ✅ Deleted | ✅ Deleted | ✅ Yes |

## Support

If you continue to have issues:
1. Check Firebase Console Authentication logs
2. Verify you have the correct permissions
3. Contact the development team
4. Consider implementing Cloud Functions for automated deletion

---

**Last Updated:** 2026-02-02
**App Version:** Current
**Firebase SDK:** Client SDK (Limited Capabilities)
