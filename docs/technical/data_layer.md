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

### `hiv_screenings`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `hivStatus` | `string` | Known HIV status |
| `onArt` / `adherent` | `string` | ART status |
| `nursingReferral` | `string` | `referredToStateClinic` / `patientNotReferred` |

### `hiv_results`

| Field | Type | Description |
|---|---|---|
| `memberId` / `eventId` | `string` | References |
| `screeningResult` | `string` | `Negative` / `Positive` / `Indeterminate` |
| `windowPeriod` | `string` | Window period counselling flag |
| `nursingReferral` | `string` | Referral outcome |
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

### `audit_log`

| Field | Type | Description |
|---|---|---|
| `action` | `string` | Action performed |
| `performedBy` | `string` | UID of actor |
| `targetId` | `string` | Affected document ID |
| `timestamp` | `timestamp` | When the action occurred |

---

## SQLite Schema (Drift)

**File:** `lib/data/local/app_database.dart` — schema version **16**

| Table | Columns | Purpose |
|---|---|---|
| `members` | id, name, surname, idDocumentType, idNumber, passportNumber, dateOfBirth, gender, nationality, contactNumber, createdAt | Offline member cache |
| `tb_screenings` | id, memberId, eventId, + all clinical fields | Offline TB data |
| `cancer_screenings` | id, memberId, eventId, + all clinical fields | Offline cancer data |
| `hra_screenings` | id, memberId, eventId, + all clinical fields | Offline HRA data |
| `hiv_screenings` | id, memberId, eventId, + all clinical fields | Offline HIV data |
| `consents` | id, memberId, eventId, signatureData, consentGiven, createdAt | Offline consent data |
| `pending_writes` | id, collection, documentId, data (JSON), createdAt, retryCount | Offline write queue |

Code is generated by `build_runner` (`dart run build_runner build`).

---

## Offline Write Queue

**Service:** `lib/data/services/pending_write_service.dart`

When a non-fatal Firestore write fails (e.g. no connectivity), `PendingWriteService.enqueue()` stores the payload in the local `pending_writes` SQLite table.

On reconnect, `ConnectivityService` emits a connected event and calls `PendingWriteService.flushPending()`, which retries each queued write in insertion order. Successfully flushed writes are deleted; failed retries increment `retryCount` (up to a configurable max).

**Affected operations:**
- `RegisterMemberUseCase` — both Firestore writes (members + member_events)
- `SubmitConsentUseCase` — survey_results write

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