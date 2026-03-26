# Deployment Guide

## CI/CD Pipeline

**File:** `.github/workflows/flutter_ci.yml`

The pipeline runs on every push and pull request to: `main`, `master`, `develop`, `copilot/**`

### Steps

| Step | Command | Purpose |
|---|---|---|
| 1 | `flutter pub get` | Restore dependencies |
| 2 | `dart run build_runner build --delete-conflicting-outputs` | Generate Drift DAO code |
| 3 | `dart format --set-exit-if-changed .` | Enforce formatting |
| 4 | `flutter analyze --fatal-infos` | Static analysis (zero-warning policy) |
| 5 | `flutter test --coverage` | Run all tests with coverage |
| 6 | Upload to Codecov | Coverage reporting |
| 7 | `firebase-hosting-deploy` | Deploy to Firebase Hosting (main/master only) |

---

## Firebase Hosting

**Config file:** `firebase.json`

| Setting | Value |
|---|---|
| `public` | `build/web` |
| SPA rewrite | All URLs → `/index.html` |
| Cache control | Static assets: `max-age=31536000`, HTML: `no-cache` |

### Production Deploy

Triggered automatically on push to `main` or `master` via `FirebaseExtended/action-hosting-deploy@v0`.  
**Required secret:** `FIREBASE_SERVICE_ACCOUNT_KENWELLMOBILEAPP`

### PR Preview Channels

Every pull request deploys to a temporary Firebase Hosting preview channel. The URL is posted as a GitHub check on the PR. Preview channels are automatically deleted when the PR is closed.

---

## Firebase App Hosting

**Config file:** `apphosting.yaml`

| Setting | Value |
|---|---|
| `buildCommand` | `flutter build web --release --web-renderer canvaskit` |
| Output | Static |
| Runtime | `nodejs22` |

App Hosting is used for server-side rendering / edge features. The web renderer is **CanvasKit** for pixel-perfect Flutter rendering.

---

## Android Release Build

**Config file:** `android/app/build.gradle.kts`

| Setting | Value |
|---|---|
| `applicationId` | `com.kenwell.healthapp` |
| `namespace` | `com.kenwell.healthapp` |
| Min SDK | 21 |
| Target SDK | 34 |
| ProGuard | Enabled in release (`proguard-rules.pro`) |

### Release Signing

The build reads signing config from environment variables:

| Variable | Purpose |
|---|---|
| `KEYSTORE_PATH` | Path to the `.jks` keystore file |
| `KEY_ALIAS` | Key alias within the keystore |
| `KEY_PASSWORD` | Key password |
| `STORE_PASSWORD` | Keystore password |

Falls back to debug keys if any variable is absent.

### Build Release APK

```bash
export KEYSTORE_PATH=/path/to/release.jks
export KEY_ALIAS=my-key
export KEY_PASSWORD=secret
export STORE_PASSWORD=secret

flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Web Release Build

```bash
# CanvasKit renderer (production — matches App Hosting config)
flutter build web --release --web-renderer canvaskit

# HTML renderer (fallback / faster initial load)
flutter build web --release --web-renderer html
```

---

## Environment Setup (Developer)

### Prerequisites

- Flutter SDK ≥ 3.4.0
- Dart SDK ≥ 3.4.0
- Firebase CLI (`npm install -g firebase-tools`)
- Android Studio or Xcode (for native builds)
- A Firebase project with Firestore, Auth, Crashlytics, and Performance enabled

### Initial Setup

```bash
# 1. Clone and install
git clone <repo-url>
cd kenwell_health_app
flutter pub get

# 2. Generate Drift DAOs
dart run build_runner build --delete-conflicting-outputs

# 3. Configure Firebase
# Place google-services.json in android/app/
# Place GoogleService-Info.plist in ios/Runner/
# (web config is already embedded in lib/firebase_options.dart)

# 4. Run in development
flutter run
```

### Makefile Commands

A `Makefile` provides common dev commands:

```bash
make build        # flutter build web (debug)
make test         # flutter test
make analyze      # flutter analyze
make format       # dart format .
make gen          # build_runner build
make clean        # flutter clean + pub get
```

---

## Firebase Project Configuration

| Service | Status |
|---|---|
| Firestore | Enabled — rules in `firestore.rules`, indexes in `firestore.indexes.json` |
| Firebase Auth | Email/password provider |
| Firebase Crashlytics | Enabled — auto-captures uncaught exceptions in release |
| Firebase Performance | Enabled — custom traces in `AppPerformance` |
| Firebase Hosting | Enabled — `firebase.json` |
| Firebase Functions | `functions/` directory (Cloud Functions for admin tasks) |

### Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

### Deploy Functions

```bash
cd functions
npm install
firebase deploy --only functions
```