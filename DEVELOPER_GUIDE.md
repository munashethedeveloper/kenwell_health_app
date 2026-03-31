# KenWell Health App – Developer Guide

This guide answers common how-to questions for developers working on the KenWell Health App.

---

## 4. How to Enable Firebase Cloud Messaging (FCM)

FCM is already implemented in `lib/data/services/push_notification_service.dart`.  
To activate it in the Firebase Console:

1. Open [Firebase Console](https://console.firebase.google.com/) → select your project (`kenwellmobileapp`).
2. Go to **Build → Messaging**.
3. Click **Get started** (if not already activated).
4. **Android** – FCM is automatically enabled for Android; no additional step needed.
5. **iOS** – Under **Project Settings → Cloud Messaging**, upload your APNs Authentication Key (`.p8` file) from the Apple Developer Portal, or upload your APNs Certificate.
6. Test a notification:
   - In the Firebase Console go to **Messaging → New campaign → Notifications**.
   - Target a single device by entering the FCM token logged by `PushNotificationService` on first launch.
   - Send a test message and verify it appears on the device.

> **Tip:** The `PushNotificationService` stores the current device FCM token in `users/{uid}.fcmTokens` in Firestore. You can copy that token from Firestore to target a specific device during testing.

---

## 5. How to Enable Firebase App Hosting

Firebase App Hosting is pre-configured in `apphosting.yaml` (build command: `flutter build web --release --web-renderer canvaskit`).

1. Install the Firebase CLI if you haven't: `npm install -g firebase-tools`
2. Log in: `firebase login`
3. In the [Firebase Console](https://console.firebase.google.com/) → **Build → App Hosting**.
4. Click **Get started** and follow the wizard:
   - Connect to your GitHub repository (`munashethedeveloper/kenwell_health_app`).
   - Select the branch to deploy (e.g. `main`).
   - Firebase detects `apphosting.yaml` and sets up the build pipeline automatically.
5. Every push to the connected branch automatically triggers a new deployment.

> **CI note:** `.github/workflows/flutter_ci.yml` also deploys to Firebase Hosting (the classic static host in `firebase.json`) via `FirebaseExtended/action-hosting-deploy@v0` using the `FIREBASE_SERVICE_ACCOUNT_KENWELLMOBILEAPP` GitHub secret.

---

## 6. How to Enable Firebase Crashlytics

Crashlytics is already integrated via the `firebase_crashlytics` package.  
To activate it in the Firebase Console:

1. Open [Firebase Console](https://console.firebase.google.com/) → **Release & Monitor → Crashlytics**.
2. Click **Enable Crashlytics**.
3. Make sure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are present in the project.
4. Build and run the app at least once in **release mode** so Crashlytics can upload the mapping/dSYM files:
   - Android: `flutter build apk --release`
   - iOS: `flutter build ios --release`
5. Force a test crash from Dart to verify the pipeline:
   ```dart
   FirebaseCrashlytics.instance.crash(); // Only in a debug/test build!
   ```
6. After a few minutes the crash should appear in the Firebase Console under **Crashlytics → Issues**.

> **Note:** Crashlytics reports are **suppressed in debug mode** (`kDebugMode`). Ensure you test with a release or profile build.

---

## 7. How to Use Debug, Release and Production Modes

### Flutter build modes

| Mode | Command | Description |
|------|---------|-------------|
| Debug | `flutter run` | Hot-reload, verbose logging, assertions enabled |
| Profile | `flutter run --profile` | Near-release performance, DevTools enabled |
| Release | `flutter run --release` or `flutter build apk --release` | Fully optimised, no debug overhead |

### Passing environment variables (secrets)

The app reads secrets via `--dart-define`:

```bash
# Debug run with encryption key
flutter run \
  --dart-define=PII_ENCRYPTION_KEY=your_base64_key_here

# Release build
flutter build apk --release \
  --dart-define=PII_ENCRYPTION_KEY=your_base64_key_here
```

### Separate Firebase environments (recommended)

1. Create two Firebase projects: e.g. `kenwellmobileapp-dev` and `kenwellmobileapp-prod`.
2. Download separate `google-services.json` files for each.
3. Place them in `android/app/src/debug/` and `android/app/src/release/` respectively.
4. Flutter picks up the correct file based on the build variant automatically.

### Android signing

Release APKs/AABs are signed via environment variables (`KEYSTORE_PATH`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`). See `android/app/build.gradle.kts` for details.

---

## 8. How to Run Tests with Mocktail

The project uses [`mocktail`](https://pub.dev/packages/mocktail) for mocking dependencies.

### Run all tests

```bash
flutter test
```

### Run tests with coverage

```bash
flutter test --coverage
# View HTML report (requires lcov):
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run a specific test file

```bash
flutter test test/ui/features/event/view_model/event_view_model_test.dart
```

### Run tests matching a pattern

```bash
flutter test --name "loadEvents"
```

### Writing a new ViewModel test

Follow the pattern in existing tests under `test/ui/features/`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 1. Create mock classes
class MockMyRepository extends Mock implements MyRepository {}

void main() {
  late MockMyRepository mockRepo;
  late MyViewModel viewModel;

  setUp(() {
    mockRepo = MockMyRepository();
    viewModel = MyViewModel(repository: mockRepo);
  });

  group('MyViewModel', () {
    test('initial state is empty', () {
      expect(viewModel.items, isEmpty);
    });

    test('loadItems populates the list on success', () async {
      when(() => mockRepo.fetchItems()).thenAnswer((_) async => [_item()]);

      await viewModel.loadItems();

      expect(viewModel.items.length, 1);
      expect(viewModel.isLoading, isFalse);
    });
  });
}

MyItem _item() => MyItem(id: '1', name: 'Test');
```

### CI test pipeline

Tests run automatically on every push/PR to `main`, `master`, `develop`, and `copilot/**` branches via `.github/workflows/flutter_ci.yml`:

```
pub get → build_runner → dart format check → flutter analyze --fatal-infos → flutter test --coverage → codecov upload
```

---

## 9. FCM Notification Message Catalogue

These ready-to-use titles and body texts are derived from the app's features, user roles, and event lifecycle.
Copy them directly into the **Firebase Console → Messaging → New campaign** or use them in your server-side Cloud Functions.

### How to deep-link from a notification

The app's `PushNotificationService` reads two optional data keys on every incoming message:

| Data key | Value | Result |
|---|---|---|
| `eventId` | `<event document ID>` | Opens `/event/<eventId>` |
| `screen` | route path (e.g. `all-events`) | Opens `/<screen>` |
| *(neither)* | — | Falls back to `/all-events` |

Add these as **Additional data** in the Firebase Console or as the `data` payload in your server request.

---

### 1. Wellness Event Lifecycle

#### 1a. Event Scheduled (sent to assigned nurses/coordinators)

| Field | Text |
|---|---|
| **Title** | 📅 New Event Scheduled |
| **Body** | You have been allocated to *{Event Title}* on {Date} at {Venue}, {City}. Open the app to review the details. |
| **Data** | `eventId: <id>` |

#### 1b. Event Starting Soon (sent ~30 minutes before `startTime`)

| Field | Text |
|---|---|
| **Title** | ⏰ Event Starting Soon |
| **Body** | *{Event Title}* starts in 30 minutes at {Venue}. Please ensure you are set up and ready to welcome participants. |
| **Data** | `eventId: <id>` |

#### 1c. Event Now Live / In Progress

| Field | Text |
|---|---|
| **Title** | 🟢 Event Is Now Live |
| **Body** | *{Event Title}* is currently in progress at {Venue}, {City}. Live screening counts are available on the Stats screen. |
| **Data** | `screen: live-events` |

#### 1d. Event Completed

| Field | Text |
|---|---|
| **Title** | ✅ Event Completed |
| **Body** | *{Event Title}* has been marked as completed. {X} participants were screened. View the full report in Past Events. |
| **Data** | `screen: past-events` |

#### 1e. Event Cancelled / Postponed

| Field | Text |
|---|---|
| **Title** | ⚠️ Event Update |
| **Body** | *{Event Title}* scheduled for {Date} has been postponed. Please contact your coordinator for the updated date. |
| **Data** | `screen: all-events` |

---

### 2. Member Registration & Wellness Flow

#### 2a. Member Registered for Event

| Field | Text |
|---|---|
| **Title** | 👤 Member Registered |
| **Body** | A new member has been registered for *{Event Title}*. The wellness flow is ready to begin. |
| **Data** | `eventId: <id>` |

#### 2b. Consent Completed

| Field | Text |
|---|---|
| **Title** | 📝 Consent Form Signed |
| **Body** | Consent has been captured for {Member Name}. Proceed to the Health Screenings step in the wellness flow. |
| **Data** | `eventId: <id>` |

#### 2c. All Screenings Completed for a Member

| Field | Text |
|---|---|
| **Title** | 🩺 Screenings Complete |
| **Body** | All requested health screenings for {Member Name} have been completed. Don't forget to record the post-screening survey. |
| **Data** | `eventId: <id>` |

#### 2d. High-Risk Result Flagged

| Field | Text |
|---|---|
| **Title** | 🔴 High-Risk Outcome Detected |
| **Body** | A high-risk screening result has been flagged for a participant at *{Event Title}*. A referral has been recorded. Please follow up accordingly. |
| **Data** | `eventId: <id>` |

#### 2e. Referral Recorded

| Field | Text |
|---|---|
| **Title** | 🏥 Referral Issued |
| **Body** | A clinic referral has been logged for {Member Name}. Ensure the participant receives the referral letter before they leave. |
| **Data** | `eventId: <id>` |

---

### 3. Screening-Specific Alerts

#### 3a. HCT (HIV Counselling & Testing) Result Captured

| Field | Text |
|---|---|
| **Title** | 🔬 HCT Result Recorded |
| **Body** | An HCT result has been captured for a participant at *{Event Title}*. Review in the member's wellness record. |
| **Data** | `eventId: <id>` |

#### 3b. TB Screening Completed

| Field | Text |
|---|---|
| **Title** | 🫁 TB Screening Done |
| **Body** | A TB screening has been completed and recorded for a participant at *{Event Title}*. |
| **Data** | `eventId: <id>` |

#### 3c. Cancer Screening Completed

| Field | Text |
|---|---|
| **Title** | 🎗️ Cancer Screening Recorded |
| **Body** | Cancer screening results (Pap Smear / Breast / PSA) have been captured for a participant. View the record in the member's wellness history. |
| **Data** | `eventId: <id>` |

#### 3d. HRA (Health Risk Assessment) Completed

| Field | Text |
|---|---|
| **Title** | 📊 HRA Complete |
| **Body** | A Health Risk Assessment has been completed for a participant at *{Event Title}*. The risk score is available in the wellness report. |
| **Data** | `eventId: <id>` |

---

### 4. User & Account Notifications

#### 4a. New User Account Created (sent to admins)

| Field | Text |
|---|---|
| **Title** | 👤 New User Registered |
| **Body** | A new user account has been created. Review and assign the appropriate role in User Management. |
| **Data** | `screen: user-management` |

#### 4b. User Role Changed

| Field | Text |
|---|---|
| **Title** | 🔑 Your Role Has Been Updated |
| **Body** | Your account role in KenWell365 has been updated to *{New Role}*. If this is unexpected, please contact your administrator. |
| **Data** | `screen: my-profile-menu` |

#### 4c. Incomplete Profile Reminder

| Field | Text |
|---|---|
| **Title** | 📋 Complete Your Profile |
| **Body** | Some required profile details are missing. Please update your name, phone number, and role to ensure you have full access to all features. |
| **Data** | `screen: profile` |

#### 4d. Password Reset Requested

| Field | Text |
|---|---|
| **Title** | 🔒 Password Reset Requested |
| **Body** | A password reset has been requested for your KenWell365 account. If you did not request this, please contact your administrator immediately. |
| **Data** | `screen: login` |

---

### 5. Administrative & System Alerts

#### 5a. Low Participation Warning (sent to coordinators)

| Field | Text |
|---|---|
| **Title** | ⚠️ Low Event Participation |
| **Body** | *{Event Title}* has screened only {X} of {Expected} expected participants so far. Consider reaching out to increase uptake. |
| **Data** | `eventId: <id>` |

#### 5b. Pending Data Sync Reminder

| Field | Text |
|---|---|
| **Title** | 🔄 Pending Data to Sync |
| **Body** | You have offline records waiting to sync. Please connect to the internet to ensure all wellness data is saved to the server. |
| **Data** | `screen: home` |

#### 5c. Daily Summary Report (sent each evening to managers)

| Field | Text |
|---|---|
| **Title** | 📈 Daily Wellness Summary |
| **Body** | Today's events are complete. {Total} members were screened across {EventCount} event(s). Open the Stats screen for the full breakdown. |
| **Data** | `screen: stats` |

#### 5d. Upcoming Event Reminder (sent the day before)

| Field | Text |
|---|---|
| **Title** | 📆 Event Reminder for Tomorrow |
| **Body** | You have *{Event Title}* tomorrow at {Venue}, {City}. Set-up time is {SetUpTime}. Please confirm your attendance with your coordinator. |
| **Data** | `eventId: <id>` |

#### 5e. Event Allocation Changed

| Field | Text |
|---|---|
| **Title** | 📌 Event Allocation Updated |
| **Body** | Your event allocation has changed. You have been assigned to *{Event Title}* on {Date}. Check the Calendar for all your upcoming events. |
| **Data** | `screen: calendar` |

---

### 6. Testing Notifications (Development Only)

Use these messages when testing FCM delivery in a development environment.

| Field | Text |
|---|---|
| **Title** | 🧪 Test Notification |
| **Body** | This is a test push notification from KenWell365. If you received this, FCM is configured correctly! |
| **Data** | *(no data keys needed)* |

---

### Quick-Reference: Common `screen` Deep-link Values

| Screen | Data value |
|---|---|
| Home / Dashboard | `screen: home` (falls back to `/all-events`) |
| All Events list | `screen: all-events` |
| Calendar | `screen: calendar` |
| Live Events / Stats | `screen: live-events` |
| Past Events | `screen: past-events` |
| Statistics | `screen: stats` |
| Profile | `screen: profile` |
| User Management | `screen: user-management` |
| Audit Log | `screen: audit-log` |
| Help / FAQ | `screen: faq` |
| Specific event | `eventId: <firestoreDocumentId>` |

---

## 10. Reconfiguring Firebase After Renaming the Package

This section walks you through every file that must change when you rename the app's package/bundle ID.
The current package ID in this repository is **`com.kenwell.healthapp`** (Android) and **`com.example.kenwellHealthApp`** (iOS).
Replace both with your new IDs in the steps below.

---

### Step 1 – Update the Firebase Console (Android)

Firebase ties each Android app to an exact `package_name`. You cannot change it in place; you must re-register.

1. Open [Firebase Console](https://console.firebase.google.com/) → your project → **Project settings**.
2. Under **Your apps**, find the Android app (`com.kenwell.healthapp`).
3. Click the three-dot menu → **Delete this app** (existing data is NOT deleted from Firestore/Auth/etc.).
4. Click **Add app → Android**.
5. Enter your new package name (e.g. `com.yourcompany.newapp`).
6. Enter the app nickname and, if you have a release keystore, the **SHA-1** certificate fingerprint.
7. Download the freshly generated **`google-services.json`** and replace:
   ```
   android/app/google-services.json
   ```
8. Repeat for any SHA-1 variants (debug, release, CI) under **Project settings → Your apps → Add fingerprint**.

---

### Step 2 – Update the Firebase Console (iOS)

1. In Firebase Console → **Project settings → Your apps**, find the iOS app.
2. Click the three-dot menu → **Delete this app**.
3. Click **Add app → Apple**.
4. Enter your new bundle ID (e.g. `com.yourcompany.newapp`).
5. Download the freshly generated **`GoogleService-Info.plist`** and replace:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
   (This file is not present in the repo by default if it was gitignored — place it in that path.)

---

### Step 3 – Update `android/app/build.gradle.kts`

Open `android/app/build.gradle.kts` and change **two** values:

```kotlin
// Before
namespace = "com.kenwell.healthapp"
// ...
applicationId = "com.kenwell.healthapp"

// After
namespace = "com.yourcompany.newapp"
// ...
applicationId = "com.yourcompany.newapp"
```

Both `namespace` (line 12) and `applicationId` (inside `defaultConfig`, line 60) must match your new package name.

---

### Step 4 – Rename the Kotlin source directory

Flutter generates the Kotlin entry point in a directory that mirrors the package name.
The current file is:

```
android/app/src/main/kotlin/com/kenwell/healthapp/MainActivity.kt
```

1. Create the new directory tree:
   ```
   android/app/src/main/kotlin/com/yourcompany/newapp/
   ```
2. Move `MainActivity.kt` into it.
3. Update the `package` declaration at the top of `MainActivity.kt`:
   ```kotlin
   // Before
   package com.kenwell.healthapp

   // After
   package com.yourcompany.newapp
   ```
4. Delete the now-empty old directory tree (`com/kenwell/healthapp/`).

---

### Step 5 – Update `android/app/src/main/AndroidManifest.xml`

If `AndroidManifest.xml` contains an explicit `package=` attribute, update it:

```xml
<!-- Before -->
<manifest xmlns:android="..." package="com.kenwell.healthapp">

<!-- After -->
<manifest xmlns:android="..." package="com.yourcompany.newapp">
```

> **Note:** In modern Android Gradle Plugin (AGP ≥ 7.3), the `package` attribute in the manifest is replaced by `namespace` in `build.gradle.kts`. Check whether your manifest still has it and remove or update it accordingly.

---

### Step 6 – Update the iOS bundle identifier in Xcode

The iOS bundle ID is stored in the Xcode project file and used at build time via `$(PRODUCT_BUNDLE_IDENTIFIER)`.

**Option A — Xcode GUI (recommended)**
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** project → **Runner** target → **Signing & Capabilities** tab.
3. Change **Bundle Identifier** from `com.example.kenwellHealthApp` to your new ID.
4. Xcode updates `ios/Runner.xcodeproj/project.pbxproj` automatically.

**Option B — sed (fast for CI/scripting)**
```bash
# Replace all occurrences of the old iOS bundle ID
sed -i '' \
  's/com\.example\.kenwellHealthApp/com.yourcompany.newapp/g' \
  ios/Runner.xcodeproj/project.pbxproj
```

There are currently **6 occurrences** of `com.example.kenwellHealthApp` in `project.pbxproj` (3 for the app target, 3 for the RunnerTests target).

---

### Step 7 – Update `pubspec.yaml`

If you are also changing the Dart package name (the `name:` field), update `pubspec.yaml`:

```yaml
# Before
name: kenwell_health_app

# After
name: your_new_app_name
```

Then run a project-wide find-and-replace for every Dart `import` that references the old name:

```bash
# Find all affected imports
grep -r "package:kenwell_health_app/" lib/ test/

# Replace (macOS)
find lib test -name "*.dart" \
  -exec sed -i '' \
    's|package:kenwell_health_app/|package:your_new_app_name/|g' {} +
```

---

### Step 8 – Flush dependency caches and rebuild

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Then do a full build to confirm no breakage:

```bash
# Android
flutter build apk --debug

# iOS (requires a Mac with Xcode)
flutter build ios --debug --no-codesign
```

---

### Step 9 – Update Firebase CLI project association (optional)

If you use the Firebase CLI for Hosting, Functions, or Firestore rules deployment, check `.firebaserc`:

```json
{
  "projects": {
    "default": "kenwellmobileapp"
  }
}
```

This is a **Firebase project ID** (not the app package name) so it does not need to change unless you also moved to a different Firebase project.

---

### Step 10 – Re-run `flutterfire configure` (recommended)

The easiest way to regenerate all config files at once is to re-run the FlutterFire CLI:

```bash
# Install/update the CLI if needed
dart pub global activate flutterfire_cli

# Re-configure — this regenerates google-services.json,
# GoogleService-Info.plist, and lib/firebase_options.dart
flutterfire configure --project=kenwellmobileapp
```

When prompted, enter your new package name / bundle ID. The CLI will update:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart` (if you have one)

---

### Quick checklist

| # | File / location | What changes |
|---|---|---|
| 1 | Firebase Console (Android) | Re-register with new `package_name`; download new `google-services.json` |
| 2 | Firebase Console (iOS) | Re-register with new bundle ID; download new `GoogleService-Info.plist` |
| 3 | `android/app/build.gradle.kts` | `namespace` + `applicationId` |
| 4 | `android/app/src/main/kotlin/…/MainActivity.kt` | Directory path + `package` declaration |
| 5 | `android/app/src/main/AndroidManifest.xml` | `package=` attribute (if present) |
| 6 | `ios/Runner.xcodeproj/project.pbxproj` | All 6 `PRODUCT_BUNDLE_IDENTIFIER` values |
| 7 | `pubspec.yaml` | `name:` field + all `import 'package:…'` statements |
| 8 | Build | `flutter clean && flutter pub get && build_runner` |
| 9 | `.firebaserc` | Only if moving to a different Firebase project |
| 10 | *(optional)* `flutterfire configure` | Regenerates all Firebase config files in one step |

---

## 11. Release Keystore & SHA-1 Certificate

### Current state of this project

| Item | Status |
|---|---|
| Release keystore file (`.jks`) | ✅ **Generated** — `%USERPROFILE%\keystores\kenwell_release.jks` (kept outside the repo) |
| `key.properties` file | ❌ **Not present** |
| SHA-1 fingerprint in `google-services.json` | ⚠️ **Must be registered** — see Step 3 below |
| Release signing config in `build.gradle.kts` | ✅ **Configured** — reads `KEYSTORE_PATH`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD` env vars; falls back to the debug keystore if any are absent |

**In practice today:** every release build (local and CI) is signed with the **debug keystore** because the four release env vars are not set. This is fine for development but **must** be resolved before publishing to Google Play.

---

### Step 1 – Generate a release keystore

Run this command **once** on your machine. Keep the resulting `.jks` file **outside the repository** and **never commit it**.

> **Windows users:** `keytool` ships with the JDK but is **not** added to PATH automatically.  
> You must either run the commands below via the **full path** to `keytool.exe`, or add the JDK `bin` folder to your system PATH first.  
> PowerShell also uses a **backtick (`` ` ``)** for line continuation — not a backslash (`\`).  
> See the [Windows PowerShell](#windows-powershell) section below.

**macOS / Linux (bash / zsh)**

```bash
mkdir -p ~/keystores
keytool -genkey -v \
  -keystore ~/keystores/kenwell_release.jks \
  -alias kenwell \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

**Windows PowerShell** <a name="windows-powershell"></a>

First, confirm where `keytool` lives on your machine (run once):

```powershell
flutter doctor -v 2>&1 | Select-String "Java"
# Expected output (example):
#   • Java binary at: C:\Program Files\Android\Android Studio\jbr\bin\java
```

`keytool.exe` is in the **same folder** as `java.exe`. For a typical Android Studio installation the path is:

```
C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe
```

Create the keystores folder and generate the keystore:

```powershell
# Create the keystores directory
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\keystores"

# Generate the release keystore (single line)
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore "$env:USERPROFILE\keystores\kenwell_release.jks" -alias kenwell -keyalg RSA -keysize 2048 -validity 10000
```

With backtick (`` ` ``) line continuation for readability:

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v `
  -keystore "$env:USERPROFILE\keystores\kenwell_release.jks" `
  -alias kenwell `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000
```

> **Note:** If your Android Studio is installed in a different location, adjust the path above to match the `Java binary at:` line from `flutter doctor -v`.

**Tip:** To avoid typing the full path every session, add the JDK `bin` folder to your user PATH:

```powershell
# Permanent PATH update (run once, then restart your terminal)
[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path","User") + ";C:\Program Files\Android\Android Studio\jbr\bin",
  "User"
)
```

After that, `keytool` will work without a full path in any new PowerShell window.

---

You will be prompted for:
- **First and last name**, organisation, city, country (used in the certificate's Distinguished Name)
- **Keystore password** (`STORE_PASSWORD`)
- **Key password** (`KEY_PASSWORD`) — can be the same as the store password

Write down (or store in a password manager) the alias (`kenwell`), the keystore password, and the key password. **If you lose them you cannot re-sign a published app.**

---

### Step 2 – Extract the SHA-1 fingerprint

> **Windows users:** If you have not yet added the JDK `bin` folder to your PATH (see the Tip in Step 1), replace `keytool` in the commands below with the full path:  
> `& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"`

**From the release keystore you just created:**

*macOS / Linux*
```bash
keytool -list -v \
  -keystore ~/keystores/kenwell_release.jks \
  -alias kenwell \
  | grep -E "SHA1:|SHA256:"
```

*Windows PowerShell — interactive password prompt*
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\keystores\kenwell_release.jks" `
  -alias kenwell
```

*Windows PowerShell — inline password (recommended to avoid prompt typos)*
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\keystores\kenwell_release.jks" `
  -alias kenwell `
  -storepass YOUR_STORE_PASSWORD
```

Replace `YOUR_STORE_PASSWORD` with the store password you set when running `keytool -genkey` in Step 1.

**From the debug keystore** (useful for development / Firebase auth testing):

> The Android SDK creates the debug keystore automatically the first time you build.  
> Its fixed credentials are:  alias = `androiddebugkey`, password = `android`.

**macOS / Linux (bash / zsh)**

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android \
  | grep -E "SHA1:|SHA256:"
```

**Windows PowerShell**

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -alias androiddebugkey `
  -storepass android `
  -keypass android `
  | Select-String -Pattern "SHA1:|SHA256:"
```

Or without filtering (to see the full certificate):

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -alias androiddebugkey `
  -storepass android `
  -keypass android
```

The output looks like:

```
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE
SHA256: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB
```

> **Note:** The debug keystore is unique to each machine — the fingerprints above are placeholders. Every developer and every CI runner that needs Firebase Auth features (Google Sign-In, Phone Auth, App Check) must register their own debug SHA-1 and SHA-256 in Firebase Console.

**Confirmed fingerprints for this project's release keystore** (generated 31 Mar 2026):

| Field | Value |
|---|---|
| **Alias** | `kenwell` |
| **Owner** | CN=MunasheMapiye, OU=KenWellnessConsulting, O=KenWellnessConsulting, L=Pretoria, ST=Gauteng, C=ZA |
| **Valid** | 31 Mar 2026 → 16 Aug 2053 |
| **SHA-1** | `71:04:24:FC:FA:63:98:16:E2:96:E6:6C:EB:CF:85:40:B9:14:E5:9D` |
| **SHA-256** | `65:6F:EF:2A:C6:6D:C0:BB:F4:E9:57:1C:71:27:1B:24:10:B4:CB:F7:25:E1:36:65:F3:1A:20:1F:3F:B7:85:48` |

> ⚠️ Keep the keystore file and passwords in a password manager. The SHA-1 and SHA-256 above must both be registered in Firebase Console (see Step 3).

---

#### Troubleshooting: "keystore password was incorrect"

If you see this error:

```
keytool error: java.io.IOException: keystore password was incorrect
```

**Common causes:**

1. **Typo at the interactive prompt** — the password field in the terminal does not echo characters, making it easy to mistype. Use the `-storepass` inline flag instead (shown above) so you can see what you are typing.

2. **Copy-paste encoding issue** — smart quotes (`"`) or invisible characters copied from a document can silently corrupt the password you type. Type the password manually rather than pasting.

3. **Wrong `.jks` file** — double-check that `$env:USERPROFILE\keystores\kenwell_release.jks` points to the file you just created.

**If you remember the password**, use the inline `-storepass` form:

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\keystores\kenwell_release.jks" `
  -alias kenwell `
  -storepass YOUR_STORE_PASSWORD
```

**If you have forgotten the password** (and the app has NOT yet been published to Google Play), delete the keystore and start over:

```powershell
Remove-Item "$env:USERPROFILE\keystores\kenwell_release.jks"
```

Then repeat Step 1 to generate a new keystore, choosing a password you will store safely (e.g. in a password manager).

> ⚠️ **Already published to Google Play?**  The signing key for a Play Store app is permanently bound to the first release — it cannot be replaced. If you published even one version with a keystore and have now lost its password, you will need to contact [Google Play support](https://support.google.com/googleplay/android-developer/) about key recovery or use [Play App Signing](https://developer.android.com/studio/publish/app-signing#enroll) to let Google manage your key going forward.

---

### Step 3 – Register the SHA fingerprints in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/) → your project → **Project settings**.
2. Under **Your apps**, select the Android app (`com.kenwell.healthapp`).
3. Scroll to **SHA certificate fingerprints** → click **Add fingerprint**.
4. Paste the **SHA-1** from your **release** keystore:
   ```
   71:04:24:FC:FA:63:98:16:E2:96:E6:6C:EB:CF:85:40:B9:14:E5:9D
   ```
5. Click **Add fingerprint** again and paste the **SHA-256**:
   ```
   65:6F:EF:2A:C6:6D:C0:BB:F4:E9:57:1C:71:27:1B:24:10:B4:CB:F7:25:E1:36:65:F3:1A:20:1F:3F:B7:85:48
   ```
6. Repeat for the **debug** SHA-1 and SHA-256 (required for Auth features like Google Sign-In during development).
7. Download the updated `google-services.json` and replace `android/app/google-services.json`.

> **Why does this matter?**  Google Sign-In, Phone Auth, and App Check all verify the SHA-1 of the APK/AAB at runtime.  If the fingerprint is not registered, those services will be blocked.

---

### Step 4 – Set the signing environment variables

**Local development (macOS / Linux)** — create a file like `~/.kenwell_signing_env` and source it:

```bash
export KEYSTORE_PATH="$HOME/keystores/kenwell_release.jks"
export KEY_ALIAS="kenwell"
export KEY_PASSWORD="<your-key-password>"
export STORE_PASSWORD="<your-store-password>"
```

Then add to your shell profile (`~/.zshrc` / `~/.bashrc`):

```bash
source ~/.kenwell_signing_env
```

**Local development (Windows PowerShell)** — set the variables for your current session:

```powershell
$env:KEYSTORE_PATH = "$env:USERPROFILE\keystores\kenwell_release.jks"
$env:KEY_ALIAS     = "kenwell"
$env:KEY_PASSWORD  = "<your-key-password>"
$env:STORE_PASSWORD = "<your-store-password>"
```

To persist across sessions, add those four lines to your PowerShell profile (`$PROFILE`):

```powershell
# Open (or create) your profile file
notepad $PROFILE
# Paste the four $env: lines above, save, and restart PowerShell
```

Run `flutter build apk --release` and the build will use the release keystore.

**CI (GitHub Actions)** — add four repository secrets in **Settings → Secrets and variables → Actions**:

| Secret name | Value |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded content of the `.jks` file (`base64 -i kenwell_release.jks`) |
| `KEY_ALIAS` | `kenwell` |
| `KEY_PASSWORD` | your key password |
| `STORE_PASSWORD` | your store password |

Then add a decode step to `.github/workflows/flutter_ci.yml` before the build step:

```yaml
- name: Decode release keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > /tmp/kenwell_release.jks
    echo "KEYSTORE_PATH=/tmp/kenwell_release.jks" >> $GITHUB_ENV
    echo "KEY_ALIAS=${{ secrets.KEY_ALIAS }}" >> $GITHUB_ENV
    echo "KEY_PASSWORD=${{ secrets.KEY_PASSWORD }}" >> $GITHUB_ENV
    echo "STORE_PASSWORD=${{ secrets.STORE_PASSWORD }}" >> $GITHUB_ENV
```

> The `build.gradle.kts` in this project already reads those four env vars and signs the release build automatically — no Gradle changes are needed.

---

### Quick checklist

- [x] Keystore `.jks` file generated and stored **outside** the repo (`%USERPROFILE%\keystores\kenwell_release.jks`)
- [x] Keystore password, key alias, and key password saved securely
- [x] Release SHA-1 and SHA-256 extracted (see fingerprint table in Step 2 above)
- [ ] Release SHA-1 registered in Firebase Console
- [ ] Release SHA-256 registered in Firebase Console
- [ ] Debug SHA-1 extracted and registered in Firebase Console
- [ ] Updated `google-services.json` downloaded and committed
- [ ] Signing env vars set locally (`~/.kenwell_signing_env` or shell profile)
- [ ] `KEYSTORE_BASE64`, `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD` added as GitHub Actions secrets
- [ ] Keystore decode step added to `.github/workflows/flutter_ci.yml`

---

## 12. Where to Find `google-services.json` on Firebase

`google-services.json` is the Android configuration file that tells the app how to connect to your Firebase project.  It contains the API keys, project IDs, and (once registered) the SHA-1 fingerprints for your app.

### Your Firebase project details

| Field | Value |
|---|---|
| **Project ID** | `kenwellmobileapp` |
| **Project number** | `195093019449` |
| **Android package name** | `com.kenwell.healthapp` |
| **App ID** | `1:195093019449:android:80c5c09ca6b7f409e8c6e8` |
| **Console URL** | https://console.firebase.google.com/project/kenwellmobileapp |

---

### Step-by-step: Download `google-services.json`

1. **Open the Firebase Console**
   Go to → [https://console.firebase.google.com/project/kenwellmobileapp/settings/general](https://console.firebase.google.com/project/kenwellmobileapp/settings/general)
   *(or navigate manually: Firebase Console → select **kenwellmobileapp** → gear icon ⚙️ → **Project settings**)*

2. **Scroll down to "Your apps"**
   On the **General** tab you will see a list of registered apps.  Look for the Android app with package name **`com.kenwell.healthapp`**.

3. **Click "google-services.json"**
   Under that Android app card there is a **`google-services.json`** download button.  Click it.

   > If you cannot see the button, make sure you are on the **General** tab (not Authentication, Firestore, etc.).

4. **Replace the file in the repo**
   Copy the downloaded file into the repository at exactly this path:
   ```
   android/app/google-services.json
   ```
   Replace the existing file. Do **not** rename it.

5. **Commit the updated file**
   ```bash
   git add android/app/google-services.json
   git commit -m "chore: update google-services.json"
   ```

---

### When do you need to re-download it?

| Situation | Action required |
|---|---|
| First-time project setup | Download once and commit |
| Added a new SHA-1 fingerprint (debug, release, CI) | Download again after adding fingerprint in Firebase Console |
| Changed the Android package name | Re-register the app; download a new file |
| Added a new Firebase product (e.g. App Check, Dynamic Links) | May need a fresh download to pick up new config keys |
| Rotated API keys in Firebase Console | Download again |

---

### Can't see the app in "Your apps"?

If the `com.kenwell.healthapp` app is **not listed** under Your apps:

1. Click **"Add app"** → choose the **Android** icon.
2. Enter package name: `com.kenwell.healthapp`
3. (Optional but recommended) Enter your debug SHA-1 now — see **Section 11** for how to extract it.
4. Click **"Register app"**.
5. Download the `google-services.json` file that is shown in the next step.
6. Place it at `android/app/google-services.json` and commit.

> **Note:** The iOS equivalent is `GoogleService-Info.plist`, which lives at `ios/Runner/GoogleService-Info.plist` and is downloaded from the same **Project settings → Your apps** page, under the iOS app card.

---

## 13. Firebase Warning: "An app with this package name already exists"

### What the warning means

When you open **Firebase Console → Project settings → Add app** and type in the package name `com.kenwell.healthapp`, Firebase shows:

> ⚠️ **An app with this package name already exists in your project. You can register additional SHA1s for the app in Settings.**

This is **not an error** — it is an informational warning.  It means the Android app (`com.kenwell.healthapp`) is **already registered** in the `kenwellmobileapp` Firebase project.  You do **not** need to create a new registration.

### What to do instead

You only need to add a new SHA-1 fingerprint to the existing app registration.  Follow these steps:

1. **Close the "Add app" dialog** — do not complete a new registration.

2. **Navigate to the existing app's settings:**
   Firebase Console → [Project settings](https://console.firebase.google.com/project/kenwellmobileapp/settings/general) → **General** tab → scroll to **Your apps** → click the `com.kenwell.healthapp` card.

3. **Scroll to "SHA certificate fingerprints"** and click **Add fingerprint**.

4. **Paste the SHA-1** you want to register (debug, release, or CI — see **Section 11** for extraction commands).

5. **Click Save**, then click the **`google-services.json`** download button on the same card and replace `android/app/google-services.json` in the repo.

### Why multiple SHA-1s are needed

| Environment | Keystore used | SHA-1 must be registered? |
|---|---|---|
| Local debug builds | Android debug keystore (`~/.android/debug.keystore`) | ✅ Yes (for Google Sign-In, Phone Auth in dev) |
| Release / Play Store builds | Your release `.jks` keystore | ✅ Yes (required for production Auth) |
| CI / GitHub Actions builds | Same release keystore (base64-encoded secret) | ✅ Yes (same as release if using same keystore) |

Each developer machine has its own debug keystore, so every developer who needs Google Sign-In locally must add **their** debug SHA-1 (and SHA-256) to Firebase.

### Quick reference — extract SHA-1 and SHA-256 for the debug keystore

**macOS / Linux**

```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android \
  | grep -E "SHA1:|SHA256:"
```

**Windows PowerShell**

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -alias androiddebugkey `
  -storepass android `
  -keypass android `
  | Select-String -Pattern "SHA1:|SHA256:"
```

Then add **both** the SHA-1 and SHA-256 values in Firebase Console as described in Step 3 above.

---

## 14. Troubleshooting: `flutter build apk --release` Fails With "Crashlytics Gradle plugin 3 requires Google-Services 4.4.1 and above"

### Error message

```
> Could not create task ':app:uploadCrashlyticsMappingFileRelease'.
   > Failed to query the value of task ':app:uploadCrashlyticsMappingFileRelease' property 'appIdFile'.
      > The Crashlytics Gradle plugin 3 requires Google-Services 4.4.1 and above.
```

### Root cause

The Crashlytics Gradle plugin v3.x has a hard dependency on `com.google.gms:google-services` **≥ 4.4.1**.
If `google-services` is pinned to an older version (e.g. `4.4.0`), the build fails immediately.

### Fix

Open `android/settings.gradle.kts` and bump the `google-services` version to at least `4.4.1`.
This project uses `4.4.2`:

```kotlin
// android/settings.gradle.kts — plugins block
id("com.google.gms.google-services") version "4.4.2" apply false   // was 4.4.0
id("com.google.firebase.crashlytics") version "3.0.2" apply false
```

### Version compatibility table

| Plugin | Minimum peer requirement |
|---|---|
| `com.google.firebase.crashlytics` 3.x | `com.google.gms:google-services` ≥ **4.4.1** |
| `com.google.firebase.crashlytics` 2.x | `com.google.gms:google-services` ≥ 4.3.x |

> Always check the [Crashlytics release notes](https://firebase.google.com/support/release-notes/android) when upgrading the Crashlytics plugin to verify the minimum `google-services` version required.
