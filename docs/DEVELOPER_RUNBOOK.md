# Kenwell Health App — Developer Runbook

> **Audience:** Any developer setting up or running the app for the first time.
> **VS Code + Flutter 3.32 assumed throughout.**
> Firebase project: **kenwellmobileapp** (Africa South 1 region)

---

## Table of Contents

1. [One-time machine setup](#1-one-time-machine-setup)
2. [Running in debug — Android device](#2-running-in-debug--android-device)
3. [Running in debug — Web browser](#3-running-in-debug--web-browser)
4. [Build modes explained (debug / profile / release)](#4-build-modes-explained)
5. [PII Encryption key for debug](#5-pii-encryption-key-for-debug)
6. [Running with the Firebase Emulator Suite](#6-running-with-the-firebase-emulator-suite)
7. [Verifying Firebase Performance is working](#7-verifying-firebase-performance-is-working)
8. [Monitoring Crashlytics](#8-monitoring-crashlytics)
9. [Resetting / cleaning the database](#9-resetting--cleaning-the-database)
10. [Running the unit test suite](#10-running-the-unit-test-suite)
11. [Deploying to the web (Firebase Hosting)](#11-deploying-to-the-web--firebase-hosting)
12. [Publishing the Android app](#12-publishing-the-android-app)
13. [Web vs Mobile — what you get on each platform](#13-web-vs-mobile--what-you-get-on-each-platform)
14. [Quick-reference cheat sheet](#14-quick-reference-cheat-sheet)

---

## 1. One-time machine setup

Install the following tools **once** on your development machine.  Run
`flutter doctor -v` and resolve every ✗ before continuing.

| Tool | Install | Purpose |
|------|---------|---------|
| Flutter 3.32+ | https://docs.flutter.dev/get-started/install | SDK |
| Android Studio / SDK | bundled in Android Studio or via `sdkmanager` | Android builds & emulator |
| Chrome | https://www.google.com/chrome | Web debug target |
| VS Code | https://code.visualstudio.com | IDE |
| Flutter + Dart VS Code extensions | VS Code Marketplace | Run/debug from VS Code |
| Node.js 18+ | https://nodejs.org | Required by Firebase CLI |
| Firebase CLI | `npm install -g firebase-tools` | Emulator + deploy |
| JDK 17+ | bundled with Android Studio | Android Gradle builds |

**Sign in to Firebase CLI once:**

```bash
firebase login
firebase use kenwellmobileapp   # sets the default project
```

---

## 2. Running in debug — Android device

### Prerequisites
- USB debugging **enabled** on your phone (Settings → Developer Options → USB Debugging).
- Phone plugged into laptop via USB **or** connected via Wi-Fi ADB.

### Steps

```bash
# 1. Install / update dependencies (run every time pubspec.yaml changes)
flutter pub get

# 2. Regenerate Drift database DAO code (run every time app_database.dart changes)
dart run build_runner build --delete-conflicting-outputs

# 3. Confirm Flutter can see your device
flutter devices
# Example output: Pixel 6 (mobile) • R5CN...  • android-arm64 • Android 14

# 4. Run in debug mode on your Android device
flutter run -d <device-id>
# Or just: flutter run   (if only one device is attached)
```

**From VS Code** — open `Run & Debug` (Ctrl+Shift+D), select `Flutter (debug)` from the dropdown, then press F5.  VS Code uses the `launch.json` configuration below:

```jsonc
// .vscode/launch.json  — create this file if it does not exist
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (debug)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    },
    {
      "name": "Flutter (debug + PII key)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define=PII_ENCRYPTION_KEY=KenwellHlthApp__DevKey__32chars!"]
    },
    {
      "name": "Flutter web (Chrome)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "deviceId": "chrome"
    }
  ]
}
```

> **Tip:** The app hot-reloads on file save.  Press `r` in the terminal to
> hot-reload manually, `R` for a full hot-restart.

---

## 3. Running in debug — Web browser

```bash
# Option A — Chrome (hot reload supported)
flutter run -d chrome --web-renderer canvaskit

# Option B — headless web server (useful if Chrome is slow or on a remote machine)
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
# then open http://localhost:8080 in any browser

# Shortcut via Makefile
make serve
```

> The app uses **CanvasKit** renderer so it looks identical on all browsers and
> on mobile.  If CanvasKit is slow on your machine during development you can
> temporarily switch to `--web-renderer html`.

---

## 4. Build modes explained

Flutter has three build modes.  They are **not** configured by a file — they
are determined by the flag you pass to `flutter run` / `flutter build`.

| Mode | Flag | `kDebugMode` | `kReleaseMode` | Firebase Performance | Crashlytics |
|------|------|:---:|:---:|:---:|:---:|
| **Debug** (default) | `flutter run` | `true` | `false` | **disabled** | logs only (no upload) |
| **Profile** | `flutter run --profile` | `false` | `false` | enabled | enabled |
| **Release** | `flutter build` | `false` | `true` | enabled | enabled |

**How to check which mode you are in at runtime:**

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode)   debugPrint('Running in DEBUG');
if (kProfileMode) debugPrint('Running in PROFILE');
if (kReleaseMode) debugPrint('Running in RELEASE');
```

The app itself prints the Firebase Performance status at startup:
```
Firebase Performance: collection disabled (debug)   ← debug run
Firebase Performance: collection enabled (release)  ← release run
```

---

## 5. PII Encryption key for debug

Sensitive fields (`idNumber`, `passportNumber`, `dateOfBirth`, `medicalAidNumber`,
`screeningResult`) are **AES-256-CBC encrypted** before they are stored in
Firestore.  The encryption key is supplied at build time via `--dart-define`.

| Situation | Key used |
|-----------|----------|
| Debug run without `--dart-define` | Hard-coded dev key (`KenwellHlthApp__DevKey__32chars!`) |
| Debug run with `--dart-define` | Your supplied key |
| Release / CI build | **Must** supply key via `--dart-define=PII_ENCRYPTION_KEY=<32-char key>` |

**Running with the PII key (recommended even in debug):**

```bash
flutter run --dart-define=PII_ENCRYPTION_KEY="MySecure32CharDevKey12345678901"
```

> **Important:** The dev fallback key is fine for local development.
> **Never deploy to production without setting a real, secret key.**
> In CI/CD the key is stored as a GitHub Actions secret.

---

## 6. Running with the Firebase Emulator Suite

The Firebase Emulator Suite lets you run Firestore, Authentication, and (optionally)
Functions **entirely on your laptop** without touching the production database.

### 6a. Install and configure emulators (one-time)

```bash
# Install emulator components
firebase setup:emulators:firestore
firebase setup:emulators:auth

# Initialise emulator config in the project (already done — emulator.json exists)
# If you need to re-run:
firebase init emulators
# Select: Authentication, Firestore
# Ports: Auth=9099, Firestore=8080 (defaults)
```

### 6b. Start the emulators

```bash
# From the project root
firebase emulators:start --only auth,firestore

# Or with the Firestore emulator UI (opens browser at http://localhost:4000)
firebase emulators:start --only auth,firestore --import ./emulator-seed --export-on-exit ./emulator-seed
```

You will see:
```
✔  firestore: Firestore Emulator running on localhost:8080
✔  auth:      Auth Emulator running on localhost:9099
✔  hub:       Emulator Hub running on localhost:4400
✔  ui:        Emulator UI running on http://localhost:4000
```

### 6c. Point the Flutter app at the emulators

Add the emulator connection code in `main.dart` (**only while testing
locally**; remove or comment out before committing):

```dart
// In main(), AFTER Firebase.initializeApp():
if (kDebugMode) {
  // Connect to local Auth emulator
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  // Connect to local Firestore emulator
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  debugPrint('🧪 Using Firebase Emulator Suite');
}
```

Then run your app normally:

```bash
flutter run -d chrome    # or your Android device
```

All Firestore reads and writes will go to the local emulator.  Open
[http://localhost:4000](http://localhost:4000) to browse the data in real-time.

### 6d. Seed data for emulator

To start the emulator with pre-loaded data (e.g. a test admin user and a
couple of events):

```bash
firebase emulators:start --import ./emulator-seed
```

To **save** the current emulator state so you can reuse it next time:

```bash
firebase emulators:export ./emulator-seed
```

> **Note:** The `./emulator-seed` folder is in `.gitignore` by default.
> Commit it only if you want the whole team to share the same seed data.

---

## 7. Verifying Firebase Performance is working

Firebase Performance is **disabled in debug mode** (`kDebugMode == true`) to
keep local development fast.  To verify it works:

### Option A — Run a profile or release build

```bash
# Profile build (performance enabled, debug tools still available)
flutter run --profile -d <device-id>
```

You will see in the console:
```
Firebase Performance: collection enabled (release)
```

After triggering a flow (register a member, submit consent, add/edit/delete an
event) wait **~5 minutes** then open the Firebase Console:

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Select project **kenwellmobileapp**
3. Navigate to **Performance** → **Custom traces**
4. You should see traces like:
   - `register_member`
   - `submit_consent`
   - `event_add` / `event_update` / `event_delete`
   - `flush_pending_writes`

### Option B — Force-enable in debug (temporary)

If you need to test Performance traces without a release build, temporarily
change `!kDebugMode` to `true` in `main.dart`:

```dart
// TEMPORARY: remove before committing
await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
```

> Performance data has a delay of **~5–10 minutes** before appearing in the
> Firebase Console even after the trace fires.

---

## 8. Monitoring Crashlytics

### In debug mode
In debug mode, crash details are **logged to the console** but **not uploaded**
to Crashlytics.  Look for lines starting with `🚨` in the VS Code debug console.

### In release mode (or profile mode)
Crashes are automatically uploaded to the Crashlytics dashboard.

**To test that Crashlytics is wired up:**

```dart
// Temporarily add this button somewhere, run in release/profile mode:
ElevatedButton(
  onPressed: () => throw Exception('Test Crashlytics'),
  child: const Text('Test crash'),
)
```

After the crash, open:
1. [console.firebase.google.com](https://console.firebase.google.com) → **kenwellmobileapp**
2. **Crashlytics** (left menu)
3. The crash will appear within ~2 minutes.

### Viewing crash reports

| Dashboard section | What it shows |
|------------------|---------------|
| **Dashboard** | All crashes, crash-free users %, trends |
| **Issues** | Individual crash stacks grouped by root cause |
| **Breadcrumbs** | Log messages recorded before the crash |

Custom log messages (e.g. `FirebaseCrashlytics.instance.log(...)`) appear under
the **Logs** tab of each crash event.

---

## 9. Resetting / cleaning the database

### Local SQLite database (offline cache)

The SQLite database (`app_database.sqlite3`) is stored in the app's local
documents directory.  To start fresh:

| Platform | How to clear |
|----------|-------------|
| **Android** | Settings → Apps → Kenwell Health App → Storage → **Clear Data** |
| **Web** | Open DevTools (F12) → Application → IndexedDB → delete the database |
| **During development (Android)** | `flutter clean && flutter run` (uninstalls and reinstalls the app) |

> **Warning:** Clearing app data also signs the user out of Firebase Auth.

### Firestore (cloud database)

**Never delete production data manually.** For development/testing:

1. Open [console.firebase.google.com](https://console.firebase.google.com) → **kenwellmobileapp** → **Firestore**
2. Select a collection (e.g. `members`) → click the three-dot menu → **Delete collection**

Or from the CLI for a full reset (use **only** on a test/dev project):
```bash
firebase firestore:delete --all-collections --project kenwellmobileapp
```

### Emulator data reset

```bash
# Start fresh with no data
firebase emulators:start --only auth,firestore

# Or reset an existing emulator run
# Ctrl+C to stop, then restart without --import
```

### Regenerate Drift DAO code after schema changes

If you modify `lib/data/local/app_database.dart`:

```bash
# Option 1: manual
dart run build_runner build --delete-conflicting-outputs

# Option 2: use the helper script
bash regenerate_db.sh

# Option 3: Makefile
make generate
```

---

## 10. Running the unit test suite

```bash
# Run all tests (no coverage)
flutter test

# Run all tests with HTML coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html   # requires lcov: brew install lcov
open coverage/html/index.html

# Run a single test file
flutter test test/utils/field_encryption_test.dart

# Run tests matching a name pattern
flutter test --name "ProfileViewModel"

# Makefile shortcut
make test
```

**Current test inventory (as of this session):**

| Directory | Files | Description |
|-----------|------:|-------------|
| `test/domain/usecases/` | 8 | All use case unit tests |
| `test/ui/features/` | 31 | All 25 ViewModel unit tests |
| `test/utils/` | 1 | FieldEncryption (11 tests) |
| **Total** | **40** | **~180+ assertions** |

---

## 11. Deploying to the web (Firebase Hosting)

The app can run **in a browser** — on any laptop, tablet, or phone — as a
Progressive Web App (PWA) hosted on Firebase Hosting.

### Automatic deployment (recommended)

| Branch pushed | Deployed to | URL |
|--------------|-------------|-----|
| `main` or `master` | Production (live channel) | `https://kenwellmobileapp.web.app` |
| `develop` | Staging channel | `https://kenwellmobileapp--staging-<hash>.web.app` (printed in CI log) |
| Any Pull Request | Preview channel (expires 7 days) | Posted as a comment on the PR |

Just push to the right branch — GitHub Actions does the rest automatically.

### Manual deployment from your machine

```bash
# 1. Make sure Firebase CLI is installed and you are logged in
npm install -g firebase-tools
firebase login
firebase use kenwellmobileapp

# 2. Build the web app
flutter build web --release --web-renderer canvaskit

# 3a. Deploy to production (live channel)
firebase deploy --only hosting --project kenwellmobileapp

# 3b. Deploy to a named staging channel instead
firebase hosting:channel:deploy staging --project kenwellmobileapp

# 3c. Promote staging to production (no rebuild needed)
firebase hosting:clone kenwellmobileapp:staging kenwellmobileapp:live

# Makefile shortcuts
make build            # builds web output
make deploy-staging   # builds + deploys to staging channel
make promote-staging  # promotes staging → production (no rebuild)
```

### Deploy Firestore rules and indexes at the same time

```bash
firebase deploy --only hosting,firestore:rules,firestore:indexes --project kenwellmobileapp
```

> **Do this after every change to `firestore.rules` or `firestore.indexes.json`.**

---

## 12. Publishing the Android app

### Debug APK (side-load onto your own phone)

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
# Transfer to phone and install manually, or:
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK / App Bundle (for the Play Store)

```bash
# 1. Set environment variables for the signing keystore
export KEYSTORE_PATH=/path/to/release.jks
export KEY_ALIAS=upload
export KEY_PASSWORD=<key-password>
export STORE_PASSWORD=<store-password>

# 2. Build a signed App Bundle (recommended for Play Store)
flutter build appbundle --release \
  --dart-define=PII_ENCRYPTION_KEY="YourRealProd32CharEncryptionKey!"

# Output: build/app/outputs/bundle/release/app-release.aab

# 3. Or build a signed APK (for direct distribution)
flutter build apk --release \
  --dart-define=PII_ENCRYPTION_KEY="YourRealProd32CharEncryptionKey!"
```

> You need a keystore file to sign a release build.  Generate one once with:
> ```bash
> keytool -genkey -v -keystore release.jks -alias upload \
>   -keyalg RSA -keysize 2048 -validity 10000
> ```
> Store `release.jks` **securely** — outside the repository.

---

## 13. Web vs Mobile — what you get on each platform

**Yes — the same codebase runs on both web and mobile.** Flutter compiles to
native Android/iOS code **and** to a web app from a single Dart codebase.

| Feature | Web (Firebase Hosting) | Android (APK/AAB) |
|---------|----------------------|-------------------|
| Access URL | `https://kenwellmobileapp.web.app` | Install from Play Store or side-load APK |
| Offline support | Firestore cache only (browser IndexedDB) | Firestore cache + SQLite local DB |
| Push notifications | Not supported (web FCM needs service worker) | ✅ Firebase Cloud Messaging |
| Camera (QR, photo) | Browser permission required | ✅ Native camera |
| Biometrics | Not available | ✅ (if implemented) |
| App icon on home screen | Via PWA "Add to home screen" | ✅ Native icon |
| Performance | CanvasKit renderer — smooth, pixel-perfect | Native Skia / Impeller |

**Recommendation:**
- Use **web** for admin/manager roles on laptops (event creation, stats reports, user management).
- Use the **Android app** for nurses doing screenings at events (offline support, camera, push notifications).

---

## 14. Quick-reference cheat sheet

```bash
# ── Daily dev workflow ──────────────────────────────────────────────────────
flutter pub get                              # restore packages (after git pull)
dart run build_runner build --delete-conflicting-outputs  # regen Drift code
flutter run                                 # run on attached Android device
flutter run -d chrome                       # run in Chrome

# ── Testing ─────────────────────────────────────────────────────────────────
flutter test                                # run all tests
flutter test --coverage                     # run with coverage
flutter analyze --fatal-infos               # lint

# ── Firebase Emulator ───────────────────────────────────────────────────────
firebase emulators:start --only auth,firestore          # start
firebase emulators:start --import ./emulator-seed       # start with seed data
firebase emulators:export ./emulator-seed               # save current state

# ── Build ───────────────────────────────────────────────────────────────────
flutter build web --release --web-renderer canvaskit    # web release
flutter build apk --release                             # Android APK
flutter build appbundle --release                       # Android Play Store bundle

# ── Firebase Hosting ────────────────────────────────────────────────────────
firebase deploy --only hosting                          # deploy web (manual)
firebase hosting:channel:deploy staging                 # deploy to staging
firebase hosting:clone kenwellmobileapp:staging kenwellmobileapp:live  # promote

# ── Firebase Rules & Indexes ─────────────────────────────────────────────────
firebase deploy --only firestore:rules,firestore:indexes  # deploy Firestore config

# ── PII Encryption key ───────────────────────────────────────────────────────
# Pass at build/run time via --dart-define
flutter run --dart-define=PII_ENCRYPTION_KEY="MySecure32CharKey1234567890AB"
flutter build apk --release --dart-define=PII_ENCRYPTION_KEY="<prod-key>"

# ── Database reset ───────────────────────────────────────────────────────────
flutter clean && flutter run               # wipes app install + SQLite on device
firebase firestore:delete --all-collections # ⚠ DANGER — wipes Firestore project

# ── Makefile shortcuts ───────────────────────────────────────────────────────
make help             # list all shortcuts
make get              # flutter pub get
make generate         # pub get + build_runner
make serve            # run in Chrome (hot reload)
make test             # flutter test --coverage
make build            # flutter build web --release
make deploy-staging   # build + deploy to staging
make promote-staging  # staging → production (no rebuild)
make clean            # rm -rf build/
```

---

## Appendix A — VS Code `.vscode/launch.json` (copy-paste ready)

```jsonc
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Android debug",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    },
    {
      "name": "Android debug (with PII key)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define=PII_ENCRYPTION_KEY=KenwellHlthApp__DevKey__32chars!"]
    },
    {
      "name": "Web — Chrome",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "deviceId": "chrome",
      "args": ["--web-renderer", "canvaskit"]
    },
    {
      "name": "Web — Chrome (with PII key)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "deviceId": "chrome",
      "args": [
        "--web-renderer", "canvaskit",
        "--dart-define=PII_ENCRYPTION_KEY=KenwellHlthApp__DevKey__32chars!"
      ]
    },
    {
      "name": "Profile (perf tracing on)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "flutterMode": "profile"
    }
  ]
}
```

---

## Appendix B — Firebase Console quick links

| What | URL |
|------|-----|
| Project overview | https://console.firebase.google.com/project/kenwellmobileapp |
| Firestore Database | https://console.firebase.google.com/project/kenwellmobileapp/firestore |
| Authentication | https://console.firebase.google.com/project/kenwellmobileapp/authentication |
| Firebase Hosting | https://console.firebase.google.com/project/kenwellmobileapp/hosting |
| Crashlytics | https://console.firebase.google.com/project/kenwellmobileapp/crashlytics |
| Performance | https://console.firebase.google.com/project/kenwellmobileapp/performance |
| Cloud Messaging (FCM) | https://console.firebase.google.com/project/kenwellmobileapp/messaging |
| Storage | https://console.firebase.google.com/project/kenwellmobileapp/storage |

---

*Last updated: March 2026 — reflects all features implemented in the production-readiness sprint.*
