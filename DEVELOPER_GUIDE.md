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
