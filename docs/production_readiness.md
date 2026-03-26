# Production Readiness Assessment

**Date:** March 2026  
**Branch:** `copilot/fix-event-logic-issues`  
**Overall Production Readiness:** ~75%

---

## Summary Score Card

| Area | Score | Status |
|---|---|---|
| Architecture & Clean Code | 95% | ✅ Excellent |
| CI/CD Pipeline | 90% | ✅ Ready |
| Security & Auth | 80% | 🟡 Mostly good, 1 gap |
| Test Coverage | 55% | 🟡 Domain covered, UI under-tested |
| Error Handling & Resilience | 80% | 🟡 Good, missing widget-level guards |
| Data / PII Compliance | 65% | 🟡 Rules in place, no data classification |
| Feature Completeness | 85% | 🟡 Minor gaps (push notifications, i18n) |
| Performance | 80% | 🟡 Traced, no widget profiling |
| Documentation | 95% | ✅ Excellent |
| Observability | 70% | 🟡 Crashlytics + Perf, no uptime/alerting |
| **Overall** | **~75%** | **🟡 Beta-ready, not yet fully prod** |

---

## ✅ What Is Complete (Production-Quality)

### Architecture
- Clean Architecture with strict layer separation (domain → data → UI)
- All 19 use cases extracted into `lib/domain/usecases/`
- All 29 ViewModels use constructor dependency injection — zero inline `= SomeRepo()` initialisers (one exception: `ProfileViewModel`, see below)
- Offline write queue (`PendingWriteService`) handles non-fatal Firestore failures
- Streaming via `LoadUserEventsUseCase.watch()` with proper `StreamSubscription` lifecycle management

### CI/CD
- Full CI pipeline: `pub get → build_runner → format → analyze → test --coverage → codecov`
- Firebase Hosting auto-deploy on push to `main/master`
- PR preview channels via Firebase Hosting
- ProGuard enabled for Android release builds

### Security & Authentication
- Email verification enforcement in `LoginViewModel`
- Client-side brute-force lockout (counter + timeout)
- Firestore security rules cover all 12 collections with role-based access
- Role comparison is case-insensitive (`getUserRole().lower()`)
- Audit log is immutable (update/delete permanently blocked in rules)
- Firebase Auth is the single authentication source of truth

### Testing
- 90 unit tests across 12 test files
- All 8 domain use cases with complex logic are tested
- `StatsReportViewModel` pure methods (`computeStats`, `applyFilters`) — 14 tests
- `EventViewModel`, `HIVTestViewModel`, `UserManagementViewModel` — fully covered

### Observability
- Firebase Crashlytics captures uncaught exceptions in release builds
- Firebase Performance traces around all critical async paths
- `AppPerformance.traceAsync` disabled in `kDebugMode` (no debug noise)

### Documentation
- Complete business docs (overview, features, roles)
- Complete technical docs (architecture, use cases, data layer, testing, deployment)

---

## 🟡 What Is Missing / Needs Work Before Full Production

### 1. One ViewModel Still Has Inline Repo Instantiation *(Medium)*
**File:** `lib/ui/features/profile/view_model/profile_view_model.dart:9`  
`final AuthRepository _authRepository = AuthRepository();`  
This bypasses constructor DI, making the ViewModel untestable. Refactor to optional constructor param with default.

### 2. Test Coverage Gap — 21 ViewModels Have No Tests *(High)*
Only 4 feature directories have ViewModel tests (`event`, `hiv_test`, `stats_report`, `user_management`). The following 21 ViewModels have **zero test coverage**:

| ViewModel | Feature |
|---|---|
| `LoginViewModel` | auth |
| `AuthViewModel` | auth |
| `SplashViewModel` | splash |
| `ProfileViewModel` | profile |
| `CalendarViewModel` | calendar |
| `WellnessFlowViewModel` | wellness |
| `ConsentScreenViewModel` | consent_form |
| `CancerScreeningViewModel` | cancer |
| `TBTestingViewModel` | tb_test |
| `PersonalRiskAssessmentViewModel` | health_risk_assessment |
| `HIVTestResultViewModel` | hiv_test_results |
| `NurseInterventionViewModel` | nurse_interventions |
| `HIVTestNursingInterventionViewModel` | hiv_test_nursing_intervention |
| `TBNursingInterventionViewModel` | tb_test_nursing_intervention |
| `MemberDetailsViewModel` | member |
| `MemberSearchViewModel` | member |
| `MemberEventsViewModel` | member |
| `MyEventViewModel` | event |
| `AllocateEventViewModel` | event |
| `HealthMetricsViewModel` | health_metrics |
| `HelpScreenViewModel` | help |

**Priority:** Start with `LoginViewModel` (auth), `WellnessFlowViewModel`, `ConsentScreenViewModel`, and `CancerScreeningViewModel`.

### 3. No Push Notifications *(Medium)*
The home screen `HomeNotificationsSection` contains a comment:  
> *"For push notifications, integrate Firebase Cloud Messaging and store records in a `notifications/{uid}` Firestore subcollection."*  
Firebase Cloud Messaging (FCM) is not integrated. Nurses and coordinators cannot receive real-time event alerts or assignment notifications.

### 4. No Internationalisation / Localisation *(Low–Medium)*
The app is English-only. South Africa has 11 official languages. For a community health app, at least Zulu, Xhosa, and Afrikaans support would significantly improve community member accessibility.

### 5. Personal Data Not Encrypted at Rest *(Medium — POPIA Compliance)*
SA ID numbers, passport numbers, dates of birth, and HIV results are stored in plain text in Firestore and local SQLite. South Africa's Protection of Personal Information Act (POPIA) requires that personal information be processed lawfully and stored securely. Consider:
- Firestore-level encryption (Google manages at-rest, but field-level encryption for PII is best practice)
- SQLite column encryption for `idNumber`, `passportNumber`, `dateOfBirth` in Drift
- A data classification policy in the documentation

### 6. No Input Sanitisation Layer *(Low–Medium)*
Free-text fields (names, addresses, note fields) lack explicit sanitisation before writing to Firestore. While Firestore security rules validate authentication/authorisation, they do not validate field content. A `SanitisationHelper` utility that trims, normalises whitespace, and escapes special characters would be a good addition.

### 7. No Automated UI / Integration Tests *(Low)*
There are no `flutter_test` widget tests or integration tests. Screenings and consent flows are high-stakes — a broken submit button could result in data loss. A small suite of integration tests using `integration_test` / Firebase Emulator would provide a safety net.

### 8. No Error Boundary / Global Error Widget *(Low)*
Unhandled widget build errors are caught by Crashlytics, but the user sees Flutter's red screen in release builds. A `MaterialApp.builder` wrapping a custom `ErrorWidget.builder` would show a branded "Something went wrong" screen instead.

### 9. App Version Not Surfaced to Users *(Low)*
`version: 1.0.0+1` in `pubspec.yaml` — no version display in the app Settings/About screen. Users and support teams cannot identify which version is installed.

### 10. No Firestore Composite Index Coverage Verification *(Low)*
`firestore.indexes.json` may be missing indexes for common query patterns (e.g. `member_events WHERE memberId = X ORDER BY createdAt DESC`). Missing indexes cause runtime exceptions in production Firestore.

---

## Future Considerations & Roadmap Suggestions

### Near-Term (Next 1–2 Sprints)
1. **Fix `ProfileViewModel` DI** — 30-minute change, unblocks testing
2. **Write `LoginViewModel` tests** — auth is the most security-sensitive path
3. **FCM push notifications** — assign `firebase_messaging` package, store tokens in `users/{uid}/fcmTokens`, send notifications on event allocation
4. **`WellnessFlowViewModel` tests** — it manages multi-step consent + screening progress

### Medium-Term (Next Quarter)
5. **POPIA data audit** — classify fields as PII, add field-level encryption or masking where required
6. **Integration test suite** — cover the consent form → HIV screening → TB → HRA → survey end-to-end flow using the Firebase Emulator
7. **Input sanitisation** — add a `SanitisationHelper` used in all use cases before writing to Firestore
8. **Error boundary widget** — custom `ErrorWidget.builder` in `main.dart`
9. **Zulu/Xhosa/Afrikaans localisation** — at minimum translate member-facing screens

### Long-Term (Post-Launch)
10. **Multi-tenancy** — if Kenwell runs events for multiple organisations, add an `orgId` dimension to all Firestore collections and security rules
11. **Offline-first full sync** — currently only writes are queued; extend `PendingWriteService` to queue read misses too, or adopt Firestore offline persistence directly
12. **Analytics dashboard** — use Firebase Analytics custom events to track screening completion rates, drop-off points in the wellness flow, and event attendance patterns
13. **Role-based data export** — the `EventReportExporter` (CSV/PDF) only works for Stats users; extend to allow coordinators to export per-event member lists
14. **API rate limiting / abuse protection** — currently brute-force protection is client-side only; a Firebase Functions rate-limiter would close the server-side gap
15. **Automated POPIA/HIPAA compliance report** — generate a monthly data-processing activity record from the audit log

---

## Go/No-Go Checklist

Before declaring production-ready, verify:

- [ ] `ProfileViewModel` refactored to constructor DI
- [ ] `LoginViewModel` and `WellnessFlowViewModel` have unit tests
- [ ] Firebase Emulator used to verify all Firestore security rules pass
- [ ] All Firestore composite indexes added to `firestore.indexes.json` and deployed
- [ ] POPIA data classification completed and documented
- [ ] App version displayed in Settings/About screen
- [ ] FCM tokens stored and event-assignment notifications working
- [ ] Custom `ErrorWidget.builder` configured in `main.dart`
- [ ] QA sign-off on the full wellness screening flow (consent → HIV → TB → HRA → survey)
- [ ] Release keystore securely stored (not on developer machines)
