# Authentication System Guide - Kenwell Health App

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Authentication Flow](#authentication-flow)
4. [Components Explained](#components-explained)
5. [Complete Login Process](#complete-login-process)
6. [Session Management](#session-management)
7. [Route Protection](#route-protection)
8. [User Registration](#user-registration)
9. [Password Reset & Email Verification](#password-reset--email-verification)
10. [Code Examples](#code-examples)
11. [Troubleshooting](#troubleshooting)

---

## Overview

The Kenwell Health App uses a **multi-layered authentication system** with Firebase as the primary authentication provider and a local database as a fallback. The system includes:

- ✅ **Firebase Authentication** - Primary auth provider
- ✅ **Local Database Fallback** - Works when Firebase is unavailable
- ✅ **Session Persistence** - User stays logged in across app restarts
- ✅ **Role-Based Access Control** - Different permissions for different user roles
- ✅ **Route Protection** - GoRouter redirects based on auth status
- ✅ **Email Verification** - Email verification tracking
- ✅ **Profile Loading** - User data loaded from Firestore

---

## Architecture

The authentication system follows a **clean architecture pattern** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  ┌────────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │ LoginScreen    │  │ AuthViewModel│  │ ProfileViewModel│ │
│  │ (Widgets)      │  │ (State Mgmt) │  │ (User Data)     │ │
│  └────────────────┘  └──────────────┘  └─────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   ViewModel Layer                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ LoginViewModel - Handles login form state & navigation│ │
│  │ AuthViewModel  - Tracks global auth state             │ │
│  └────────────────────────────────────────────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                  Repository Layer                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ AuthRepository - Coordinates between services          │ │
│  │  - Tries Firebase first                               │ │
│  │  - Falls back to local database                       │ │
│  └────────────────────────────────────────────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    Service Layer                             │
│  ┌──────────────────────┐  ┌──────────────────────────────┐│
│  │FirebaseAuthService   │  │ AuthService (Local DB)       ││
│  │ - Firebase Auth      │  │ - SharedPreferences          ││
│  │ - Firestore          │  │ - Local fallback             ││
│  └──────────────────────┘  └──────────────────────────────┘│
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   External Services                          │
│  ┌──────────────────────┐  ┌──────────────────────────────┐│
│  │ Firebase Auth        │  │ Firestore Database           ││
│  │ (Google)             │  │ (User profiles)              ││
│  └──────────────────────┘  └──────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Authentication Flow

### High-Level Flow Diagram

```
┌──────────────┐
│ App Launches │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ main.dart initializes│
│ - Firebase           │
│ - Providers          │
│ - GoRouter           │
└──────┬───────────────┘
       │
       ▼
┌─────────────────────────────┐
│ GoRouter checks auth status │
│ initialLocation: '/login'   │
└──────┬──────────────────────┘
       │
       ▼
┌────────────────────────────┐
│ AuthViewModel checks       │
│ _auth.currentUser != null │
└──────┬─────────────────────┘
       │
       ├─── Not Logged In ───┐
       │                     │
       │                     ▼
       │              ┌──────────────┐
       │              │ Show Login   │
       │              │ Screen       │
       │              └──────┬───────┘
       │                     │
       │                     ▼
       │              ┌──────────────────┐
       │              │ User enters      │
       │              │ email & password │
       │              └──────┬───────────┘
       │                     │
       │                     ▼
       │              ┌──────────────────────┐
       │              │ LoginViewModel.login │
       │              │ ↓                    │
       │              │ AuthRepository.login │
       │              │ ↓                    │
       │              │ FirebaseAuthService  │
       │              │   .login()           │
       │              └──────┬───────────────┘
       │                     │
       │              ┌──────┴───────┐
       │              │              │
       │         Success          Fail
       │              │              │
       │              ▼              ▼
       │       ┌──────────────┐  ┌────────────┐
       │       │ User object  │  │ Try local  │
       │       │ returned     │  │ database   │
       │       └──────┬───────┘  └────────────┘
       │              │
       │              ▼
       │       ┌──────────────────┐
       │       │ Load Profile     │
       │       │ - ProfileViewModel│
       │       │ - Get role, name │
       │       └──────┬───────────┘
       │              │
       │              ▼
       │       ┌──────────────────┐
       │       │ Navigate to '/'  │
       │       │ (Main Screen)    │
       │       └──────────────────┘
       │
       └─── Already Logged In ──┐
                                │
                                ▼
                         ┌──────────────┐
                         │ Redirect to  │
                         │ '/' (Main)   │
                         └──────────────┘
```

---

## Components Explained

### 1. FirebaseAuthService
**Location:** `lib/data/services/firebase_auth_service.dart`

**Purpose:** Handles all Firebase Authentication operations.

**Key Methods:**
- `login(email, password)` - Authenticate with Firebase
- `register(...)` - Create new user account
- `logout()` - Sign out user
- `currentUser()` - Get currently logged-in user
- `isLoggedIn()` - Check if user is logged in
- `sendPasswordResetEmail(email)` - Send password reset email
- `sendEmailVerification()` - Send email verification
- `updateUserProfile(...)` - Update user information

**Important Features:**
- Uses Firebase Auth for authentication
- Stores user data in Firestore (`users` collection)
- Syncs email verification status
- Uses secondary Firebase app for registration (prevents admin logout)

### 2. AuthRepository
**Location:** `lib/data/repositories_dcl/auth_repository_dcl.dart`

**Purpose:** Coordinates between Firebase and local database services.

**Strategy:**
1. **Try Firebase first** - Primary authentication method
2. **Fallback to local** - If Firebase fails or unavailable
3. **Unified interface** - ViewModels don't need to know which service is used

**Key Methods:**
```dart
Future<UserModel?> login(String email, String password) async {
  // Try Firebase
  try {
    final firebaseUser = await _firebaseAuthService.login(email, password);
    if (firebaseUser != null) return firebaseUser;
  } catch (e) {
    AppLogger.error('Firebase login failed', e);
  }
  
  // Fallback to local
  try {
    final localUser = await _localAuthService.login(email, password);
    return localUser;
  } catch (e) {
    AppLogger.error('Local login failed', e);
    return null;
  }
}
```

### 3. AuthViewModel
**Location:** `lib/ui/features/auth/view_models/auth_view_model.dart`

**Purpose:** Manages global authentication state for the entire app.

**State:**
- `isLoggedIn: bool` - Whether user is currently authenticated
- `isLoading: bool` - Whether auth check is in progress

**Usage:**
- Created as a global provider in `main.dart`
- GoRouter checks `AuthViewModel.isLoggedIn` for route protection
- Automatically checks login status on initialization

**Lifecycle:**
```dart
// App starts
AuthViewModel created
  ↓
_checkLoginStatus() called
  ↓
_authService.isLoggedIn() // Checks Firebase currentUser
  ↓
_isLoggedIn = result
  ↓
notifyListeners() // UI rebuilds
```

### 4. LoginViewModel
**Location:** `lib/ui/features/auth/view_models/login_view_model.dart`

**Purpose:** Manages the login screen's state and form handling.

**State:**
- `isLoading: bool` - Login in progress
- `errorMessage: String?` - Error to display to user
- `navigationTarget: LoginNavigationTarget?` - Where to navigate after login

**Flow:**
```dart
User taps "Login" button
  ↓
LoginViewModel.login(email, password)
  ↓
AuthRepository.login(email, password)
  ↓
Success: Set navigationTarget = mainNavigation
Failure: Set errorMessage
  ↓
notifyListeners()
  ↓
UI reacts:
  - If navigationTarget → Navigate
  - If errorMessage → Show error
```

### 5. ProfileViewModel
**Location:** `lib/ui/features/profile/view_model/profile_view_model.dart`

**Purpose:** Manages user profile data including role.

**Why It's Important:**
- Role-based permissions need the user's role
- GoRouter redirect logic checks permissions
- Must be loaded BEFORE navigation after login

**Loaded After Login:**
```dart
// In login_screen.dart
final profileVM = context.read<ProfileViewModel>();
await profileVM.loadProfile(); // Loads role, name, etc.
```

---

## Complete Login Process

Let's walk through what happens when a user logs in:

### Step-by-Step Login Flow

#### 1. User Opens App
```dart
// main.dart
void main() async {
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}
```

#### 2. App Initializes Providers
```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<AuthViewModel>(
      create: (_) => AuthViewModel(), // ← Checks login status
    ),
    ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(),
    ),
    // ... other providers
  ],
)
```

#### 3. GoRouter Checks Authentication
```dart
// go_router_config.dart
redirect: (context, state) {
  final isAuthenticated = _isAuthenticated(context); // ← Checks AuthViewModel
  
  if (!isAuthenticated && !isPublicRoute) {
    return '/login'; // ← Redirect to login
  }
  
  return null; // Allow navigation
}
```

#### 4. User Sees Login Screen
```dart
// login_screen.dart
LoginScreen()
  ↓
Creates LoginViewModel
  ↓
Displays email/password form
```

#### 5. User Enters Credentials & Taps Login
```dart
// login_screen.dart - _handleLogin()
void _handleLogin() {
  if (!_formKey.currentState!.validate()) return;
  
  viewModel.login(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );
}
```

#### 6. LoginViewModel Processes Login
```dart
// login_view_model.dart
Future<void> login(String email, String password) async {
  _isLoading = true; // Show loading spinner
  notifyListeners();
  
  final user = await _repository.login(email, password);
  
  if (user != null) {
    _navigationTarget = LoginNavigationTarget.mainNavigation;
  } else {
    _errorMessage = 'Invalid email or password';
  }
  
  _isLoading = false;
  notifyListeners(); // UI updates
}
```

#### 7. AuthRepository Tries Firebase
```dart
// auth_repository_dcl.dart
Future<UserModel?> login(String email, String password) async {
  // Try Firebase
  try {
    final firebaseUser = await _firebaseAuthService.login(email, password);
    if (firebaseUser != null) {
      return firebaseUser; // ← Success!
    }
  } catch (e) {
    // Log error, try local database
  }
  
  // Fallback to local
  return await _localAuthService.login(email, password);
}
```

#### 8. FirebaseAuthService Authenticates
```dart
// firebase_auth_service.dart
Future<UserModel?> login(String email, String password) async {
  // 1. Sign in with Firebase Auth
  final userCredential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  final user = userCredential.user;
  if (user == null) return null;
  
  // 2. Reload to get latest verification status
  await user.reload();
  final emailVerified = _auth.currentUser?.emailVerified ?? false;
  
  // 3. Fetch user data from Firestore
  final doc = await _firestore.collection('users').doc(user.uid).get();
  
  // 4. Update Firestore with latest verification status
  await _firestore.collection('users').doc(user.uid).update({
    'emailVerified': emailVerified,
  });
  
  // 5. Return UserModel
  final userData = Map<String, dynamic>.from(doc.data()!);
  userData['emailVerified'] = emailVerified;
  
  return UserModel.fromMap(userData);
}
```

#### 9. UI Receives Success Response
```dart
// login_screen.dart - Consumer<LoginViewModel>
if (viewModel.navigationTarget != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // IMPORTANT: Load profile before navigation
    final profileVM = context.read<ProfileViewModel>();
    await profileVM.loadProfile(); // ← Loads user role
    
    // Update auth status
    final authVM = context.read<AuthViewModel>();
    await authVM.checkLoginStatus();
    
    // Navigate to main screen
    context.go('/');
  });
}
```

#### 10. GoRouter Allows Navigation
```dart
// go_router_config.dart - redirect
redirect: (context, state) {
  final isAuthenticated = _isAuthenticated(context); // ← Now returns true
  
  if (isAuthenticated && isPublicRoute) {
    return '/'; // ← Redirect to main screen
  }
  
  // Check role-based permissions
  final userRole = _getUserRole(context); // ← Now has role from ProfileViewModel
  if (!_canAccessRoute(context, currentPath)) {
    return '/';
  }
  
  return null; // ← Allow navigation to main screen
}
```

#### 11. User Lands on Main Screen
```
LoginScreen → Main Navigation Screen → Calendar Tab
```

---

## Session Management

### How Sessions Persist

Firebase Authentication **automatically persists sessions**:

```dart
// Firebase Auth maintains session state
final user = FirebaseAuth.instance.currentUser;
// ↑ This stays non-null across app restarts
```

**Session Storage:**
- Firebase Auth stores session tokens locally
- Platform-specific storage:
  - **iOS:** Keychain
  - **Android:** SharedPreferences (encrypted)
  - **Web:** Local Storage

**Session Lifecycle:**

```
App Install
  ↓
First Login
  ↓
Firebase stores auth token
  ↓
App Restart
  ↓
AuthViewModel._checkLoginStatus()
  ↓
_authService.isLoggedIn()
  ↓
FirebaseAuth.instance.currentUser != null ✅
  ↓
User stays logged in
```

**Session Expiration:**
- Firebase refresh tokens are valid for **1 hour**
- Firebase automatically refreshes tokens in the background
- User stays logged in indefinitely unless they:
  - Explicitly logout
  - Clear app data
  - Uninstall app

---

## Route Protection

### GoRouter Redirect Logic

The app uses GoRouter's `redirect` callback for authentication guards:

```dart
// go_router_config.dart
redirect: (BuildContext context, GoRouterState state) {
  final isAuthenticated = _isAuthenticated(context);
  final currentPath = state.uri.path;
  
  // Public routes (no auth required)
  final publicRoutes = ['/login', '/forgot-password'];
  final isPublicRoute = publicRoutes.contains(currentPath);
  
  // Rule 1: Not authenticated + Protected route → Login
  if (!isAuthenticated && !isPublicRoute) {
    return '/login';
  }
  
  // Rule 2: Authenticated + Public route → Main
  if (isAuthenticated && isPublicRoute) {
    return '/';
  }
  
  // Rule 3: Authenticated + Protected route → Check permissions
  if (isAuthenticated && !isPublicRoute) {
    if (!_canAccessRoute(context, currentPath)) {
      return '/'; // No permission → Home
    }
  }
  
  // Rule 4: Allow navigation
  return null;
}
```

### Authentication Check

```dart
static bool _isAuthenticated(BuildContext context) {
  try {
    final authVM = context.read<AuthViewModel>();
    return authVM.isLoggedIn; // ← Checks Firebase currentUser
  } catch (e) {
    return false; // Fail closed
  }
}
```

### Role-Based Access Control

```dart
static bool _canAccessRoute(BuildContext context, String path) {
  final userRole = _getUserRole(context);
  return RolePermissions.canAccessRoute(userRole, path);
}

static String? _getUserRole(BuildContext context) {
  try {
    final profileVM = context.read<ProfileViewModel>();
    return profileVM.role; // ← From Firestore
  } catch (e) {
    return null;
  }
}
```

**Permission Flow:**

```
User navigates to /user-management
  ↓
GoRouter redirect() called
  ↓
Check: isAuthenticated? → Yes ✅
  ↓
Check: isPublicRoute? → No
  ↓
Check: _canAccessRoute()
  ↓
Get userRole from ProfileViewModel → "ADMIN"
  ↓
RolePermissions.canAccessRoute("ADMIN", "/user-management")
  ↓
Check: routeAccess["/user-management"] includes "ADMIN"? → Yes ✅
  ↓
return null → Allow navigation
```

---

## User Registration

### Registration Flow

```
Admin/Manager navigates to User Management
  ↓
Clicks "Create User" tab
  ↓
Fills registration form:
  - Email
  - Password
  - First Name
  - Last Name
  - Phone Number
  - Role (dropdown)
  ↓
Submits form
  ↓
UserManagementViewModel.createUser()
  ↓
AuthRepository.register()
  ↓
FirebaseAuthService.register()
  ↓
Creates SECONDARY Firebase app
  ↓
Creates user in Firebase Auth
  ↓
Sends email verification
  ↓
Saves user data to Firestore
  ↓
Signs out from secondary app
  ↓
Admin stays logged in ✅
```

### Why Secondary Firebase App?

```dart
// firebase_auth_service.dart - register()
// Problem: createUserWithEmailAndPassword() auto-signs in the new user
// This would log out the admin who's creating the user!

// Solution: Use a secondary Firebase app instance
secondaryApp = await Firebase.initializeApp(
  name: 'userRegistration', // ← Different app instance
  options: DefaultFirebaseOptions.currentPlatform,
);

secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

// Create user with secondary auth (doesn't affect primary session)
await secondaryAuth.createUserWithEmailAndPassword(...);

// Sign out from secondary app
await secondaryAuth.signOut(); // ← Admin stays logged in on primary app
```

**Benefits:**
- ✅ Admin stays logged in while creating users
- ✅ New user account created successfully
- ✅ Email verification sent to new user
- ✅ No session conflicts

---

## Password Reset & Email Verification

### Password Reset Flow

```
User clicks "Forgot Password?"
  ↓
Navigates to /forgot-password
  ↓
Enters email address
  ↓
Taps "Send Reset Link"
  ↓
ForgotPasswordViewModel.sendPasswordReset()
  ↓
FirebaseAuthService.sendPasswordResetEmail()
  ↓
Firebase sends email with reset link
  ↓
User clicks link in email
  ↓
Firebase hosted reset password page
  ↓
User sets new password
  ↓
User can log in with new password
```

**Code:**
```dart
// firebase_auth_service.dart
Future<bool> sendPasswordResetEmail(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email.trim());
    return true;
  } catch (e) {
    debugPrint('Password reset error: $e');
    return false;
  }
}
```

### Email Verification

**When Sent:**
- Automatically during user registration
- Can be resent manually

**Tracking:**
```dart
// User model includes emailVerified field
class UserModel {
  final bool emailVerified; // ← Synced from Firebase Auth
}

// Synced during login
await user.reload(); // Get latest status from Firebase
final emailVerified = user.emailVerified;

// Updated in Firestore
await _firestore.collection('users').doc(user.uid).update({
  'emailVerified': emailVerified,
});
```

**Manual Sync:**
```dart
// User can trigger verification status sync
await FirebaseAuthService().syncCurrentUserEmailVerification();
```

---

## Code Examples

### Example 1: Checking If User Is Logged In

```dart
// From anywhere in the app
final authVM = context.read<AuthViewModel>();
if (authVM.isLoggedIn) {
  // User is authenticated
  print('User is logged in');
} else {
  // User is not authenticated
  print('User is logged out');
}
```

### Example 2: Getting Current User Data

```dart
// Get current user profile
final profileVM = context.read<ProfileViewModel>();
await profileVM.loadProfile();

print('User ID: ${profileVM.userId}');
print('Email: ${profileVM.email}');
print('Role: ${profileVM.role}');
print('Name: ${profileVM.firstName} ${profileVM.lastName}');
```

### Example 3: Manual Login Programmatically

```dart
// Login from code
final authRepo = AuthRepository();
final user = await authRepo.login('email@example.com', 'password');

if (user != null) {
  print('Login successful: ${user.email}');
  
  // Update AuthViewModel
  final authVM = context.read<AuthViewModel>();
  await authVM.checkLoginStatus();
  
  // Load profile
  final profileVM = context.read<ProfileViewModel>();
  await profileVM.loadProfile();
  
  // Navigate
  context.go('/');
} else {
  print('Login failed');
}
```

### Example 4: Logout

```dart
// From anywhere in the app
final authVM = context.read<AuthViewModel>();
await authVM.logout();

// This will:
// 1. Sign out from Firebase
// 2. Clear local session
// 3. Set AuthViewModel.isLoggedIn = false
// 4. GoRouter will redirect to /login
```

### Example 5: Check Permission for Feature

```dart
// Check if user can access a feature
final profileVM = context.read<ProfileViewModel>();
final canDeleteUsers = RolePermissions.canAccessFeature(
  profileVM.role,
  'delete_user'
);

if (canDeleteUsers) {
  // Show delete button
}
```

### Example 6: Protected Screen with Permission Check

```dart
class MyProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    
    // Check permission
    final hasAccess = RolePermissions.canAccessFeature(
      profileVM.role,
      'view_statistics'
    );
    
    if (!hasAccess) {
      return Scaffold(
        body: Center(
          child: Text('You do not have permission to view this page'),
        ),
      );
    }
    
    // Render protected content
    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: StatisticsContent(),
    );
  }
}
```

---

## Troubleshooting

### Issue: User Logged In But Redirected to Login

**Symptom:**
```
[GoRouter] going to /
[GoRouter] redirecting to /login
```

**Cause:** ProfileViewModel not loaded, role is null

**Solution:** Ensure profile is loaded after login:
```dart
// In login_screen.dart
final profileVM = context.read<ProfileViewModel>();
await profileVM.loadProfile(); // ← Must be called before navigation
```

### Issue: Login Succeeds But No Navigation

**Symptom:** User sees login screen after successful login

**Cause:** navigationTarget not being handled

**Solution:** Check Consumer in login_screen.dart:
```dart
Consumer<LoginViewModel>(
  builder: (context, viewModel, _) {
    if (viewModel.navigationTarget != null) {
      // Navigation logic here
    }
  }
)
```

### Issue: "Permission Denied" After Login

**Symptom:** User redirected away from intended route

**Cause:** Role-based access control blocking access

**Solution:**
1. Check user's role in Firestore
2. Verify role in `RolePermissions.routeAccess`
3. Ensure ProfileViewModel loaded correctly

### Issue: Session Not Persisting

**Symptom:** User logged out after app restart

**Possible Causes:**
1. Firebase not initialized properly
2. App data cleared
3. Logout called somewhere

**Debug:**
```dart
// Check Firebase current user
final user = FirebaseAuth.instance.currentUser;
print('Current user: ${user?.email}'); // Should not be null
```

### Issue: Email Verification Not Syncing

**Symptom:** emailVerified always false

**Solution:** Manually trigger sync:
```dart
await FirebaseAuthService().syncCurrentUserEmailVerification();
```

### Issue: Cannot Create Users (Admin Logged Out)

**Symptom:** Admin gets logged out when creating user

**Cause:** Using primary Firebase app for registration

**Solution:** Code already uses secondary app, ensure it's working:
```dart
// Check logs for:
'FirebaseAuth: Using existing secondary app'
// or
'FirebaseAuth: Creating new secondary app'
```

---

## Security Best Practices

### 1. Never Store Passwords
- ✅ Firebase handles password hashing
- ✅ Passwords never stored in Firestore
- ✅ Only Firebase Auth has passwords

### 2. Use Email Verification
- ✅ Verification emails sent automatically
- ✅ emailVerified tracked in user model
- ✅ Can be used to restrict features

### 3. Role-Based Access Control
- ✅ Permissions checked on every navigation
- ✅ Fail-closed (deny by default)
- ✅ Server-side validation should also be implemented

### 4. Session Security
- ✅ Firebase handles token refresh
- ✅ Tokens encrypted at rest
- ✅ Secure platform-specific storage

### 5. Re-authentication for Sensitive Operations
```dart
// Before password change or email update
await FirebaseAuthService().reauthenticateUser(currentPassword);
```

---

## Summary

### Key Takeaways

1. **Multi-Layer Architecture**: UI → ViewModel → Repository → Service
2. **Firebase Primary**: Uses Firebase Auth + Firestore
3. **Local Fallback**: Works offline with local database
4. **Session Persistence**: Firebase auto-manages sessions
5. **Route Protection**: GoRouter redirects based on auth status
6. **Role-Based Access**: Permissions checked using RolePermissions
7. **Profile Loading**: Must load profile after login for permissions
8. **Email Verification**: Tracked and synced automatically

### Authentication Checklist

When implementing auth features:

- [ ] Check `AuthViewModel.isLoggedIn` for auth status
- [ ] Load `ProfileViewModel` after login
- [ ] Use `RolePermissions` for access control
- [ ] Handle errors gracefully (network, Firebase, etc.)
- [ ] Test all user roles
- [ ] Verify session persistence
- [ ] Test offline behavior (local fallback)
- [ ] Check email verification flow
- [ ] Ensure secondary app used for registration

---

## Additional Resources

**Files to Review:**
- `lib/data/services/firebase_auth_service.dart` - Firebase operations
- `lib/data/repositories_dcl/auth_repository_dcl.dart` - Auth coordination
- `lib/ui/features/auth/view_models/auth_view_model.dart` - Global auth state
- `lib/ui/features/auth/view_models/login_view_model.dart` - Login flow
- `lib/ui/features/profile/view_model/profile_view_model.dart` - User profile
- `lib/routing/go_router_config.dart` - Route protection
- `lib/domain/constants/role_permissions.dart` - Permission definitions

**Related Documentation:**
- `LOGIN_NAVIGATION_FIX.md` - Login redirect issue fix
- `ROLE_PERMISSIONS_DETAILED_GUIDE.md` - Role-based access control
- `GOROUTER_ADVANCED_FEATURES.md` - GoRouter authentication guards

---

**Last Updated:** 2026-02-04  
**Author:** GitHub Copilot Agent  
**Version:** 1.0
