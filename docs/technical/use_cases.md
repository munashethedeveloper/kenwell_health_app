# Use Cases Reference

The Kenwell Health App has **19 use cases** in `lib/domain/usecases/`. All are callable classes with a `call()` method (or named methods for complex cases).

> **Note:** The HIV-related use cases and terminology were renamed to **HCT** (HIV Combined Test) throughout the codebase to align with clinical workflows.

---

## Member Management

### `RegisterMemberUseCase`
**File:** `register_member_usecase.dart`  
**Repositories:** `MemberRepository` (SQLite), `FirestoreMemberRepository`, `FirestoreMemberEventRepository`  
**Returns:** `Member`

Orchestrates member creation across three stores:
1. Creates the member in local SQLite (**fatal** — throws on failure).
2. Writes to Firestore `members` (**non-fatal** — queued to `PendingWriteService` on failure).
3. Writes to Firestore `member_events` (**non-fatal** — queued).

Performance-traced via `AppPerformance.traceAsync`.

---

### `DeleteMemberUseCase`
**File:** `delete_member_usecase.dart`  
**Repositories:** `FirestoreMemberRepository`, `MemberRepository`  

Deletes a member from Firestore then from local SQLite. Both are fatal — any failure propagates.

---

### `LoadMembersUseCase`
**File:** `load_members_usecase.dart`  
**Repositories:** `FirestoreMemberRepository`  
**Returns:** `List<Member>`

Thin wrapper around `FirestoreMemberRepository.fetchAllMembers()`. The repository handles the Firestore → local-cache fallback automatically.

---

### `SearchMemberUseCase`
**File:** `search_member_usecase.dart`  
**Repositories:** `FirestoreMemberRepository`  
**Returns:** `Member?`

Detects whether the query is a 13-digit SA ID or a passport number and executes the appropriate Firestore query.

---

## Event Management

### `AddEventUseCase`
**File:** `add_event_usecase.dart`  
**Repositories:** `EventRepository`  
**Returns:** `void`

Creates a new `WellnessEvent` in Firestore.

---

### `UpdateEventUseCase`
**File:** `update_event_usecase.dart`  
**Repositories:** `EventRepository`  
**Returns:** `void`

Updates an existing `WellnessEvent` in Firestore.

---

### `DeleteEventUseCase`
**File:** `delete_event_usecase.dart`  
**Repositories:** `EventRepository`  
**Returns:** `void`

Deletes a `WellnessEvent` from Firestore.

---

### `GetEventsUseCase`
**File:** `get_events_usecase.dart`  
**Repositories:** `EventRepository`  
**Returns:** `List<WellnessEvent>`

Fetches all events. Used by `EventViewModel` as a stream source.

---

### `UpsertEventUseCase`
**File:** `upsert_event_usecase.dart`  
**Repositories:** `EventRepository`  
**Returns:** `void`

Creates or updates an event (used for status transitions like in-progress / completed).

---

### `LoadUserEventsUseCase`
**File:** `load_user_events_usecase.dart`  
**Repositories:** `UserEventRepository`, `EventRepository`  
**Returns:** `Future<List<WellnessEvent>>` (one-shot), `Stream<List<WellnessEvent>>` (streaming via `watch()`)

Two-step resolution: fetches `user_events` records for a userId, extracts event IDs, then fetches the full `WellnessEvent` for each. Null/missing events are silently dropped.

---

## Wellness Screening

### `SubmitConsentUseCase`
**File:** `submit_consent_usecase.dart`  
**Repositories:** `FirestoreConsentRepository`, `FirestoreSurveyRepository`  
**Returns:** `void`

Saves consent to Firestore (**fatal**) and writes the survey-data snapshot to `survey_results` (**non-fatal**). Owns the consent → survey-data mapping. Performance-traced.

---

### `SubmitHCTScreeningUseCase`
**File:** `submit_hct_screening_usecase.dart`  
**Repositories:** `FirestoreHctScreeningRepository`  
**Returns:** `void`

Saves the HCT (HIV Combined Test) screening questionnaire answers.

---

### `SubmitHCTTestResultUseCase`
**File:** `submit_hct_test_result_usecase.dart`  
**Repositories:** `FirestoreHctResultRepository`  
**Returns:** `void`

Saves the clinical HCT (HIV Combined Test) rapid test result, including nurse details, counselling notes, and follow-up information.

---

### `SubmitTBScreeningUseCase`
**File:** `submit_tb_screening_usecase.dart`  
**Repositories:** `FirestoreTbScreeningRepository`  
**Returns:** `void`

Saves TB symptom screening answers.

---

### `SubmitCancerScreeningUseCase`
**File:** `submit_cancer_screening_usecase.dart`  
**Repositories:** `FirestoreCancerScreeningRepository`  
**Returns:** `void`

Saves pap smear, breast exam, and PSA screening results.

---

### `SubmitHRAUseCase`
**File:** `submit_hra_usecase.dart`  
**Repositories:** `FirestoreHraRepository`  
**Returns:** `void`

Saves Health Risk Assessment data (BMI, blood pressure, blood sugar, cholesterol).

---

### `SubmitSurveyUseCase`
**File:** `submit_survey_usecase.dart`  
**Repositories:** `FirestoreSurveyRepository`  
**Returns:** `void`

Saves post-screening survey results.

---

### `LoadWellnessCompletionStatusUseCase`
**File:** `load_wellness_completion_status_usecase.dart`  
**Repositories:** `FirestoreConsentRepository`, `FirestoreHctScreeningRepository`, `FirestoreTbScreeningRepository`, `FirestoreCancerScreeningRepository`, `FirestoreHraRepository`, `FirestoreSurveyRepository`  
**Returns:** `WellnessCompletionStatus`

Loads all wellness completion flags in parallel via `Future.wait<bool>`. Returns a `WellnessCompletionStatus` value object containing `hctEnabled`/`hctCompleted`, `tbEnabled`/`tbCompleted`, `cancerEnabled`/`cancerCompleted`, `hraEnabled`/`hraCompleted`, and `surveyCompleted`. Used by `WellnessFlowViewModel` at startup to restore progress.

---

### `LoadMemberEventReferralsUseCase`
**File:** `load_member_event_referrals_usecase.dart`  
**Repositories:** `FirestoreMemberRepository`, `FirestoreTbScreeningRepository`, `FirestoreCancerScreeningRepository`, `FirestoreHraRepository`  
**Returns:** `MemberEventReferrals`

1. Fetches the member's event attendance records.
2. Loads TB, Cancer, and HRA screening data in parallel.
3. Derives an `EventReferralSummary` per event (status: `healthy` / `at_risk` / `null`, plus a list of specific risk flags).

**Risk flag rules:**
- TB: `nursingReferral == 'referredToStateClinic'` → flags specific symptoms
- Cancer: `nursingReferral == 'referredToStateClinic'` → flags pap smear, breast exam, PSA > 4.0
- HRA: BMI < 18.5 or ≥ 30.0, systolic BP ≥ 140, diastolic ≥ 90, blood sugar ≥ 7.0, cholesterol ≥ 5.2

---

## Use Case Usage Map

| ViewModel | Use Cases Injected |
|---|---|
| `EventViewModel` | `AddEventUseCase`, `UpdateEventUseCase`, `DeleteEventUseCase`, `GetEventsUseCase`, `UpsertEventUseCase` |
| `MemberDetailsViewModel` | `RegisterMemberUseCase`, `DeleteMemberUseCase`, `LoadMembersUseCase` |
| `MemberSearchViewModel` | `SearchMemberUseCase` |
| `MemberEventsViewModel` | `LoadMemberEventReferralsUseCase` |
| `ConsentScreenViewModel` | `SubmitConsentUseCase` |
| `HCTTestViewModel` | `SubmitHCTScreeningUseCase` |
| `HCTTestResultViewModel` | `SubmitHCTTestResultUseCase` |
| `TBTestingViewModel` | `SubmitTBScreeningUseCase` |
| `CancerScreeningViewModel` | `SubmitCancerScreeningUseCase` |
| `PersonalRiskAssessmentViewModel` | `SubmitHRAUseCase` |
| `SurveyViewModel` | `SubmitSurveyUseCase` |
| `WellnessFlowViewModel` | `LoadWellnessCompletionStatusUseCase` |
| `MyEventViewModel` | `LoadUserEventsUseCase` |