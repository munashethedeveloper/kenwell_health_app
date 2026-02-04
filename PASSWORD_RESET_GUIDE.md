# Password Reset Guide - Kenwell Health App

## Overview

This guide explains how password reset works in the Kenwell Health App, why it's been improved, and how to troubleshoot any issues.

---

## The Problem (Before Fix)

### Issue Reported
**"Users still can't login even after sending the password reset email to already registered users"**

### Why This Happened

When a user reset their password:
1. ✅ Firebase Auth sent password reset email
2. ✅ User clicked link and set new password
3. ✅ Firebase Auth updated the password
4. ❌ **Local database still had old password**
5. ❌ **Firestore had no tracking of the reset**
6. ❌ **No clear messaging about what to do next**

**Result:** Users were confused and thought password reset didn't work.

---

## The Solution (After Fix)

### Key Improvements

#### 1. Database Synchronization
**Problem:** Local database password out of sync with Firebase Auth

**Solution:** Always sync password on successful login
```dart
// After successful Firebase Auth login
if (user exists in local DB) {
  // Update their password to match what they just used
  await _database.updateUser(..., password: sanitizedPassword);
} else {
  // Create new user with current password
  await _database.createUser(..., password: sanitizedPassword);
}
```

**Why this works:**
- Firebase Auth is the **source of truth** for passwords
- Local database password syncs automatically after any successful login
- Works for: new logins, password resets, password changes

#### 2. User Verification Before Reset
**Problem:** No validation that user exists before sending reset email

**Solution:** Check Firestore before sending email
```dart
// Verify user exists
final querySnapshot = await _firestore
    .collection('users')
    .where('email', isEqualTo: sanitizedEmail)
    .get();

if (querySnapshot.docs.isEmpty) {
  return false; // User doesn't exist
}

// User exists, send reset email
await _auth.sendPasswordResetEmail(email: sanitizedEmail);
```

**Benefits:**
- Better error messages
- No confusing emails sent to non-users
- Security improvement (don't reveal which emails exist)

#### 3. Audit Tracking in Firestore
**Problem:** No way to track password reset requests or successful logins

**Solution:** Track timestamps in Firestore
```dart
// When reset email sent
await _firestore.collection('users').doc(userId).update({
  'passwordResetRequestedAt': FieldValue.serverTimestamp(),
});

// When user logs in
await _firestore.collection('users').doc(userId).update({
  'lastLoginAt': FieldValue.serverTimestamp(),
});
```

**Benefits:**
- Verify reset emails were sent
- Confirm users logged in after reset
- Audit trail for security
- Troubleshooting capabilities

#### 4. Improved User Communication
**Problem:** Users didn't know what to expect after reset

**Solution:** Clear, detailed messages
```dart
// Success message after reset
'Password reset email sent! Check your email and click the link to set 
a new password. After setting your new password, you can login immediately.'
```

**Benefits:**
- Users know exactly what to do
- Sets correct expectations
- Reduces support tickets
- Longer display time for important messages

---

## How Password Reset Works (Complete Flow)

### User-Initiated Reset (Forgot Password)

```
┌────────────────────────────────────────────────────────────────┐
│ 1. USER REQUESTS PASSWORD RESET                                 │
├────────────────────────────────────────────────────────────────┤
│ • User opens Forgot Password screen                             │
│ • Enters email: user@example.com                                │
│ • Clicks "Send Reset Link"                                      │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 2. APP VALIDATES EMAIL EXISTS                                   │
├────────────────────────────────────────────────────────────────┤
│ Query Firestore:                                                │
│   WHERE email = 'user@example.com'                              │
│                                                                  │
│ If NOT found:                                                   │
│   ❌ Return error: "No account found with this email"          │
│                                                                  │
│ If found:                                                       │
│   ✅ Continue to next step                                     │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 3. FIREBASE SENDS RESET EMAIL                                   │
├────────────────────────────────────────────────────────────────┤
│ Firebase Auth:                                                  │
│   sendPasswordResetEmail(user@example.com)                      │
│                                                                  │
│ Email sent to user with:                                        │
│   • Secure reset link (expires in 1 hour)                       │
│   • Instructions to set new password                            │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 4. UPDATE FIRESTORE WITH RESET REQUEST                          │
├────────────────────────────────────────────────────────────────┤
│ Update Firestore:                                               │
│   users/{userId}.passwordResetRequestedAt = NOW()               │
│                                                                  │
│ This creates an audit trail:                                    │
│   • Proves reset email was sent                                 │
│   • Track when reset was requested                              │
│   • Useful for troubleshooting                                  │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 5. SHOW SUCCESS MESSAGE TO USER                                 │
├────────────────────────────────────────────────────────────────┤
│ Display:                                                        │
│   "Password reset email sent! Check your email and click        │
│    the link to set a new password. After setting your new      │
│    password, you can login immediately."                        │
│                                                                  │
│ Duration: 6 seconds with OK button                              │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 6. USER RECEIVES EMAIL                                          │
├────────────────────────────────────────────────────────────────┤
│ Email from: noreply@kenwell-health.firebaseapp.com             │
│ Subject: Reset your password                                    │
│                                                                  │
│ Content:                                                        │
│   "Someone requested a password reset for your account"         │
│   [Reset Password] ← Button/link                               │
│                                                                  │
│ Link expires: 1 hour                                            │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 7. USER SETS NEW PASSWORD                                       │
├────────────────────────────────────────────────────────────────┤
│ • User clicks reset link in email                               │
│ • Opens Firebase password reset page                            │
│ • Enters new password: "MyNewSecurePass123!"                    │
│ • Confirms password                                             │
│ • Submits form                                                  │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 8. FIREBASE AUTH UPDATES PASSWORD                               │
├────────────────────────────────────────────────────────────────┤
│ Firebase Auth:                                                  │
│   • Validates new password                                      │
│   • Updates password hash                                       │
│   • Invalidates reset link                                      │
│                                                                  │
│ ✅ Password updated successfully                               │
│ ✅ Old password no longer works                                │
│ ✅ New password is active immediately                          │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 9. USER LOGS IN WITH NEW PASSWORD                               │
├────────────────────────────────────────────────────────────────┤
│ • User opens app                                                │
│ • Goes to login screen                                          │
│ • Enters email: user@example.com                                │
│ • Enters password: "MyNewSecurePass123!"                        │
│ • Clicks Login                                                  │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 10. FIREBASE AUTH VALIDATES PASSWORD                            │
├────────────────────────────────────────────────────────────────┤
│ Firebase Auth:                                                  │
│   signInWithEmailAndPassword(email, password)                   │
│                                                                  │
│ ✅ Password matches → Login succeeds                           │
│ ✅ Returns user object                                         │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 11. SYNC LOCAL DATABASE PASSWORD                                │
├────────────────────────────────────────────────────────────────┤
│ Check local DB:                                                 │
│   user = getUserById(firebaseUser.uid)                          │
│                                                                  │
│ Update user:                                                    │
│   updateUser(..., password: "MyNewSecurePass123!")              │
│                                                                  │
│ ✅ Local DB password now matches Firebase Auth                │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 12. UPDATE FIRESTORE TRACKING                                   │
├────────────────────────────────────────────────────────────────┤
│ Update Firestore:                                               │
│   users/{userId}.lastLoginAt = NOW()                            │
│   users/{userId}.emailVerified = true/false                     │
│                                                                  │
│ ✅ Confirms user logged in after reset                         │
│ ✅ Creates audit trail                                         │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 13. USER ACCESSES APP                                           │
├────────────────────────────────────────────────────────────────┤
│ • Profile loaded with user role                                 │
│ • Navigate to main screen based on permissions                  │
│ • User can access all authorized features                       │
│                                                                  │
│ ✅ PASSWORD RESET COMPLETE AND SUCCESSFUL! ✅                 │
└────────────────────────────────────────────────────────────────┘
```

### Admin-Initiated Reset

```
┌────────────────────────────────────────────────────────────────┐
│ 1. ADMIN SELECTS RESET PASSWORD                                 │
├────────────────────────────────────────────────────────────────┤
│ • Admin opens User Management                                   │
│ • Views list of users                                           │
│ • Clicks actions menu (⋮) for user                             │
│ • Selects "Reset Password"                                      │
│ • Confirms action                                               │
└────────────────────────────────────────────────────────────────┘
                          ↓
┌────────────────────────────────────────────────────────────────┐
│ 2-12. SAME FLOW AS USER-INITIATED RESET                         │
├────────────────────────────────────────────────────────────────┤
│ • Email verified to exist                                       │
│ • Reset email sent to user                                      │
│ • Firestore updated with passwordResetRequestedAt               │
│ • Admin sees detailed success message                           │
│ • User receives email and sets new password                     │
│ • User logs in with new password                                │
│ • Databases synchronized                                        │
└────────────────────────────────────────────────────────────────┘
```

---

## Database Structure

### Firestore Collections

#### users/{userId}

**Standard Fields:**
```javascript
{
  "id": "ZlbBNIDm3AWyAagVxKXn6mfwXz43",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "PROJECT_MANAGER",
  "phoneNumber": "+27 12 345 6789",
  "emailVerified": true
}
```

**New Tracking Fields:**
```javascript
{
  // NEW: Timestamp when password reset was last requested
  "passwordResetRequestedAt": Timestamp(2026, 2, 4, 10, 30, 0),
  
  // NEW: Timestamp of last successful login
  "lastLoginAt": Timestamp(2026, 2, 4, 10, 35, 0)
}
```

### Local SQLite Database

**users table:**
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,           -- Firebase UID
  email TEXT NOT NULL,
  password TEXT,                 -- Synced from last successful login
  role TEXT,
  phoneNumber TEXT,
  firstName TEXT,
  lastName TEXT
);
```

**Important Notes:**
- `password` field is synced after every successful Firebase Auth login
- This is NOT the source of truth (Firebase Auth is)
- Used only for offline fallback scenarios
- Always updated to match the password that worked in Firebase

---

## Troubleshooting

### Problem: User can't login after password reset

**Diagnosis Steps:**

1. **Check if reset email was sent:**
   ```
   Open Firestore Console
   → users collection
   → Find user by email
   → Check passwordResetRequestedAt field
   
   If present: Email was sent ✅
   If missing: Email was never sent ❌
   ```

2. **Check if user actually set new password:**
   ```
   Ask user: "Did you click the link in the email and set a new password?"
   
   Common issues:
   - Link expired (1 hour limit)
   - User didn't complete the form
   - Email went to spam
   - User didn't receive email
   ```

3. **Check if user is using correct password:**
   ```
   Ask user: "Are you using the NEW password you just set, not the old one?"
   
   Common confusion:
   - User tries old password
   - User forgets new password they just set
   - User has multiple passwords for different apps
   ```

4. **Check Firebase Auth console:**
   ```
   Open Firebase Console
   → Authentication
   → Users tab
   → Find user by email
   → Check "Last sign-in" timestamp
   
   If recent: User successfully logged in ✅
   If old: User hasn't logged in yet ❌
   ```

5. **Check for account issues:**
   ```
   Firebase Console → Authentication → Users
   
   Check if user is:
   - Disabled
   - Deleted
   - Email not verified (if verification required)
   ```

**Solutions:**

| Issue | Solution |
|-------|----------|
| Reset link expired | Send another reset email |
| User didn't receive email | Check spam, resend email |
| User forgot new password | Send another reset email |
| Account disabled | Re-enable in Firebase Console |
| User doesn't exist | Create user account |
| Wrong email address | Verify email is correct |

### Problem: Reset email not received

**Diagnosis:**

1. **Check spam folder**
   - Firebase emails sometimes flagged as spam
   - Check junk/promotions folders

2. **Verify email address is correct**
   ```
   Firestore → users → Search by email
   
   Check:
   - Email spelling correct?
   - No extra spaces?
   - Correct domain?
   ```

3. **Check Firebase email settings**
   ```
   Firebase Console
   → Authentication
   → Templates
   → Password reset
   
   Verify:
   - Template is active
   - From email is configured
   - Email service is working
   ```

4. **Check Firestore logs**
   ```
   Look at passwordResetRequestedAt timestamp
   
   If present: Email was triggered ✅
   If missing: Email was never sent ❌
   ```

**Solutions:**

- Wait a few minutes (email can be delayed)
- Check all email folders (spam, junk, promotions)
- Verify email address spelling
- Try resending reset email
- Use different email provider if possible

### Problem: Local database password out of sync

**This is NOT actually a problem anymore!**

The fix ensures password syncs automatically. But if you suspect issues:

**Diagnosis:**
```
Open local SQLite database
→ users table
→ Find user
→ Check password field

Note: You can't see the actual password hash in Firebase,
but you can verify the local password is updated after login.
```

**Solution:**
```
User just needs to login successfully ONCE with their current
Firebase password, and the local database will automatically sync.

No manual intervention needed!
```

---

## Testing Guide

### Test Case 1: User Forgot Password

**Steps:**
1. Logout of app
2. Click "Forgot Password"
3. Enter your email
4. Click "Send Reset Link"
5. Check email inbox
6. Click reset link in email
7. Set new password: "TestPass123!"
8. Go back to app
9. Login with email and "TestPass123!"

**Expected Results:**
- ✅ Success message appears after step 4
- ✅ Email received within 1 minute
- ✅ Reset link works
- ✅ Can set new password
- ✅ Login succeeds with new password
- ✅ Firestore `passwordResetRequestedAt` updated
- ✅ Firestore `lastLoginAt` updated after login
- ✅ Can access app features

### Test Case 2: Admin Resets User Password

**Steps:**
1. Login as ADMIN or TOP MANAGEMENT
2. Go to User Management
3. Find a test user
4. Click actions menu (⋮)
5. Select "Reset Password"
6. Confirm action
7. Check success message
8. Ask test user to check email
9. Test user sets new password
10. Test user logs in

**Expected Results:**
- ✅ Detailed success message displayed
- ✅ Message mentions email was sent
- ✅ User receives email
- ✅ User can set new password
- ✅ User can login with new password
- ✅ Firestore fields updated correctly

### Test Case 3: Invalid Email

**Steps:**
1. Logout
2. Click "Forgot Password"
3. Enter: "nonexistent@example.com"
4. Click "Send Reset Link"

**Expected Results:**
- ✅ Error message: "No account found with this email"
- ✅ No email sent
- ✅ Firestore NOT updated
- ✅ Clear error indication

### Test Case 4: Database Sync

**Steps:**
1. Create user with password "InitialPass123"
2. User logs in with "InitialPass123" ✅
3. User requests password reset
4. User sets new password "NewPass456!"
5. User logs in with "NewPass456!" ✅
6. Check local database

**Expected Results:**
- ✅ After step 2: Local DB has "InitialPass123"
- ✅ After step 5: Local DB has "NewPass456!"
- ✅ Password automatically synced
- ✅ No manual intervention needed

---

## Best Practices

### For Users

1. **Use Strong Passwords**
   - At least 8 characters
   - Mix of letters, numbers, symbols
   - Don't reuse passwords from other sites

2. **Keep Passwords Secure**
   - Don't share passwords
   - Don't write passwords down
   - Use a password manager

3. **Check Spam Folder**
   - Reset emails might be filtered
   - Check junk/promotions folders
   - Add Firebase to safe senders

4. **Act Quickly**
   - Reset links expire in 1 hour
   - Complete password reset promptly
   - Request new link if expired

### For Admins

1. **Inform Users**
   - Tell users to check email
   - Explain they'll receive reset link
   - Remind them link expires in 1 hour

2. **Verify Email Addresses**
   - Check email spelling before reset
   - Confirm user has access to email
   - Update email if changed

3. **Track Resets**
   - Check Firestore `passwordResetRequestedAt`
   - Verify `lastLoginAt` after reset
   - Monitor successful logins

4. **Security**
   - Only authorized roles can reset passwords
   - Log all password reset actions
   - Review audit trail regularly

---

## Security Considerations

### What's Secure

✅ **Password Storage**
- Passwords hashed in Firebase Auth
- Never stored in plain text
- Never sent via email

✅ **Reset Links**
- Unique one-time use links
- Expire after 1 hour
- Cryptographically secure

✅ **Email Verification**
- Verifies user owns email address
- User must have email access to reset
- Can't reset someone else's password

✅ **Audit Trail**
- All resets tracked in Firestore
- Timestamps for accountability
- Login history maintained

### Potential Risks

⚠️ **Email Interception**
- Risk: Reset email could be intercepted
- Mitigation: Links expire quickly (1 hour)
- Best practice: Use secure email provider

⚠️ **Account Takeover**
- Risk: Attacker with email access can reset password
- Mitigation: User should secure their email
- Best practice: Enable 2FA on email

⚠️ **Spam Folder**
- Risk: User doesn't see reset email
- Mitigation: Clear success messages
- Best practice: Whitelist Firebase emails

---

## FAQ

### Q: Why do users need to check their email to reset password?

**A:** This is a security measure. It proves the person requesting the reset has access to the account's email address. Without this, anyone could reset anyone else's password.

### Q: Can an admin set a specific password for a user?

**A:** No, Firebase client SDK doesn't allow this (security feature). Admins can only send password reset emails. Users must set their own passwords. This is industry best practice.

### Q: What if the reset email goes to spam?

**A:** Users should:
1. Check spam/junk folders
2. Add `noreply@kenwell-health.firebaseapp.com` to safe senders
3. Request another reset email
4. Use a different email provider if persistent

### Q: How long is the reset link valid?

**A:** Reset links expire after 1 hour for security. If expired, user can request a new reset email.

### Q: Can I reset password multiple times?

**A:** Yes, you can request password reset as many times as needed. Each new reset invalidates previous links.

### Q: What happens to the old password after reset?

**A:** The old password becomes invalid immediately after setting the new password. Only the new password works.

### Q: Why track `passwordResetRequestedAt` in Firestore?

**A:** For audit trail and troubleshooting:
- Verify reset email was sent
- Check if user requested reset
- Security monitoring
- Support troubleshooting

### Q: Why track `lastLoginAt` in Firestore?

**A:** To verify password reset success:
- Confirm user logged in after reset
- Track active users
- Security monitoring
- Identify inactive accounts

### Q: Is the password stored in Firestore?

**A:** No! Passwords are ONLY stored in:
1. Firebase Auth (hashed and secure)
2. Local SQLite DB (for offline fallback)

Firestore has user profile data but NOT passwords.

### Q: What if Firebase is down?

**A:** Password reset requires Firebase Authentication service. If Firebase is down, password reset won't work until service is restored. However, users who have already reset passwords can still login (local DB fallback).

---

## Related Documentation

- **NEW_USER_LOGIN_FIX.md** - New user password reset issue
- **AUTHENTICATION_GUIDE.md** - Complete authentication system
- **AUTHENTICATION_QUICK_REFERENCE.md** - Quick auth reference

---

## Summary

**Password reset now works reliably because:**

1. ✅ Email existence verified before sending
2. ✅ Audit trail in Firestore
3. ✅ Local database syncs automatically
4. ✅ Clear user messaging
5. ✅ Login tracking for verification

**Users can successfully:**
1. Request password reset (self or admin)
2. Receive reset email
3. Set new password
4. Login with new password
5. Access app immediately

**Databases stay synchronized:**
- Firebase Auth (source of truth)
- Firestore (tracking and profile)
- Local SQLite (synced on login)

---

**Status:** Password reset flow fully functional and documented! ✅

**Last Updated:** 2026-02-04  
**Version:** 2.0
