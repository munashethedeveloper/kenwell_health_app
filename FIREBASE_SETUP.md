# Firebase Setup Guide for Kenwell Health App

This guide explains how to set up Firebase Authentication and Firestore for the Kenwell Health App.

## Prerequisites

- Flutter SDK installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
- A Firebase project created at [Firebase Console](https://console.firebase.google.com/)

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Give your project a name (e.g., "kenwell-health-app")
4. Enable Google Analytics (optional)
5. Create the project

## Step 2: Enable Firebase Authentication

1. In the Firebase Console, go to **Build** > **Authentication**
2. Click "Get started"
3. Under "Sign-in method" tab, enable **Email/Password** authentication
4. Click "Enable" and save

## Step 3: Enable Cloud Firestore

1. In the Firebase Console, go to **Build** > **Firestore Database**
2. Click "Create database"
3. Choose "Start in production mode" (recommended) or "Start in test mode" (for development)
4. Select a Cloud Firestore location close to your users
5. Click "Enable"

### Firestore Security Rules

Update your Firestore security rules to allow authenticated users to read and write their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Events - authenticated users can read all, but only write their own
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 4: Configure Firebase for Flutter

### Option 1: Using FlutterFire CLI (Recommended)

1. Login to Firebase:
   ```bash
   firebase login
   ```

2. Run the FlutterFire configuration command from your project root:
   ```bash
   flutterfire configure
   ```

3. Select your Firebase project from the list
4. Select the platforms you want to support (Android, iOS, Web, macOS)
5. The CLI will automatically generate `lib/firebase_options.dart` with your configuration

### Option 2: Manual Configuration

If you prefer to configure manually, update the `lib/firebase_options.dart` file with your Firebase project credentials:

#### For Android:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory

#### For iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory

#### For Web:
Add the Firebase configuration to `web/index.html`

## Step 5: Firestore Database Structure

The app uses the following collections:

### `users` Collection
```
users/{userId}
  - id: string
  - email: string
  - role: string
  - firstName: string
  - lastName: string
  - phoneNumber: string
```

### `events` Collection
```
events/{eventId}
  - id: string
  - title: string
  - date: timestamp
  - venue: string
  - address: string
  - townCity: string
  - province: string
  - ... (additional event fields)
```

## Step 6: Run the App

1. Ensure all dependencies are installed:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Features Implemented

### Firebase Authentication
- ✅ Email/Password registration
- ✅ Email/Password login
- ✅ Logout functionality
- ✅ User session management
- ✅ User data stored in Firestore

### Cloud Firestore
- ✅ User profile storage
- ✅ CRUD operations for documents
- ✅ Real-time data synchronization
- ✅ Query capabilities
- ✅ Batch operations support

## Architecture

### Services
- **FirebaseAuthService** (`lib/data/services/firebase_auth_service.dart`)
  - Handles user authentication (login, register, logout)
  - Manages user sessions
  - Stores user profiles in Firestore

- **FirestoreService** (`lib/data/services/firestore_service.dart`)
  - Generic Firestore CRUD operations
  - Real-time data streaming
  - Query and batch operations

### Repository
- **AuthRepository** (`lib/data/repositories_dcl/auth_repository_dcl.dart`)
  - Abstraction layer between UI and Firebase services
  - Used by ViewModels

### View Models
- **AuthViewModel** (`lib/ui/features/auth/view_models/auth_view_model.dart`)
  - Manages authentication state
  - Used across the app for auth status

- **LoginViewModel** (`lib/ui/features/auth/view_models/login_view_model.dart`)
  - Handles login screen logic

## Testing

To test the Firebase integration:

1. **Registration Flow:**
   - Open the app and navigate to the Register screen
   - Fill in all required fields
   - Submit the form
   - Check Firebase Console > Authentication to see the new user
   - Check Firebase Console > Firestore to see the user document

2. **Login Flow:**
   - Use the credentials you registered with
   - Login should redirect to the main navigation screen
   - Check that the user session is maintained

3. **Logout Flow:**
   - Use the logout button in the app
   - Should redirect back to login screen
   - Session should be cleared

## Troubleshooting

### Common Issues

1. **"Firebase not initialized" error:**
   - Ensure `Firebase.initializeApp()` is called in `main.dart` before `runApp()`
   - Check that `firebase_options.dart` has valid configuration

2. **Authentication fails silently:**
   - Check Firebase Console > Authentication is enabled
   - Verify Email/Password sign-in method is enabled
   - Check for error messages in the console

3. **Firestore permission denied:**
   - Verify Firestore security rules allow the operation
   - Ensure user is authenticated before accessing Firestore
   - Check that the user ID matches the document being accessed

4. **Missing google-services.json or GoogleService-Info.plist:**
   - Download from Firebase Console
   - Place in correct directory (see Step 4)
   - Run `flutter clean` and rebuild

## Security Best Practices

1. **Never commit Firebase configuration files with real credentials to public repositories**
2. Use environment variables for sensitive data
3. Implement proper Firestore security rules
4. Validate all user input before storing in Firestore
5. Use Firebase Authentication tokens for API calls
6. Regularly review Firebase Console > Authentication > Users for suspicious activity

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

## Support

For issues or questions:
1. Check the Firebase Console for error logs
2. Review the app logs for detailed error messages
3. Consult the FlutterFire documentation
4. Check Firebase Status page for any service outages
