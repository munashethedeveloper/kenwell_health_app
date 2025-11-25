# Auth & Drift Integration Guide

## Background Analysis

- **Previous state**: Auth screens stored credentials in `SharedPreferences`, which meant only one user could exist locally and profile data was easily out of sync. Validation only checked for empty fields, so malformed emails and weak passwords slipped through.
- **Pain points**:
  - No real persistence layer to back login/register/profile flows.
  - Password reset merely checked for presence in preferences.
  - Profile edits overwrote shared preference fields without conflict detection.

## Architecture Overview

1. **Drift database (`lib/data/local/app_database.dart`)**
   - `Users` stores the canonical auth/profile state with created/updated timestamps.
   - `AppDatabase.instance` exposes helpers such as `createUser`, `getUserByEmail`, `getUserByCredentials`, and `updateUser`.
   - The app now targets Android (with optional desktop debugging) and no longer ships a web backend. The database always uses `LazyDatabase` + `NativeDatabase`/`sqlite3_flutter_libs`, so Windows/macOS debug builds share the same on-disk store as the Android runtime.

2. **Auth service (`lib/data/services/auth_service.dart`)**
   - Now orchestrates all reads/writes through Drift and only keeps the current user id in `SharedPreferences`.
   - Normalizes email + trims every field before persistence.
   - Provides `register`, `login`, `forgotPassword`, `saveUser`, `getCurrentUser`, and `getStoredPassword` APIs.
   - Throws a `StateError` if profile updates attempt to reuse an existing email address.

3. **Auth view model (`lib/ui/features/auth/view_models/auth_view_model.dart`)**
   - Delegates status checks, login, and logout to `AuthService`, keeping splash/auth wrapper logic in sync with Drift.

4. **Validation utilities (`lib/utils/validators.dart`)**
   - Central place for the required email + strong password regex:
     ```dart
     static final RegExp _emailRegex =
         RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
     static final RegExp _strongPasswordRegex =
         RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
     ```
   - Exported helpers (`validateEmail`, `validatePasswordPresence`, `validateStrongPassword`) are used across login/register/profile/forgot-password screens.

## How Each Screen Uses Drift

| Screen | Drift interaction | Validation updates |
| --- | --- | --- |
| `LoginScreen` | Calls `AuthService.login`, which queries Drift and stores the current user id when it succeeds. | Email + password reuse the shared regex validators. |
| `RegisterScreen` | Calls `AuthService.register`; duplicates short-circuited via a unique email lookup before insert. | Strong password check applied before submitting. |
| `ForgotPasswordScreen` | `AuthService.forgotPassword` now verifies the email exists inside Drift. | Uses the same email regex + copywriting. |
| `ProfileScreen` | Loads via `AuthService.getCurrentUser`, and saves back with `AuthService.saveUser`, which in turn performs a Drift update. | Email + strong password validators shared with other forms. |

## Development Workflow

1. **Toolchain**: The repo now targets **Flutter 3.38.3 / Dart 3.10.1** (required by the existing `signature` package and the new Drift toolchain).
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Generate Drift code** (run anytime `app_database.dart` changes):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. **Run tests / smoke checks** as usual (`flutter test`, targeted widget tests, etc.).

## Working with AuthService Directly

```dart
final authService = AuthService();

final newUser = await authService.register(
  email: 'casey@example.com',
  password: 'MyP@ssw0rd!',
  role: 'Nurse',
  phoneNumber: '5551234567',
  username: 'casey',
  firstName: 'Casey',
  lastName: 'Quinn',
);

if (newUser != null) {
  final loggedInUser = await authService.login('casey@example.com', 'MyP@ssw0rd!');
  // Navigate to main screen...
}
```

Because the profile screen reuses the same service, updating personal info simply means editing the form and tapping "Save Profile"; the Drift row is updated and the in-memory session stays in sync.

## Key Takeaways

- Auth flows now rely on a single source of truth (Drift) instead of ad-hoc preferences.
- Email/password validation is consistent and enforced at every touchpoint.
- Profile data, login status, and forgot-password checks are all fed by the same database-backed service, simplifying future server sync work or offline capabilities.
