# Firebase Configuration Checklist

This checklist will guide you through setting up Firebase for the Kenwell Health App.

## Prerequisites ✓

Before you begin, ensure you have:
- [ ] Flutter SDK installed and working
- [ ] A Google account
- [ ] Node.js installed (for Firebase CLI)
- [ ] Terminal/command line access

## Step 1: Install Required Tools

### Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Verify Installation
```bash
firebase --version
flutterfire --version
```

## Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: **kenwell-health-app** (or your preferred name)
4. Enable/Disable Google Analytics (optional but recommended)
5. Click **"Create project"**
6. Wait for project creation to complete

## Step 3: Configure Firebase for Flutter

### Login to Firebase
```bash
firebase login
```
- Follow the browser prompts to authenticate

### Configure FlutterFire
```bash
cd /path/to/kenwell_health_app
flutterfire configure
```

Follow the prompts:
1. Select your Firebase project from the list
2. Select platforms to support:
   - [x] Android
   - [x] iOS
   - [x] Web
   - [x] macOS (optional)
3. Wait for configuration to complete

**This will automatically:**
- Update `lib/firebase_options.dart` with your actual Firebase configuration
- Add necessary configuration files for each platform
- Link your app to your Firebase project

## Step 4: Enable Firebase Authentication

1. In [Firebase Console](https://console.firebase.google.com/), select your project
2. Go to **Build** → **Authentication**
3. Click **"Get started"**
4. Click on **"Sign-in method"** tab
5. Find **"Email/Password"** provider
6. Click the **Edit** icon (pencil)
7. Toggle **Enable** switch to ON
8. Click **"Save"**

### Optional: Enable Email Verification
1. In the same Authentication section
2. Go to **"Settings"** tab (top of page)
3. Scroll to **"User actions"**
4. Enable **"Email enumeration protection"** (recommended for security)

## Step 5: Create Firestore Database

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **"Create database"**
3. Select starting mode:
   - **Production mode** (recommended) - Start with secure rules
   - **Test mode** - Open for 30 days (for development only)
4. Choose a location close to your users (e.g., `us-central`, `europe-west`, etc.)
5. Click **"Enable"**

### Configure Security Rules

After database creation:

1. In Firestore Database, click **"Rules"** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isAuthenticated();
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // Events collection - authenticated users can read all, write their own
    match /events/{eventId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated();
      allow delete: if isAuthenticated();
    }
    
    // Admin-only access (optional - update with your admin logic)
    // match /admin/{document=**} {
    //   allow read, write: if isAuthenticated() && 
    //     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    // }
  }
}
```

3. Click **"Publish"**

## Step 6: Platform-Specific Configuration

### Android

The `flutterfire configure` command should have created:
- `android/app/google-services.json`

Verify this file exists and contains your project configuration.

### iOS

The `flutterfire configure` command should have created:
- `ios/Runner/GoogleService-Info.plist`

Verify this file exists and is added to Xcode project.

### Web

Configuration should be in `lib/firebase_options.dart` automatically.

## Step 7: Build and Test

### Clean and Get Dependencies
```bash
flutter clean
flutter pub get
```

### Run on Your Platform

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d chrome
```

## Step 8: Test Authentication Flow

### Test Registration
1. Launch the app
2. Navigate to Register screen
3. Fill in all fields:
   - First Name
   - Last Name
   - Role (select from dropdown)
   - Phone Number
   - Email
   - Password
   - Confirm Password
4. Click **"Register"**
5. **Verify in Firebase Console:**
   - Go to Authentication → Users
   - You should see the new user
   - Go to Firestore → users collection
   - You should see user document with profile data

### Test Login
1. After registration, go to Login screen
2. Enter email and password
3. Click **"Login"**
4. Should navigate to main app screen

### Test Password Reset
1. Go to Login screen
2. Click **"Forgot Password?"**
3. Enter registered email
4. Click **"Send Reset Link"**
5. **Check email inbox** for password reset link
6. Click link and reset password
7. Login with new password

### Test Profile Update
1. Login to the app
2. Navigate to Profile screen
3. Update any field
4. Save changes
5. **Verify in Firestore Console** that data updated

## Step 9: Monitor and Debug

### View Authentication Events
1. Firebase Console → Authentication → Users
2. See all registered users, when they signed up, last sign-in

### View Firestore Data
1. Firebase Console → Firestore Database
2. Browse collections and documents
3. Manually add/edit/delete data if needed

### Check Logs
Enable debug logging in your IDE:
- Look for `debugPrint` messages
- Check for Firebase errors
- Monitor network requests

### Common Issues

**"MissingPluginException"**
```bash
flutter clean
flutter pub get
# Restart your IDE
# Rebuild the app completely
```

**"Firebase not initialized"**
- Verify `firebase_options.dart` has actual values (not template)
- Check `main.dart` calls `Firebase.initializeApp()`
- Ensure it's before `runApp()`

**"Permission denied" in Firestore**
- Check Firestore rules
- Ensure user is logged in
- Verify UID matches document path
- Check Firebase Console for rule errors

**Email not sending**
- Check spam folder
- Verify email in Authentication settings
- Check quota limits in Firebase Console

## Step 10: Production Checklist

Before deploying to production:

- [ ] Update app display name in `pubspec.yaml`
- [ ] Update bundle ID/package name
- [ ] Configure email templates in Firebase Console
- [ ] Enable email verification (optional)
- [ ] Set up monitoring and analytics
- [ ] Review and tighten security rules
- [ ] Set up Cloud Functions if needed
- [ ] Configure custom domain for auth (optional)
- [ ] Set up backup strategy for Firestore
- [ ] Test on physical devices
- [ ] Load test with multiple users
- [ ] Review Firebase quotas and upgrade plan if needed

## Additional Features to Consider

### Email Verification
```dart
// After registration, send verification email
await FirebaseAuth.instance.currentUser?.sendEmailVerification();
```

### Phone Authentication
- Enable in Firebase Console → Authentication → Sign-in method
- Add phone number field to registration
- Implement SMS verification flow

### Social Sign-In
- Enable Google, Facebook, or Apple sign-in
- Configure OAuth credentials
- Update UI to include social login buttons

### Multi-Factor Authentication
- Enable in Firebase Console
- Implement second factor (SMS, TOTP)
- Enhance security for sensitive accounts

## Support and Resources

- **Firebase Documentation**: https://firebase.google.com/docs
- **FlutterFire Documentation**: https://firebase.flutter.dev/
- **Firebase Console**: https://console.firebase.google.com/
- **Community Support**: https://firebase.google.com/support
- **Stack Overflow**: Tag your questions with `firebase` and `flutter`

## Files Reference

- `FIREBASE_SETUP.md` - Detailed setup guide
- `FIREBASE_IMPLEMENTATION_SUMMARY.md` - Technical implementation details
- `lib/firebase_options.dart` - Firebase configuration (auto-generated)
- `lib/data/services/firebase_auth_service.dart` - Authentication service
- `lib/data/services/firestore_service.dart` - Firestore operations

## Completion Checklist

- [ ] Firebase CLI installed
- [ ] FlutterFire CLI installed
- [ ] Firebase project created
- [ ] `flutterfire configure` run successfully
- [ ] Email/Password authentication enabled
- [ ] Firestore database created
- [ ] Security rules configured
- [ ] App builds without errors
- [ ] Registration tested and working
- [ ] Login tested and working
- [ ] Password reset tested
- [ ] Profile update tested
- [ ] Data visible in Firebase Console
- [ ] All platform configurations verified

---

**Congratulations! 🎉**

Your Kenwell Health App is now configured with Firebase Authentication and Firestore!

If you encounter any issues, refer to the troubleshooting section or check the Firebase Console for error messages.
