# Data Layer

## Overview

The data layer sits between the domain (use cases) and the external world (Firebase, SQLite). It provides typed access to all data sources via Repository and Service classes.

```
Domain (Use Cases)
       ↓ injects
Repositories ──┬──→ Firestore (Cloud)
               └──→ SQLite via Drift (Local)
Services ──────────→ Firebase Auth / Performance / Crashlytics
```

---

## Firestore Schema

### `events`

| Field | Type | Description |
|---|---|---|
| `id` | `string` | Auto-generated UUID |
| `title` | `string` | Event name |
| `date` | `timestamp` | Event date |
| `venue` | `string` | Venue name |
| `address` | `string` | Street address |
| `townCity` | `string` | Town / city |
| `province` | `string` | South African province |
| `status` | `string` | `scheduled` / `in_progress` / `completed` |
| `expectedParticipation` | `string` | Target attendee count |
| `servicesRequested` | `array` | Flow step identifiers |
| `nurses` / `coordinators` | `array` | Assigned staff UIDs |
| `onsiteContact*` / `aeContact*` | `string` | Contact details |
| `setUpTime` / `startTime` / `endTime` / `strikeDownTime` | `string` | Time fields |

### `members`

| Field | Type | Description |
|---|---|---|
| `id` | `string` | UUID |
| `name` / `surname` | `string` | Legal name |
| `idDocumentType` | `string` | `'ID'` or `'Passport'` |
| `idNumber` / `passportNumber` | `string` | Identity document number |
| `dateOfBirth` | `timestamp` | Date of birth |
| `gender` | `string` | Gender |
| `nationality` | `string` | Nationality |
| `contactNumber` | `string` | Phone number |
| `createdAt` | `timestamp` | Record created timestamp |

### `member_events`

| Field | Type | Description |
|---|---|---|
| `memberId` | `string` | Reference to `members.id` |
| `eventId` | `string` | Reference to `events.id` |
| `eventTitle` | `string` | Denormalised event title |
| `eventDate` / `eventVenue` | `string` | Denormalised event details |

### `user_events`

| Field | Type | Description |
|---|---|---|
| `userId` | `string` | Firebase Auth UID |
| `eventId` | `string` | Reference to `events.id` |

### `consents`

| Field | Type | Description |
|---|---|---|
| `memberId` | `string` | Member reference |
| `eventId` | `string` | Event reference |
| `signatureData` | `string` | Base64-encoded signature image |
| `consentGiven` | `bool` | Whether consent was given |
| `createdAt` | `timestamp` | Submission time |

### `hct_screenings`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `firstHctTest` | `string` | First-ever HCT test flag (`yes` / `no`) |
| `lastTestMonth` / `lastTestYear` | `string` | Month/year of most recent previous test |
| `lastTestResult` | `string` | Result of most recent previous test |
| `sharedNeedles` | `string` | Risk behaviour: shared needles |
| `unprotectedSex` | `string` | Risk behaviour: unprotected sex |
| `treatedSTI` | `string` | Risk behaviour: treated STI |
| `knowPartnerStatus` | `string` | Awareness of partner HIV status |
| `createdAt` / `updatedAt` | `string` | Lifecycle timestamps (ISO-8601) |

### `hct_results`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `screeningTestName` | `string` | Test kit name |
| `screeningBatchNo` | `string` | Test kit batch number |
| `screeningExpiryDate` | `string` | Test kit expiry date |
| `screeningResult` | `string` | `Negative` / `Positive` / `Indeterminate` |
| `expectedResult` | `string` | Pre-test expected result |
| `windowPeriod` | `string` | Window period counselling flag |
| `difficultyDealingResult` | `string` | Psychosocial: difficulty dealing with result |
| `urgentPsychosocial` | `string` | Urgent psychosocial support needed |
| `committedToChange` | `string` | Committed to behaviour change |
| `followUpLocation` / `followUpOther` / `followUpDate` | `string` | Follow-up details |
| `nursingReferral` | `string` | Referral outcome |
| `notReferredReason` | `string` | Reason not referred |
| `nurseFirstName` / `nurseLastName` | `string` | Nurse identity |
| `rank` / `sancNumber` / `nurseDate` | `string` | Nurse registration details |
| `signatureData` | `string` | Nurse signature |

### `tb_screenings`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `coughTwoWeeks` / `bloodInSputum` / `weightLoss` / `nightSweats` | `string` | Symptom flags (`'yes'`/`'no'`) |
| `nursingReferral` | `string` | Referral outcome |

### `cancer_screenings`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `papSmearResults` | `string` | Pap smear outcome |
| `breastLightExamFindings` | `string` | CBE findings |
| `psaResults` | `string` | PSA level (numeric string) |
| `nursingReferral` | `string` | Referral outcome |

### `hra_screenings`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `bmi` | `string` | BMI value (numeric string) |
| `bloodPressureSystolic` / `bloodPressureDiastolic` | `string` | BP readings |
| `bloodSugar` | `string` | Fasting glucose (mmol/L) |
| `cholesterol` | `string` | Total cholesterol (mmol/L) |
| `nursingReferral` | `string` | Referral outcome |
| `chronicConditions` | `map<string, bool>` | Named condition flags |

### `survey_results`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `type` | `string` | Survey type identifier |
| Various answer fields | `string` | Question-specific answers |

### `users`

| Field | Type | Description |
|---|---|---|
| `uid` | `string` | Firebase Auth UID |
| `email` | `string` | User email |
| `displayName` | `string` | Display name |
| `role` | `string` | RBAC role (case-insensitive) |
| `fcmTokens` | `array<string>` | FCM push notification tokens |

### `audit_logs`

| Field | Type | Description |
|---|---|---|
| `action` | `string` | `create` / `update` / `delete` |
| `collection` | `string` | Firestore collection affected |
| `documentId` | `string` | Affected document ID |
| `performedBy` | `string` | UID of actor |
| `summary` | `string` | Human-readable description |
| `newData` / `previousData` | `map` | Before/after field snapshot |
| `timestamp` | `timestamp` | When the action occurred |

### `wellness_sessions`

| Field | Type | Description |
|---|---|---|
| `eventId` | `string` | Reference to `events.id` |
| `nurseUserId` | `string` | UID of the nurse conducting the session |
| `participantId` | `string` | Reference to `participants.id` |
| `status` | `string` | `in_progress` / `completed` |
| `completedSteps` | `array<string>` | Steps completed (e.g. `consent`, `hct_test`, `survey`) |
| `consent` / `hctTest` / `hctResults` / `tbTest` / `riskAssessment` / `survey` | `map` | Step data snapshots |
| `memberDetails` / `personalDetails` | `map` | Participant identity data |
| `createdAt` / `updatedAt` / `completedAt` | `timestamp` | Lifecycle timestamps |

### `participants`

| Field | Type | Description |
|---|---|---|
| `sessionId` | `string` | Reference to `wellness_sessions.id` |
| Various identity fields | `string` | Name, ID number, contact, etc. |
| `createdAt` / `updatedAt` | `timestamp` | Record timestamps |

---

## SQLite Schema (Drift)

**File:** `lib/data/local/app_database.dart` — schema version **17**

| Table | Columns | Purpose |
|---|---|---|
| `members` | id, name, surname, idDocumentType, idNumber, passportNumber, dateOfBirth, gender, nationality, contactNumber, createdAt | Offline member cache |
| `tb_screenings` | id, memberId, eventId, + all clinical fields | Offline TB data |
| `cancer_screenings` | id, memberId, eventId, + all clinical fields | Offline cancer data |
| `hra_screenings` | id, memberId, eventId, + all clinical fields | Offline HRA data |
| `hct_screenings` | id, memberId, eventId, + all clinical fields | Offline HCT data |
| `consents` | id, memberId, eventId, signatureData, consentGiven, createdAt | Offline consent data |
| `pending_writes` | id, collection, documentId, data (JSON), createdAt, retryCount | Offline write queue |

**Raw SQL offline-cache tables** (not Drift-managed):

| Table | Purpose |
|---|---|
| `cached_hct_screenings` | Local cache of HCT screening records keyed by member and event |
| `cached_hct_results` | Local cache of HCT result records keyed by member and event |

> **Migration note:** Schema v17 renamed `cached_hiv_screenings` → `cached_hct_screenings` and `cached_hiv_results` → `cached_hct_results` to match the HCT service rename.

---

## Offline Write Queue

**Service:** `lib/data/services/pending_write_service.dart`

When a non-fatal Firestore write fails (e.g. no connectivity), `PendingWriteService.enqueue()` stores the payload in the local `pending_writes` SQLite table.

On reconnect, `ConnectivityService` emits a connected event and calls `PendingWriteService.flushPending()`, which retries each queued write in insertion order. Successfully flushed writes are deleted; failed retries increment `retryCount` (up to a configurable max).

**Affected operations:**
- `RegisterMemberUseCase` — both Firestore writes (members + member_events)
- `SubmitConsentUseCase` — survey_results write

---

## Audit Logging

**Service:** `lib/data/services/audit_log_service.dart`

`AuditLogService` writes immutable entries to the `audit_logs` Firestore collection. Every mutating repository method (create, update, delete) calls one of the convenience helpers (`logCreate`, `logUpdate`, `logDelete`). Logging is fire-and-forget — failures are silently swallowed so they never block the primary operation.

Audit entries include the collection, document ID, actor UID, a human-readable summary, and optional before/after data snapshots.

---

## Wellness Sessions

**Service:** `lib/data/services/wellness_session_service.dart`

`WellnessSessionService` manages the lifecycle of a wellness session — the container that links a nurse, an event, and a participant for a single screening encounter. Sessions are stored in the `wellness_sessions` Firestore collection with participant details in a separate `participants` collection.

Session steps tracked: `consent`, `member_registration`, `personal_details`, `risk_assessment`, `hct_test`, `hct_results`, `tb_test`, `survey`.

---

## Security Rules

**File:** `firestore.rules`

All Firestore access requires `isAuthenticated()`. Role-based access is enforced server-side via helper functions:

| Function | Roles |
|---|---|
| `isAdmin()` | Admin only |
| `isTopManager()` | Top Management only |
| `isProjectManager()` | Project Manager only |
| `isCoordinator()` | Project Coordinator only |
| `isPractitioner()` | Health Practitioner only |
| `isStaff()` | Admin ∪ Top Management ∪ PM ∪ Coordinator ∪ Practitioner |
| `isManagement()` | Admin ∪ Top Management ∪ PM |

Role comparison is case-insensitive (`getUserRole()` calls `.lower()`).