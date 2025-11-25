# Kenwell Health App

A wellness planning experience with form-heavy workflows, local persistence, and a guided auth experience.

## Tooling

- **Flutter**: 3.38.3 (Dart 3.10.1) — required by `signature` 6.x and the Drift toolchain.
- Install dependencies with `flutter pub get`.
- Regenerate Drift outputs after editing `lib/data/local/app_database.dart`:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## Auth & Persistence

- Login, registration, forgot-password, and profile screens are backed by a Drift database. `AuthService` exposes a single API surface that every screen reuses.
- Email + password validation now relies on reusable regex helpers (see `lib/utils/validators.dart`).
- For a deeper dive into the design, read [`AUTH_DRIFT_INTEGRATION.md`](AUTH_DRIFT_INTEGRATION.md).

## Helpful Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/) – tutorials, samples, and API reference.
