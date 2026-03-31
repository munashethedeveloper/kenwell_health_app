# Testing Guide

## Overview

Tests live in `test/` and mirror the `lib/` directory structure:

```
test/
  domain/
    usecases/           ← Unit tests for all use cases (8 files)
  ui/
    features/           ← ViewModel unit tests (29 directories)
  *.dart               ← Integration-style event and repository tests
```

All tests use **mocktail** (`^1.0.4`) to mock concrete repository and service classes.

Total: **~350 tests across 41 test files**.

---

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific test file
flutter test test/domain/usecases/register_member_usecase_test.dart

# Run tests matching a name pattern
flutter test --name "RegisterMemberUseCase"
```

CI runs `flutter test --coverage` on every push/PR (see `.github/workflows/flutter_ci.yml`).

---

## Test Structure

### Mocktail Pattern

```dart
// 1. Declare mock
class MockFirestoreMemberRepository extends Mock
    implements FirestoreMemberRepository {}

// 2. Instantiate in setUp()
setUp(() {
  mockRepo = MockFirestoreMemberRepository();
  useCase = DeleteMemberUseCase(firestoreRepository: mockRepo, ...);
});

// 3. Stub
when(() => mockRepo.deleteMember(any())).thenAnswer((_) async {});

// 4. Exercise
await useCase('member-1');

// 5. Verify
verify(() => mockRepo.deleteMember('member-1')).called(1);
```

For non-primitive type arguments, always call `registerFallbackValue(instance)` in `setUp` before the first `any()` use.

---

## Use Case Tests (`test/domain/usecases/`)

| Test File | Class Under Test | Scenarios Covered |
|---|---|---|
| `register_member_usecase_test.dart` | `RegisterMemberUseCase` | All-succeed, local-fail throws, Firestore-fail queues, member-event-fail queues |
| `submit_consent_usecase_test.dart` | `SubmitConsentUseCase` | Saves consent + survey, consent-fail throws, survey-fail is non-fatal |
| `load_wellness_completion_status_usecase_test.dart` | `LoadWellnessCompletionStatusUseCase` | No consent, consent-only, all flags, wrong-event ignored, resilience to partial errors |
| `delete_member_usecase_test.dart` | `DeleteMemberUseCase` | Both succeed, Firestore fail propagates (local not called), local fail propagates |
| `load_members_usecase_test.dart` | `LoadMembersUseCase` | Returns list, empty list, propagates exception |
| `submit_hct_test_result_usecase_test.dart` | `SubmitHCTTestResultUseCase` | Calls repo with correct result, propagates exception |
| `load_user_events_usecase_test.dart` | `LoadUserEventsUseCase` | Resolves IDs, empty user, skips null IDs, skips missing events, skips null events |
| `load_member_event_referrals_usecase_test.dart` | `LoadMemberEventReferralsUseCase` | No events, no-data=null, healthy, at-risk TB, at-risk Cancer, at-risk HRA BP, at-risk BMI, multiple events, null eventId skipped, screening errors swallowed |

### ViewModel Tests (`test/ui/features/`)

| Test File | Class Under Test | Tests |
|---|---|---|
| `event/view_model/event_view_model_test.dart` | `EventViewModel` | 9 |
| `event/view_model/all_events_view_model_test.dart` | `AllEventsViewModel` | 14 |
| `event/view_model/event_details_view_model_test.dart` | `EventDetailsViewModel` | 3 |
| `event/view_model/event_form_view_model_test.dart` | `EventFormViewModel` | 12 |
| `event/view_model/my_event_view_model_test.dart` | `MyEventViewModel` | 7 |
| `event/view_model/allocate_event_view_model_test.dart` | `AllocateEventViewModel` | — |
| `auth/view_model/auth_view_model_test.dart` | `AuthViewModel` | 6 |
| `auth/view_model/login_view_model_test.dart` | `LoginViewModel` | 15 |
| `calendar/view_model/calendar_view_model_test.dart` | `CalendarViewModel` | 22 |
| `cancer/view_model/cancer_view_model_test.dart` | `CancerScreeningViewModel` | 10 |
| `consent_form/view_model/consent_view_model_test.dart` | `ConsentScreenViewModel` | 12 |
| `hct_test/view_model/hct_test_view_model_test.dart` | `HCTTestViewModel` | 9 |
| `hct_test_nursing_intervention/view_model/hct_test_nursing_intervention_view_model_test.dart` | `HCTTestNursingInterventionViewModel` | 15 |
| `hct_test_results/view_model/hct_test_result_view_model_test.dart` | `HCTTestResultViewModel` | 10 |
| `health_metrics/view_model/health_metrics_view_model_test.dart` | `HealthMetricsViewModel` | 11 |
| `health_risk_assessment/view_model/health_risk_assessment_view_model_test.dart` | `PersonalRiskAssessmentViewModel` | 13 |
| `help/view_model/help_screen_view_model_test.dart` | `HelpScreenViewModel` | 5 |
| `member/view_model/member_details_view_model_test.dart` | `MemberDetailsViewModel` | 9 |
| `member/view_model/member_events_view_model_test.dart` | `MemberEventsViewModel` | 10 |
| `nurse_interventions/view_model/nurse_intervention_view_model_test.dart` | `NurseInterventionViewModel` | 14 |
| `profile/view_model/profile_view_model_test.dart` | `ProfileViewModel` | 21 |
| `splash/view_model/splash_view_model_test.dart` | `SplashViewModel` | 6 |
| `stats_report/view_model/stats_report_view_model_test.dart` | `StatsReportViewModel` | 16 |
| `survey/view_model/survey_view_model_test.dart` | `SurveyViewModel` | — |
| `tb_test/view_model/tb_testing_view_model_test.dart` | `TBTestingViewModel` | 12 |
| `tb_test_nursing_intervention/view_model/tb_nursing_intervention_view_model_test.dart` | `TBNursingInterventionViewModel` | 13 |
| `user_management/view_model/user_management_view_model_test.dart` | `UserManagementViewModel` | 11 |
| `wellness/view_model/wellness_flow_view_model_test.dart` | `WellnessFlowViewModel` | 14 |
| `wellness/view_model/member_search_view_model_test.dart` | `MemberSearchViewModel` | 10 |

---

## Writing New Tests

Follow this checklist:

1. **Mirror the source structure**: `lib/domain/usecases/foo.dart` → `test/domain/usecases/foo_test.dart`
2. **Use mocktail**: extend `Mock`, implement the concrete class
3. **Register fallback values** for all non-primitive argument types used with `any()`
4. **Test the happy path first**, then each error branch
5. **Keep tests independent**: each `test()` sets up its own state via `setUp()`
6. **Use descriptive test names** — the name should read as a sentence: `'deletes from Firestore then local when both succeed'`
7. **Do not test Flutter widgets** in the domain/use-case test layer — ViewModel tests are enough at that level

---

## Coverage

Coverage reports are generated with:

```bash
flutter test --coverage
# Produces: coverage/lcov.info
```

CI uploads coverage to **Codecov** automatically on every run using the secret `CODECOV_TOKEN`.

To view coverage locally:
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Key coverage targets:
- All use cases must have tests
- ViewModel state transitions (loading → error / loading → success) must be covered
- Pure methods (`computeStats`, `applyFilters`) must be fully covered