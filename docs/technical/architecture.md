# Architecture — Kenwell Health App

## Overview

The Kenwell Health App follows **Clean Architecture** layered with the **MVVM** UI pattern. The goal is a strict dependency rule: outer layers depend on inner layers; inner layers never import outer layers.

```
┌────────────────────────────────────────────────────┐
│  Presentation (UI)                                  │
│  Screens · Widgets · ViewModels                     │
├────────────────────────────────────────────────────┤
│  Domain                                             │
│  Use Cases · Domain Models · (no framework deps)   │
├────────────────────────────────────────────────────┤
│  Data                                               │
│  Repositories · Services · Local DB · Firebase     │
└────────────────────────────────────────────────────┘
```

---

## Layer: Domain

**Location:** `lib/domain/`

The domain layer contains no Flutter or Firebase imports — only pure Dart. It defines the business rules that every other layer depends on.

### Domain Models (`lib/domain/models/`)

| Model | Description |
|---|---|
| `WellnessEvent` | Core event entity. `isPast` computed getter (completed/finished or date < today) |
| `Member` | Community member. Supports ID number and passport number identification |
| `Consent` | Informed consent record |
| `HivResult` | Clinical HIV rapid test result |
| `HivScreening` | HIV screening questionnaire answers |
| `TbScreening` | TB symptom screening with nursing referral flag |
| `CancerScreening` | Pap smear, breast exam, PSA screening |
| `HraScreening` | Health Risk Assessment — BMI, blood pressure, glucose, cholesterol |
| `MemberEvent` | Attendance record linking a Member to a WellnessEvent |
| `AuditLogEntry` | Immutable audit trail entry |
| `UserModel` | Platform user (staff/client) |
| `User` | Firebase Auth user wrapper |

### Use Cases (`lib/domain/usecases/`)

Use cases are single-responsibility classes with a `call()` method. They exist to:
- Orchestrate multiple repositories when a single action spans more than one data store
- Isolate business rules (e.g. referral derivation, dual-write strategy) from ViewModels
- Serve as the only entry point for multi-repo transactions that are testable without Flutter

See [use_cases.md](use_cases.md) for the full catalogue.

---

## Layer: Data

**Location:** `lib/data/`

### Repositories (`lib/data/repositories_dcl/`)

Repositories are the single access point for a data source. Each repository:
- Has a Firestore-backed implementation that falls back to SQLite on failure
- Returns typed domain model objects (not raw maps)
- Is injected into use cases via constructor parameter (optional with default)

| Repository | Collection / Table |
|---|---|
| `FirestoreMemberRepository` | `members`, SQLite `members` |
| `FirestoreMemberEventRepository` | `member_events` |
| `FirestoreConsentRepository` | `consents` |
| `FirestoreHivScreeningRepository` | `hiv_screenings` |
| `FirestoreHivResultRepository` | `hiv_results` |
| `FirestoreTbScreeningRepository` | `tb_screenings` |
| `FirestoreCancerScreeningRepository` | `cancer_screenings` |
| `FirestoreHraRepository` | `hra_screenings` |
| `FirestoreSurveyRepository` | `survey_results` |
| `EventRepository` | `events` |
| `UserEventRepository` | `user_events` |
| `MemberRepository` | SQLite `members` (local-only) |
| `AuthRepositoryDcl` | Firebase Auth wrapper |

### Services (`lib/data/services/`)

| Service | Responsibility |
|---|---|
| `AuthService` | Firebase Auth current user, sign in / out |
| `FirebaseAuthService` | User CRUD (admin — list, create, delete) |
| `PendingWriteService` | SQLite offline write queue (schema v16) |
| `ConnectivityService` | Network state stream; triggers `flushPending()` |
| `AppPerformance` | Firebase Performance trace wrapper; disabled in debug |
| `UserEventService` | Static helper for adding a user to an event |

### Local Database (`lib/data/local/`)

SQLite via **Drift** ORM. Schema version: 16.  
Tables: `members`, `tb_screenings`, `cancer_screenings`, `hra_screenings`, `hiv_screenings`, `consents`, `pending_writes`.

`AppDatabase` is a singleton (`AppDatabase.instance`). `build_runner` generates the Drift DAO code.

---

## Layer: Presentation (UI)

**Location:** `lib/ui/`

### MVVM Pattern

```
Screen (Widget)  →  ChangeNotifier (ViewModel)  →  UseCase / Repository
     ↑ reads state via Provider / Consumer
```

- **Screens** are stateless widgets that read state from their ViewModel via `context.watch<VM>()` or `Consumer<VM>`.
- **ViewModels** extend `ChangeNotifier`. They hold UI state (loading, error, data lists) and expose async methods that call use cases.
- **Use Cases** are injected into ViewModels as optional constructor parameters with production defaults.
- **No ViewModel** has an inline `= SomeRepo()` field initializer. All dependencies flow in via constructor.

### Dependency Injection

`AppProviders.rootProviders` in `lib/di/app_providers.dart` is the single registration point for all 8 app-lifetime `ChangeNotifierProvider` entries. `main.dart` passes this list to a `MultiProvider`.

Per-screen ViewModels that require route arguments (e.g., `MemberEventsViewModel`, `MyEventViewModel`) are created locally with `ChangeNotifierProvider(create: ...)` at the screen level.

### Navigation

**go_router** (`lib/routing/`) handles all navigation. Routes are named constants. Deep links and auth-guard redirects are implemented as go_router `redirect` callbacks.

### Shared Widgets (`lib/ui/shared/`)

| Widget | Purpose |
|---|---|
| `KenwellEventDayHeader` | Day-group header: accent bar + date + event-count badge |
| `KenwellAppBarActions` | Standardized Refresh + Help AppBar action buttons |

---

## Key Architectural Decisions

### 1. Dual-Write Strategy (Fatal vs Non-Fatal)

`RegisterMemberUseCase` writes to 3 stores:
- **Local SQLite (fatal)** — if this fails, an exception is thrown and the operation is rolled back.
- **Firestore `members` (non-fatal)** — failure is caught, queued to `PendingWriteService`, and retried on reconnect.
- **Firestore `member_events` (non-fatal)** — same.

This ensures data is never lost even when the device is offline.

### 2. Offline Write Queue

`PendingWriteService` stores failed Firestore writes in a `pending_writes` SQLite table. When `ConnectivityService` emits a "connected" event, `flushPending()` retries all queued operations.

### 3. Referral Derivation in Domain

The TB+Cancer+HRA multi-repo referral logic is encapsulated in `LoadMemberEventReferralsUseCase`, not in the ViewModel or widget tree. This means the referral business rules are testable without Flutter.

### 4. Streaming vs One-Shot Fetches

`LoadUserEventsUseCase` exposes both:
- `call(userId)` → `Future<List<WellnessEvent>>` for one-shot load
- `watch(userId)` → `Stream<List<WellnessEvent>>` for real-time updates

ViewModels subscribe to the stream via `StreamSubscription` and cancel it in `dispose()`.

### 5. Performance Monitoring

`AppPerformance.traceAsync<T>()` wraps async operations with Firebase Performance traces. It is **disabled in `kDebugMode`** to avoid noise in development. Instrumented operations: `RegisterMemberUseCase`, `SubmitConsentUseCase`, all `EventViewModel` CRUD methods, and `PendingWriteService.flushPending()`.