# Authentication Quick Reference

## How Users Get Authenticated - TL;DR

### The Simple Answer

Users get authenticated through **Firebase Authentication** with email and password:

1. User enters email & password on login screen
2. Firebase verifies credentials
3. If valid, user is logged in
4. Session persists automatically
5. User can navigate the app based on their role

---

## Authentication Components

```
LoginScreen → LoginViewModel → AuthRepository → FirebaseAuthService → Firebase
```

**Analogy:** Think of it like airport security:
- **LoginScreen** = Security checkpoint entrance
- **LoginViewModel** = TSA officer checking your ID
- **AuthRepository** = Security supervisor coordinating checks
- **FirebaseAuthService** = Background check system
- **Firebase** = Central government database

---

## Login Flow (Simplified)

```
1. User enters credentials
   ↓
2. App sends to Firebase
   ↓
3. Firebase checks username/password
   ↓
4. If valid: Returns user data + session token
   ↓
5. App stores session (automatic)
   ↓
6. User navigates to main screen
```

---

## Key Files

| File | Purpose |
|------|---------|
| `firebase_auth_service.dart` | Talks to Firebase |
| `auth_repository_dcl.dart` | Coordinates authentication |
| `auth_view_model.dart` | Tracks "is user logged in?" |
| `login_view_model.dart` | Handles login screen |
| `login_screen.dart` | UI for login |
| `go_router_config.dart` | Protects routes |

---

## Common Operations

### Check if User is Logged In
```dart
final authVM = context.read<AuthViewModel>();
bool isLoggedIn = authVM.isLoggedIn;
```

### Get Current User Info
```dart
final profileVM = context.read<ProfileViewModel>();
await profileVM.loadProfile();

String email = profileVM.email;
String role = profileVM.role;
String name = '${profileVM.firstName} ${profileVM.lastName}';
```

### Logout
```dart
final authVM = context.read<AuthViewModel>();
await authVM.logout();
// User is redirected to login screen automatically
```

---

## Session Persistence

**Q: How does the user stay logged in after closing the app?**

**A:** Firebase stores a session token on the device:
- **iOS:** Keychain (encrypted)
- **Android:** SharedPreferences (encrypted)
- **Web:** Local Storage

When the app reopens:
1. Firebase checks for stored token
2. If valid, user is still logged in
3. No need to login again

**Session expires:** Never, unless user logs out or app data is cleared

---

## Security Features

✅ **Passwords are never stored** - Only Firebase has them  
✅ **Sessions auto-refresh** - Every hour, Firebase updates the token  
✅ **Email verification** - Users get verification emails  
✅ **Role-based access** - Different permissions for different roles  
✅ **Route protection** - Can't access pages without permission  

---

## Role-Based Access

The app has 6 user roles:

1. **ADMIN** - Full access to everything
2. **TOP MANAGEMENT** - Nearly full access
3. **PROJECT MANAGER** - Manage events and users
4. **PROJECT COORDINATOR** - Allocate events
5. **HEALTH PRACTITIONER** - Conduct wellness screenings
6. **CLIENT** - View-only access

Each role has specific permissions defined in `role_permissions.dart`.

---

## Authentication Guard (Route Protection)

**How it works:**

```
User tries to visit /user-management
  ↓
GoRouter checks: Is user logged in?
  ↓
  Yes → Check: Does user's role have permission?
    ↓
    Yes → Allow access ✅
    No  → Redirect to home ❌
  ↓
  No → Redirect to login ❌
```

This happens **automatically** on every navigation.

---

## Troubleshooting

### User can't login
- Check Firebase is initialized
- Verify credentials are correct
- Check network connection
- Look for errors in console

### User logged out unexpectedly
- Check if logout was called
- Verify Firebase session is valid
- Check if app data was cleared

### Redirected after login
- Ensure ProfileViewModel is loaded
- Check user has permission for destination route
- Verify role is correct in Firestore

---

## For More Details

See **AUTHENTICATION_GUIDE.md** for:
- Complete architecture diagrams
- Detailed step-by-step flows
- Code examples
- Troubleshooting guide
- Security best practices

---

## Summary

**How users get authenticated:**
1. Enter email/password
2. Firebase verifies
3. Session stored automatically
4. User navigates based on role
5. Session persists across app restarts

**That's it!** Firebase handles the complex parts (encryption, token refresh, secure storage). The app just sends credentials and Firebase says "yes" or "no".
