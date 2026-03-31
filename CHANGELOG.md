# Changelog

All notable changes to KenWell365 are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2026-03-29

### Added
- **Corporate wellness event management** — create, edit, and delete wellness
  events with multi-service configurations (nurses, OT, dietician, etc.).
- **Member registration & consent** — full onboarding flow: member registration,
  digital consent form, and wellness-flow orchestration.
- **Health screenings** — Health Risk Assessment (HRA), HCT HIV test, TB
  screening, Cancer screening, and post-event resilience survey.
- **Nurse interventions** — dedicated screens and ViewModels for capturing
  HCT and TB nursing intervention notes.
- **Calendar view** — real-time Firestore-backed calendar with event cards and
  offline persistence.
- **Statistics & reporting** — live event stats, screening counts, and historical
  event reports with per-service drill-down.
- **Role-based access control** — admin, coordinator, nurse, and practitioner
  roles enforced via `RolePermissions` + go_router guards.
- **Push notifications** — FCM integration with foreground, background, and
  terminated-state handlers; deep-link navigation from notification payloads.
- **Offline-first write queue** — failed Firestore writes are queued to a local
  SQLite database (Drift) and flushed automatically on reconnect.
- **PII encryption** — AES-256-CBC encryption for member ID numbers, passport
  numbers, dates of birth, and medical aid numbers via `FieldEncryption`.
- **Audit log** — every create/update/delete on core collections writes an
  immutable entry to the `audit_logs` Firestore collection; accessible to
  admin and top-management roles.
- **Centralised DI** — `AppProviders.rootProviders` is the single source of
  truth for all app-lifetime `ChangeNotifierProvider` registrations.
- **AppRoutes constants** — `lib/routing/app_routes.dart` eliminates hardcoded
  route name strings across the codebase.
- **Android App Links & iOS URL scheme** — HTTPS deep links for
  `kenwellhealth.co.za` and `kenwell365://` custom URI scheme.
- **Firebase Crashlytics** — collection enabled in release builds via
  `setCrashlyticsCollectionEnabled(!kDebugMode)`.
- **Firebase Performance Monitoring** — instrumented on key use cases and the
  pending-write flush path.
- **Privacy Policy & Terms of Service screen** — in-app legal screen accessible
  from the Help section.
- **Accessibility** — `Semantics` labels added to all action buttons, icon
  buttons, and key navigation elements in shared widgets.

### Architecture
- MVVM + Clean Architecture with `ChangeNotifier`-based ViewModels.
- Use cases for multi-repo orchestration: `RegisterMemberUseCase`,
  `SubmitConsentUseCase`, `LoadWellnessCompletionStatusUseCase`, and all
  event-CRUD use cases.
- `ThemeProvider` co-located with `app_theme.dart` under
  `lib/ui/shared/themes/`.
- `AuditLogViewModel` + `FirestoreAuditLogRepository` introduced to eliminate
  the last direct `FirebaseFirestore.instance` call in the UI layer.

### Changed
- `RadioListTile` usages migrated from deprecated `groupValue`/`onChanged`
  constructor parameters to the `RadioGroup<T>` ancestor widget pattern.

---

## [Unreleased]

### Planned
- Localisation (Zulu, Xhosa) via Flutter `intl` ARB files.
- Integration / widget tests for the wellness onboarding flow.
- Additional `semanticLabel` coverage for form fields and data tables.