# Feature Catalogue

This document describes every feature in the Kenwell Health App, the screens involved, and the user flow.

---

## 1. Authentication

**Screens:** `LoginScreen`, `ForgotPasswordScreen`  
**ViewModel:** `LoginViewModel`, `AuthViewModel`  
**Roles:** All

- Email + password login via Firebase Authentication
- "Forgot password" sends a reset email
- Role is read from Firestore `users/{uid}` after sign-in
- Session persists across app restarts (Firebase Auth token)

---

## 2. Home Dashboard

**Screen:** `HomeScreen`  
**Roles:** All authenticated users

- Role-aware welcome panel
- Quick-access tiles to core workflows (Events, Members, Reports, My Events)
- Connectivity status indicator

---

## 3. Event Management

**Screens:** `AllEventsScreen`, `EventDetailsScreen`, `EventFormScreen`, `EventsListTabView`  
**ViewModels:** `EventViewModel`, `CalendarViewModel`  
**Roles:** Admin, Project Manager, Project Coordinator

### Create / Edit Event
- Fields: title, date, time, venue, province, location, expected attendance, flow steps, status
- Event color is auto-assigned from a deterministic palette via `EventColorHelper`
- Validation enforced before saving

### View Events
- Tab view: All / Scheduled / In Progress / Completed
- Day-group headers (`KenwellEventDayHeader`) group events by date
- Search, status filter, province filter, date range filter (`applyFilters()`)

### Calendar View
- Monthly calendar with event pins
- Tap a date to see events that day

### Event Lifecycle
- **Scheduled → In Progress** (manual or auto-transition when start time reached)
- **In Progress → Completed** (manual via action)

---

## 4. Member Allocation

**Screen:** `AllocateEventScreen`  
**ViewModel:** `AllocateEventViewModel`  
**Roles:** Admin, Project Manager, Project Coordinator

- See all platform users and which are already assigned to an event
- Assign / unassign with a toggle
- Live badge showing assigned count vs total

---

## 5. Member Registration

**Screen:** `MemberRegistrationScreen`  
**ViewModel:** `MemberDetailsViewModel`  
**Use Case:** `RegisterMemberUseCase`  
**Roles:** Health Practitioner, Project Coordinator

### Register new member
1. Capture personal details (name, ID/passport, date of birth, gender, nationality, contact)
2. `RegisterMemberUseCase` writes to:
   - Local SQLite (immediate, fatal — prevents data loss)
   - Firestore `members` collection (non-fatal, queued on failure)
   - Firestore `member_events` collection (non-fatal, queued on failure)

### Member list
- Lists all registered members from Firestore (`LoadMembersUseCase`)
- Search by name, ID number, or passport
- Delete member (`DeleteMemberUseCase` — dual Firestore + local SQLite delete)

---

## 6. Wellness Flow

**Screen:** `WellnessFlowScreen`  
**ViewModel:** `WellnessFlowViewModel`  
**Navigator:** `WellnessNavigator`  
**Roles:** Health Practitioner

The wellness flow is a configurable multi-step guided wizard that walks a health practitioner through every clinical step for a single member at a single event.

### Progress tracking
- Progress bar shows `completedSectionsCount / totalWellnessSections` (4 core sections)
- Each section sets a completion flag when submitted
- `LoadWellnessCompletionStatusUseCase` loads all 6 flags in parallel at startup

### Steps (all optional per-event configuration)
| Step | Use Case | Description |
|---|---|---|
| Member Registration | `RegisterMemberUseCase` | Register or select existing member |
| Consent Form | `SubmitConsentUseCase` | Capture signed informed consent |
| HIV Test | `SubmitHIVScreeningUseCase` | Record HIV screening questionnaire |
| HIV Test Result | `SubmitHIVTestResultUseCase` | Record rapid HIV test result |
| TB Screening | `SubmitTBScreeningUseCase` | Record TB symptom screening |
| Cancer Screening | `SubmitCancerScreeningUseCase` | Pap smear, breast exam, PSA |
| HRA | `SubmitHRAUseCase` | Blood pressure, BMI, glucose, cholesterol |
| Health Metrics | *(ViewModel direct, read-only)* | Capture biometric measurements |
| Nurse Intervention | *(ViewModel)* | Document referrals and nursing actions |
| Survey | `SubmitSurveyUseCase` | Post-screening feedback questionnaire |

---

## 7. Member Search

**Screen:** `MemberSearchScreen`  
**ViewModel:** `MemberSearchViewModel`  
**Use Case:** `SearchMemberUseCase`  
**Roles:** Health Practitioner

- Enter a 13-digit SA ID number or passport number
- `SearchMemberUseCase` determines query type (ID vs passport) and executes the correct Firestore query
- Found member is set as the active member for the wellness flow

---

## 8. Member Events History

**Screen:** `MemberEventsScreen`  
**ViewModel:** `MemberEventsViewModel`  
**Use Case:** `LoadMemberEventReferralsUseCase`  
**Roles:** Health Practitioner, Project Coordinator, Admin

- View all wellness events a member has attended
- Per-event referral outcome card: **Healthy** or **At Risk** with specific risk flags:
  - TB symptoms (cough, blood in sputum, weight loss, night sweats)
  - Cancer findings (pap smear, breast exam, PSA > 4.0)
  - HRA metrics (BMI, blood pressure, blood sugar, cholesterol)

---

## 9. My Events

**Screen:** `MyEventsScreen`  
**ViewModel:** `MyEventViewModel`  
**Use Case:** `LoadUserEventsUseCase`  
**Roles:** Health Practitioner

- Lists events assigned to the currently authenticated user
- Live stream — updates automatically when assignments change
- Auto-transition: events past their start time auto-move to "In Progress"
- Start / Complete event actions
- Tap to enter Wellness Flow for that event

---

## 10. Statistics & Reporting

**Screens:** `StatsReportScreen`, `EventStatsContent`, `HealthScreeningStatsSection`  
**ViewModel:** `StatsReportViewModel`  
**Service:** `EventReportExporter`  
**Roles:** Admin, Top Management, Project Manager, Project Coordinator

### Dashboard metrics (computed by `computeStats()`)
- Total expected vs total screened
- Completed / Scheduled / In Progress counts
- Participation rate (%)
- Events by province (breakdown)

### Filters (`applyFilters()`)
- Tab filter (All / Scheduled / In Progress / Completed)
- Free-text search (event title / venue)
- Status filter
- Province filter
- Date range filter

### Live screening counts
- Per-event counts from HIV, TB, Cancer, HRA Firestore collections

### Export
- PDF report with event summary, screening breakdown, and referral outcomes
- CSV data export for spreadsheet analysis

---

## 11. User Management

**Screen:** `UserManagementScreen`  
**ViewModel:** `UserManagementViewModel`  
**Roles:** Admin

- List all platform users (streamed from Firebase Auth via `getAllUsersStream()`)
- Create new user (email + password + role)
- Edit user role
- Delete user account

---

## 12. Audit Log

**Screen:** `AuditLogScreen`  
**Roles:** Admin

- Read-only chronological log of all significant system actions
- Powered by Firestore `audit_log` collection

---

## 13. Profile

**Screen:** `ProfileScreen`  
**ViewModel:** `ProfileViewModel`  
**Roles:** All

- View own profile (name, email, role)
- Change display name
- Sign out

---

## 14. Help

**Screen:** `HelpScreen`  
**Roles:** All

- In-app help content and FAQ
- Contact / support information

---

## 15. Offline Support

**Service:** `PendingWriteService`, `ConnectivityService`

- Failed Firestore writes (non-fatal) are queued in the local SQLite `pending_writes` table
- `ConnectivityService` listens for network restoration and automatically calls `PendingWriteService.flushPending()`
- Affected operations: member creation (both Firestore collections), consent submission (survey_results), and any use case that uses a non-fatal write pattern
