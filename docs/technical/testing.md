# Testing Guide

## Overview

Tests live in `test/` and mirror the `lib/` directory structure:

```
test/
  domain/
    usecases/           ← Unit tests for all use cases
  ui/
    features/           ← ViewModel unit tests
```

All tests use **mocktail** (`^1.0.4`) to mock concrete repository and service classes.

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
| `submit_hiv_test_result_usecase_test.dart` | `SubmitHIVTestResultUseCase` | Calls repo with correct result, propagates exception |
| `load_user_events_usecase_test.dart` | `LoadUserEventsUseCase` | Resolves IDs, empty user, skips null IDs, skips missing events, skips null events |
| `load_member_event_referrals_usecase_test.dart` | `LoadMemberEventReferralsUseCase` | No events, no-data=null, healthy, at-risk TB, at-risk Cancer, at-risk HRA BP, at-risk BMI, multiple events, null eventId skipped, screening errors swallowed |

### ViewModel Tests (`test/ui/features/`)

| Test File | Class Under Test | Mock Strategy |
|---|---|---|
| `event/view_model/event_view_model_test.dart` | `EventViewModel` | `MockEventRepository` + mock use cases (9 tests) |
| `hiv_test/view_model/hiv_test_view_model_test.dart` | `HIVTestViewModel` | Mock repos (fully covered) |
| `stats_report/view_model/stats_report_view_model_test.dart` | `StatsReportViewModel` | No mocking needed — pure method tests (14 tests) |
| `user_management/view_model/user_management_view_model_test.dart` | `UserManagementViewModel` | `MockFirebaseAuthService` + `StreamController` (10 tests) |

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