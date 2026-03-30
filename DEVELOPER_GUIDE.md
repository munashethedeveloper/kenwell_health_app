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
