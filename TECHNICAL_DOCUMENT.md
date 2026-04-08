# Kenwell Health App — Technical Document

> **Version:** 1.0.0+1  
> **Date:** March 2026  
> **Prepared for:** Kenwell Health  
> **Document type:** Internal Technical Reference

---

## Table of Contents

1. [Application Overview](#1-application-overview)
2. [Technologies Used](#2-technologies-used)
3. [System Architecture](#3-system-architecture)
4. [Application Layers](#4-application-layers)
5. [Database Design](#5-database-design)
6. [Firestore Collections](#6-firestore-collections)
7. [Role-Based Access Control & Security](#7-role-based-access-control--security)
8. [Navigation & Routing](#8-navigation--routing)
9. [Features Walkthrough](#9-features-walkthrough)
10. [Workflow Diagrams](#10-workflow-diagrams)
11. [UI & Theming](#11-ui--theming)
12. [Offline Support Strategy](#12-offline-support-strategy)
13. [Pending Items & Known Gaps](#13-pending-items--known-gaps)
14. [Future Recommendations](#14-future-recommendations)
15. [Glossary](#15-glossary)

---

## 1. Application Overview

**Kenwell Health App** is a cross-platform Flutter application built for healthcare wellness event management and health screening. It enables Kenwell Health teams to plan and execute corporate wellness day events, register participants (members), collect informed consent, perform a battery of health screenings (HRA, HCT, TB, Cancer), and generate statistical reports — all with a clean role-based permission model.

### Core Purpose

| Capability | Description |
|---|---|
| Event Management | Create, schedule, allocate, start, and complete wellness events |
| Member Registration | Register participants at an event using SA ID or Passport |
| Health Screenings | Conduct HRA, HCT, TB, and Cancer screenings per participant |
| Nursing Interventions | Record nurse referrals and clinical follow-up decisions |
| Reporting & Statistics | View live screening counts and historical event stats |
| User Management | Manage practitioner and coordinator accounts with roles |

### Supported Platforms

The app targets **Android**, **iOS**, and **Web** (Flutter Web). Windows desktop support is present in the build configuration but is flagged as incomplete in comments (Firebase C++ SDK dependency).

---

## 2. Technologies Used

### Framework

| Technology | Version | Purpose |
|---|---|---|
| Flutter | SDK ≥ 3.2.0 < 4.0.0 | Cross-platform UI framework |
| Dart | ≥ 3.2.0 | Programming language |

### Backend & Cloud

| Technology | Version | Purpose |
|---|---|---|
| Firebase Core | ^4.2.0 | Firebase initialisation |
| Firebase Auth | ^6.1.1 | User authentication (email/password) |
| Cloud Firestore | ^6.0.3 | Primary cloud database |

### Local Database

| Technology | Version | Purpose |
|---|---|---|
| Drift (moor) | ^2.21.0 | Type-safe SQLite ORM (local cache) |
| drift_flutter | ^0.2.7 | Platform-specific SQLite connection helper |
| sqlite3_flutter_libs | ^0.5.40 | SQLite native binaries |

### State Management

| Technology | Version | Purpose |
|---|---|---|
| Provider | ^6.1.5 | ViewModel-based state management (MVVM) |

### Navigation

| Technology | Version | Purpose |
|---|---|---|
| go_router | ^14.6.2 | Declarative routing with deep linking and auth guards |

### UI & UX

| Technology | Version | Purpose |
|---|---|---|
| google_fonts | ^6.2.1 | Typography (custom brand fonts) |
| flutter_animate | ^4.5.2 | Declarative animations |
| fl_chart | ^1.1.1 | Charts for statistics (bar, line, pie) |
| table_calendar | ^3.2.0 | Monthly calendar widget |
| sizer | ^2.0.15 | Responsive layout sizing |
| flutter_slidable | ^3.1.1 | Swipe-to-action list items |
| signature | ^6.3.0 | Nurse digital signature capture |
| dropdown_search | ^6.0.2 | Searchable dropdown selects |
| flutter_spinbox | ^0.13.1 | Numeric spin-box inputs |
| intl_phone_field | ^3.2.0 | International phone number input |
| fluttertoast | ^9.0.0 | Toast notifications |

### Utilities

| Technology | Version | Purpose |
|---|---|---|
| intl | 0.20.2 | Date/number formatting, localisation |
| uuid | ^4.5.2 | UUID v4 generation for entity IDs |
| shared_preferences | ^2.5.3 | Lightweight key-value persistence |
| path_provider | ^2.1.5 | Filesystem paths (DB file location) |
| path | ^1.9.0 | Cross-platform path manipulation |
| url_launcher | ^6.3.2 | Open URLs / phone dialler |
| package_info_plus | ^9.0.0 | App version information |
| permission_handler | ^11.3.1 | Runtime permission requests |
| geocoding | ^3.0.0 | Address → coordinates conversion |
| flutter_typeahead | ^5.2.0 | Autocomplete text fields |
| excel | ^4.0.6 | Export data to .xlsx spreadsheet |

### Dev Dependencies

| Technology | Version | Purpose |
|---|---|---|
| flutter_lints | ^2.0.0 | Linting rules |
| drift_dev | ^2.21.0 | Code generation for Drift tables |
| build_runner | ^2.4.11 | Source code generation runner |

---

## 3. System Architecture

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                           │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                  Presentation Layer                  │   │
│  │  Screens (Widgets) ←→ ViewModels (ChangeNotifier)   │   │
│  │       Provider / Consumer / context.watch()          │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │                   Domain Layer                       │   │
│  │   Models · Enums · Constants · RolePermissions       │   │
│  └──────────────────────┬───────────────────────────────┘   │
│                         │                                    │
│  ┌──────────────────────▼───────────────────────────────┐   │
│  │                    Data Layer                        │   │
│  │  Repositories (Firestore + local fallback)           │   │
│  │  Services (Auth, Firestore, WellnessSession,         │   │
│  │           DataMigration, UserEvent)                  │   │
│  │  Local DB (Drift / SQLite)                           │   │
│  └──────────┬───────────────────────┬───────────────────┘   │
│             │                       │                        │
└─────────────┼───────────────────────┼────────────────────────┘
              │                       │
    ┌─────────▼──────┐     ┌──────────▼────────┐
    │  Cloud Firestore│     │  SQLite (Device)  │
    │  (Firebase)     │     │  Drift ORM        │
    └─────────────────┘     └───────────────────┘
```

### Component Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                         main.dart                              │
│   Firebase.initializeApp()                                     │
│   MultiProvider (AppProvider, ProfileViewModel, AuthViewModel, │
│                  CalendarViewModel, EventViewModel,            │
│                  StatsReportViewModel, ThemeProvider,          │
│                  ConsentScreenViewModel)                       │
│   MaterialApp.router → AppRouterConfig (go_router)            │
└────────────────────────┬───────────────────────────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │      AppRouterConfig           │
         │  Auth guard + RBAC redirect    │
         │  22 named routes               │
         └───────────────┬────────────────┘
                         │
         ┌───────────────▼────────────────┐
         │    MainNavigationScreen        │
         │  Role-adaptive bottom nav /    │
         │  navigation rail (desktop)     │
         │                                │
         │  Tabs (by role):               │
         │  ┌──────────┐ ┌─────────────┐ │
         │  │  Home    │ │  My Events  │ │
         │  ├──────────┤ ├─────────────┤ │
         │  │  Stats   │ │  Users Mgmt │ │
         │  ├──────────┤ └─────────────┘ │
         │  │ Profile  │                 │
         │  └──────────┘                 │
         └────────────────────────────────┘
```

---

## 4. Application Layers

### 4.1 Presentation Layer (`lib/ui/`)

Follows MVVM (Model–View–ViewModel) with Provider.

```
lib/ui/
├── features/               # Feature modules (one folder per screen domain)
│   ├── auth/               # Login, ForgotPassword, AuthWrapper
│   ├── home/               # HomeScreen + HomeHeroHeader, WelcomeBanner, Notifications
│   ├── calendar/           # CalendarScreen + CalendarTabView, EventsListTabView
│   ├── event/              # EventScreen, EventDetailsScreen, MyEventScreen, AllocateEventScreen
│   ├── wellness/           # WellnessFlowScreen + WellnessNavigator + ScreeningNavigator
│   │   └── navigation/
│   │       └── screening_navigators/
│   ├── member/             # MemberRegistrationScreen, MemberManagementScreen, MemberEventsScreen
│   ├── consent_form/       # ConsentScreen
│   ├── health_risk_assessment/ # HRAScreen (sections: Lifestyle, GenderQuestions, HealthMetrics)
│   ├── health_metrics/     # HealthMetricsScreen
│   ├── hiv_test/           # HIVTestScreen
│   ├── hiv_test_results/   # HIVTestResultScreen
│   ├── hiv_test_nursing_intervention/
│   ├── tb_test/            # TBTestingScreen
│   ├── tb_test_nursing_intervention/
│   ├── cancer/             # CancerScreen
│   ├── nurse_interventions/# NurseInterventionScreen + NurseInterventionForm
│   ├── survey/             # SurveyScreen
│   ├── stats_report/       # StatsReportScreen, LiveEventsScreen, PastEventsScreen, EventStatsDetailScreen
│   ├── user_management/    # RegistrationManagementScreen, UserManagementScreenV2
│   ├── profile/            # ProfileScreen, MyProfileMenuScreen
│   ├── help/               # HelpScreen
│   └── splash/             # SplashScreen
└── shared/
    ├── themes/             # AppTheme (light + dark)
    ├── ui/
    │   ├── app_bar/        # KenwellAppBar
    │   ├── badges/         # NumberBadge, StatPill
    │   ├── buttons/        # Shared button widgets
    │   ├── cards/          # KenwellEmptyState, KenwellDetailRow, KenwellSectionCard
    │   ├── colours/        # KenwellColors (brand palette)
    │   ├── containers/
    │   ├── dialogs/
    │   ├── form/
    │   ├── headers/
    │   ├── labels/
    │   ├── logo/
    │   ├── navigation/     # MainNavigationScreen
    │   ├── responsive/     # ResponsiveBreakpoints
    │   └── snackbars/      # AppSnackbar (Success/Error/Info/Warning)
    └── models/
```

**ViewModels per feature:**

| Feature | ViewModel(s) |
|---|---|
| Auth | `AuthViewModel`, `LoginViewModel` |
| Calendar | `CalendarViewModel` |
| Event | `EventViewModel`, `EventDetailsViewModel`, `AllocateEventViewModel`, `MyEventViewModel` |
| Wellness Flow | `WellnessFlowViewModel` |
| Member | `MemberRegistrationViewModel`, `MemberEventsViewModel` |
| Member Search | `MemberSearchViewModel` |
| Health Screening | `HealthRiskAssessmentViewModel`, `HealthMetricsViewModel` |
| HIV | `HIVTestViewModel`, `HIVTestResultViewModel` |
| TB | `TBTestingViewModel`, `TBNursingInterventionViewModel` |
| Cancer | `CancerViewModel` |
| Nurse Interventions | `NurseInterventionViewModel` |
| Survey | `SurveyViewModel` |
| Stats Report | `StatsReportViewModel` |
| User Management | `UserManagementViewModel` |
| Profile | `ProfileViewModel` |
| Consent | `ConsentScreenViewModel` |
| Help | `HelpScreenViewModel` |
| Splash | `SplashViewModel` |
| HIV Test Result | `HIVTestResultViewModel` |

### 4.2 Domain Layer (`lib/domain/`)

```
lib/domain/
├── models/
│   ├── wellness_event.dart       # WellnessEvent, WellnessEventStatus
│   ├── member.dart               # Member
│   ├── user.dart / user_model.dart # User, UserModel
│   ├── consent.dart              # Consent
│   ├── hra_screening.dart        # HraScreening
│   ├── hiv_screening.dart        # HivScreening
│   ├── hiv_result.dart           # HivResult
│   ├── tb_screening.dart         # TbScreening
│   ├── cander_screening.dart     # CancerScreening (note: filename has a typo — should be cancer_screening.dart)
│   └── member_event.dart         # MemberEvent (event↔member association)
├── constants/
│   ├── user_roles.dart           # UserRoles (6 roles)
│   ├── role_permissions.dart     # RolePermissions (route + feature access maps)
│   └── enums.dart                # ServiceType, AdditionalServiceType enums
└── enums/                        # Additional enums
```

### 4.3 Data Layer (`lib/data/`)

```
lib/data/
├── local/
│   ├── app_database.dart          # Drift @DriftDatabase definition
│   ├── app_database.g.dart        # Generated code
│   ├── database_helper.dart       # Platform dispatcher
│   ├── database_helper_io.dart    # Mobile/desktop SQLite opener
│   └── database_helper_web.dart   # Web SQLite opener
├── repositories_dcl/
│   ├── auth_repository_dcl.dart   # Auth repository interface
│   ├── event_repository.dart      # Events: Firestore + local cache
│   ├── firestore_event_repository.dart
│   ├── firestore_member_repository.dart
│   ├── member_repository.dart     # Member repo interface + cache logic
│   ├── firestore_member_event_repository.dart
│   ├── firestore_consent_repository.dart
│   ├── firestore_hra_repository.dart
│   ├── firestore_hiv_screening_repository.dart
│   ├── firestore_hiv_result_repository.dart
│   ├── firestore_tb_screening_repository.dart
│   ├── firestore_cancer_screening_repository.dart
│   └── user_event_repository.dart
├── services/
│   ├── auth_service.dart          # Auth service interface
│   ├── firebase_auth_service.dart # Firebase Auth + Firestore user ops
│   ├── firestore_service.dart     # Generic CRUD wrapper for Firestore
│   ├── wellness_session_service.dart # Participant session lifecycle
│   ├── data_migration_service.dart # Local → Firestore data migration
│   └── user_event_service.dart
└── model_dto/
    └── api_response.dart          # Unified API response wrapper
```

---

## 5. Database Design

### Local Database (SQLite via Drift)

The app embeds a local SQLite database (schema version **14**) for offline-first operation. Three tables are defined:

#### `users` Table

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | UUID |
| `email` | TEXT | UNIQUE, NOT NULL | Login email |
| `password` | TEXT | NOT NULL | Hashed/stored password (local only) |
| `role` | TEXT | NOT NULL | One of 6 role constants |
| `phone_number` | TEXT | NOT NULL | Contact number |
| `first_name` | TEXT | NOT NULL | First name |
| `last_name` | TEXT | NOT NULL | Last name |
| `created_at` | INTEGER | DEFAULT now | Creation timestamp |
| `updated_at` | INTEGER | DEFAULT now | Last update timestamp |

#### `events` Table

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | UUID |
| `title` | TEXT | DEFAULT '' | Event title |
| `date` | INTEGER | NOT NULL | Event date (epoch ms) |
| `venue` | TEXT | DEFAULT '' | Venue name |
| `address` | TEXT | DEFAULT '' | Street address |
| `town_city` | TEXT | DEFAULT '' | Town or city |
| `province` | TEXT | NULLABLE | Province |
| `onsite_contact_first_name` | TEXT | DEFAULT '' | On-site contact first name |
| `onsite_contact_last_name` | TEXT | DEFAULT '' | On-site contact last name |
| `onsite_contact_number` | TEXT | DEFAULT '' | On-site contact number |
| `onsite_contact_email` | TEXT | DEFAULT '' | On-site contact email |
| `ae_contact_first_name` | TEXT | DEFAULT '' | AE contact first name |
| `ae_contact_last_name` | TEXT | DEFAULT '' | AE contact last name |
| `ae_contact_number` | TEXT | DEFAULT '' | AE contact number |
| `ae_contact_email` | TEXT | DEFAULT '' | AE contact email |
| `services_requested` | TEXT | DEFAULT '' | Comma-separated service types |
| `additional_services_requested` | TEXT | DEFAULT '' | Comma-separated additional services |
| `expected_participation` | INTEGER | DEFAULT 0 | Expected attendee count |
| `nurses` | INTEGER | DEFAULT 0 | Number of nurses allocated |
| `coordinators` | INTEGER | DEFAULT 0 | Number of coordinators |
| `set_up_time` | TEXT | DEFAULT '' | Setup time string |
| `start_time` | TEXT | DEFAULT '' | Start time string |
| `end_time` | TEXT | DEFAULT '' | End time string |
| `strike_down_time` | TEXT | DEFAULT '' | Strike-down time string |
| `mobile_booths` | TEXT | DEFAULT '' | Mobile booths information |
| `medical_aid` | TEXT | DEFAULT '' | Medical aid scheme name |
| `description` | TEXT | NULLABLE | Free-text description |
| `status` | TEXT | DEFAULT 'scheduled' | `scheduled` / `in_progress` / `completed` |
| `actual_start_time` | INTEGER | NULLABLE | Recorded actual start (epoch ms) |
| `actual_end_time` | INTEGER | NULLABLE | Recorded actual end (epoch ms) |
| `screened_count` | INTEGER | DEFAULT 0 | Participant screened count |
| `created_at` | INTEGER | DEFAULT now | |
| `updated_at` | INTEGER | DEFAULT now | |

#### `members` Table

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | UUID |
| `name` | TEXT | NOT NULL | First name |
| `surname` | TEXT | NOT NULL | Last name |
| `id_number` | TEXT | NULLABLE | SA ID number |
| `passport_number` | TEXT | NULLABLE | Passport number |
| `id_document_type` | TEXT | NOT NULL | `'ID'` or `'Passport'` |
| `date_of_birth` | TEXT | NULLABLE | ISO 8601 date string |
| `gender` | TEXT | NULLABLE | Gender |
| `marital_status` | TEXT | NULLABLE | Marital status |
| `nationality` | TEXT | NULLABLE | Nationality |
| `citizenship_status` | TEXT | NULLABLE | Citizenship status |
| `email` | TEXT | NULLABLE | Email address |
| `cell_number` | TEXT | NULLABLE | Mobile number |
| `medical_aid_status` | TEXT | NULLABLE | Medical aid status |
| `medical_aid_name` | TEXT | NULLABLE | Medical aid scheme |
| `medical_aid_number` | TEXT | NULLABLE | Membership number |
| `created_at` | INTEGER | DEFAULT now | |
| `updated_at` | INTEGER | DEFAULT now | |

#### Schema Migration History

| Version | Change |
|---|---|
| 1–9 | Initial schema iterations |
| 10 | Added `additional_services_requested` to events |
| 11 | Removed `username` column from users (table rebuild) |
| 12 | Added NOT NULL defaults to events (NULL fix); COALESCE data copy |
| 13 | Added `screened_count` to events |
| 14 | Added `members` table |

---

## 6. Firestore Collections

Cloud Firestore is the primary cloud store. All collections use auto-generated or UUID document IDs.

| Collection | Description | Key Fields |
|---|---|---|
| `users` | Practitioner accounts | `id`, `email`, `role`, `firstName`, `lastName`, `phoneNumber`, `emailVerified` |
| `events` | Wellness events | All `WellnessEvent` fields including `status`, `actualStartTime`, `screenedCount` |
| `members` | Participant (member) records | All `Member` fields including `eventId` |
| `consents` | Informed consent records | `memberId`, `eventId`, `hra`, `hct`, `tb`, `cancer` (booleans), `signatureData` |
| `hra_screenings` | Health Risk Assessment results | `memberId`, `eventId`, chronic conditions, vitals, lifestyle answers |
| `hiv_screenings` | HIV screening data | `memberId`, `eventId`, counselling and testing fields |
| `hiv_results` | HIV test results | `memberId`, `eventId`, result fields |
| `tb_screenings` | TB screening data | `memberId`, `eventId`, symptom questions, nurse intervention fields, `signatureData` |
| `cancer_screenings` | Cancer screening data | `memberId`, `eventId`, symptom fields, exam findings, Pap smear, PSA, referral |
| `wellness_sessions` | Participant session lifecycle | `eventId`, `nurseUserId`, `status`, `completedSteps`, consent + screening sub-documents |
| `member_events` | Member ↔ Event associations | `memberId`, `eventId`, timestamps |

---

## 7. Role-Based Access Control & Security

### User Roles

Six roles are defined in `UserRoles`:

| Role | Target User | Access Level |
|---|---|---|
| `ADMIN` | System administrator | Full access to everything |
| `TOP MANAGEMENT` | Executive / director | Full access except delete user |
| `PROJECT MANAGER` | Event project manager | Create/edit events, manage users, view stats |
| `PROJECT COORDINATOR` | On-site coordinator | Conduct wellness flows, allocate events |
| `HEALTH PRACTITIONER` | Nurse / clinician | Conduct wellness flows and screenings |
| `CLIENT` | Corporate client | View statistics only |

### Route-Level Access

`RolePermissions.canAccessRoute()` is called in the global `go_router` redirect hook on every navigation event. The route permission map covers 30+ named routes.

**Example access matrix (selected routes):**

| Route | ADMIN | TOP MGMT | PROJ MGR | PROJ COORD | HEALTH PRACT | CLIENT |
|---|---|---|---|---|---|---|
| `/` (Home) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/calendar` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/user-management-version-two` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `/add-edit-event` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `/stats` | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| `/member-search` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `/health-risk-assessment` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `/tb-testing` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

### Feature-Level Access

`RolePermissions.canAccessFeature()` is used inside widgets and ViewModels to conditionally render buttons and controls (e.g., create/edit/delete event buttons).

**Key feature permissions:**

| Feature | Allowed Roles |
|---|---|
| `create_event` / `edit_event` / `delete_event` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |
| `allocate_events` | ADMIN, TOP MANAGEMENT, PROJECT COORDINATOR |
| `create_member` / `edit_member` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |
| `view_members` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |
| `create_user` / `edit_user` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |
| `delete_user` | ADMIN only |
| `conduct_wellness_flow` | HEALTH PRACTITIONER, PROJECT MANAGER, PROJECT COORDINATOR, ADMIN, TOP MANAGEMENT |
| `view_statistics` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER, CLIENT |
| `export_data` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |

### Authentication Flow

```
App Start
    │
    ▼
Firebase.initializeApp()
    │
    ▼
go_router redirect guard
    ├─ Not authenticated → redirect to /login
    └─ Authenticated
           ├─ Trying to access /login → redirect to /
           └─ Role check via RolePermissions
                  ├─ Has permission → allow
                  └─ No permission → redirect to /
```

**Firebase Auth** handles email/password authentication. The app also:
- Sends email verification on new account creation
- Syncs `emailVerified` status to the Firestore `users` collection
- Supports password reset via `ForgotPasswordScreen`

### Security Considerations

| Area | Implementation |
|---|---|
| Authentication | Firebase Authentication (email + password) |
| Authorisation | `RolePermissions` class — fail-open for undefined routes, fail-closed for undefined features |
| Data isolation | Firestore reads are not restricted by security rules at the SDK level (see Pending Items) |
| Password storage | Passwords are stored locally in the Drift `users` table; Firebase Auth handles cloud passwords |
| Consent | Digital consent with nurse signature capture (base64 PNG stored in Firestore) |
| HTTPS | All Firebase/Firestore traffic is over TLS |

---

## 8. Navigation & Routing

### Navigation Architecture

The app uses **go_router v14** for declarative routing. All route changes go through a global `redirect` callback that enforces authentication and role access.

### Named Routes

| Name | Path | Screen | Access |
|---|---|---|---|
| `login` | `/login` | LoginScreen | Public |
| `forgotPassword` | `/forgot-password` | ForgotPasswordScreen | Public |
| `main` | `/` | MainNavigationScreen | All roles |
| `calendar` | `/calendar` | CalendarScreen | All roles |
| `memberSearch` | `/member-search` | MemberSearchScreen | Staff |
| `memberManagement` | `/member-management` | MemberManagementScreen | Privileged |
| `myRegistrationManagement` | `/my-registration-management` | RegistrationManagementScreen | Privileged |
| `eventById` | `/event/:id` | EventDetailsScreen | All roles |
| `addEditEvent` | `/add-edit-event` | EventScreen | Privileged |
| `eventDetails` | `/event-details` | EventDetailsScreen | All roles |
| `stats` | `/stats` | StatsReportScreen | Mgmt + Client |
| `liveEvents` | `/live-events` | LiveEventsScreen | Privileged |
| `pastEvents` | `/past-events` | PastEventsScreen | Privileged |
| `hivTest` | `/hiv-test` | HIVTestScreen | Staff |
| `hivResults` | `/hiv-result` | HIVTestResultScreen | Staff |
| `tbTesting` | `/tb-testing` | TBTestingScreen | Staff |
| `survey` | `/survey` | SurveyScreen | Staff |
| `profile` | `/profile` | ProfileScreen | All roles |
| `alocateEvent` | `/allocate-event` | (→ ProfileScreen, placeholder) | Privileged |
| `help` | `/help` | HelpScreen | All roles |
| `userManagementVersionTwo` | `/user-management-version-two` | UserManagementScreenV2 | Privileged |

### Tab Navigation

`MainNavigationScreen` renders a **bottom navigation bar** (mobile) or **NavigationRail** (desktop) with role-adaptive tabs:

| Tab Set | Roles | Tabs |
|---|---|---|
| Full (`allTabs`) | ADMIN, TOP MANAGEMENT, PROJECT MANAGER | Users · Statistics · Home · Profile · My Events |
| Client (`clientTabs`) | CLIENT | Statistics · Home · Profile |
| Restricted (`restrictedTabs`) | PROJECT COORDINATOR, HEALTH PRACTITIONER | Home · Profile · My Events |

### Wellness Flow Navigation

The wellness flow uses an **imperative `Navigator.push()`** pattern managed by `WellnessNavigator` (rather than go_router), because it is a multi-step guided flow within a single modal context.

---

## 9. Features Walkthrough

### 9.1 Authentication

- **Login Screen**: Email + password form. Validates input, calls `AuthViewModel.login()`, navigates to home on success.
- **Forgot Password Screen**: Email input, triggers Firebase password reset email.
- **Auth Wrapper**: Listens to `AuthViewModel.isLoggedIn` and directs the user appropriately.
- **Profile Screen**: Edit own profile details, change theme, log out.

### 9.2 Home Screen

- **HomeHeroHeader**: Displays current user's name and role with a branded gradient card.
- **HomeWelcomeBanner**: Motivational / information banner.
- **HomeNotificationsSection**: In-app notification feed (`NotifItem` cards with `NotifType` colour coding).

### 9.3 Calendar & Events

- **CalendarScreen** (250 lines after refactor): Tabbed view — a monthly calendar (`table_calendar`) and an events list.
  - `CalendarTabView`: Interactive calendar with event dots; `CalendarStatChip` shows quick counts.
  - `EventsListTabView`: Scrollable list of `EventCard` widgets.
- **EventScreen**: Create / edit event form with the following sections:
  - `EventBasicInfoSection`: Title, date, province, venue, address
  - `EventLocationSection`: Town/city, geocoding support
  - `EventTimeSection`: Setup, start, end, strike-down times (calls `showTimePicker`)
  - `ContactPersonSection`: Onsite and AE contacts
  - `ServicesSelectionSection`: Multi-select checkboxes for `ServiceType` enums
  - `HealthcareProfessionalsSection`: Nurse and coordinator headcount
  - `ParticipationSection`: Expected participation count
  - `MedicalAidSection`: Medical aid scheme
  - `EventOptionsSection`: Mobile booths, additional services
- **EventDetailsScreen**: Read-only event summary with Start / Finish event controls (time-locked).
- **MyEventScreen**: Practitioner's own allocated events with `MyEventTabBar` and `PremiumEventCard`.
- **AllocateEventScreen**: Assign practitioners to events (`AllocateUserCard` with `_AssignmentBadge`).

### 9.4 Wellness Flow (Core Clinical Workflow)

The wellness flow is the heart of the application. When a practitioner starts an event, they navigate participants through a multi-step guided process managed by `WellnessFlowViewModel`.

**Flow Steps (in order):**

1. **Member Registration** (`stepMemberRegistration`) — Search for an existing member or register a new one
2. **Current Event Home** (`stepCurrentEventDetails`) — Event overview with section progress indicators
3. **Consent Form** (`stepConsent`) — Digital informed consent with signature capture; flags which screenings are enabled (HRA/HCT/TB/Cancer)
4. **Health Screenings Menu** (`stepHealthScreeningsMenu`) — Overview of selected screenings and their completion status
5. **Personal Details** (`stepPersonalDetails`) — Demographics collection (Health Metrics)
6. **Risk Assessment** (`stepRiskAssessment`) — HRA (Health Risk Assessment)
7. **HCT Test** (`stepHctTest`) — HIV Counselling & Testing
8. **HCT Results** (`stepHctResults`) — HIV result entry and nursing intervention
9. **TB Test** (`stepTbTest`) — TB symptom screening + nurse intervention + signature
10. **Cancer Screening** (`stepCancerScreening`) — Breast/cervical/prostate screening + referral
11. **Survey** (`stepSurvey`) — Post-screening satisfaction survey

Each step is dynamically included in `_flowSteps` based on the consent flags. Steps not consented to are skipped automatically.

### 9.5 Health Screenings

#### Health Risk Assessment (HRA)
- **Sections**: Lifestyle (`hra_lifestyle_section`), Gender Questions (`hra_gender_questions_section`), Health Metrics (`hra_health_metrics_section`)
- **Data captured**: Chronic conditions, exercise frequency, smoking, alcohol, Pap smear history, breast exam, mammogram, PSA, height, weight, BMI, BP, cholesterol, blood sugar, waist circumference
- **Outcome**: `NursingReferralStatusCard` — animated "Healthy" / "At-Risk" result card

#### HCT (HIV Counselling & Testing)
- Pre- and post-test counselling flags
- Test result entry (Reactive / Non-Reactive / Indeterminate)
- Nursing intervention with follow-up location and date

#### TB Screening
- Four symptom questions (cough ≥2 weeks, blood in sputum, weight loss, night sweats)
- TB history questions (previous treatment, contacts)
- Nurse intervention fields + digital signature (base64)
- Outcome: referral status + `NursingReferralStatusCard`

#### Cancer Screening
- Medical history + chronic conditions
- Symptom checklist
- Breast light exam findings
- Liquid cytology / Pap smear specimen and results
- PSA result
- Referral facility + follow-up date
- Nurse intervention + signature

### 9.6 Member Management

- **MemberManagementScreen**: Tabbed — view all members, create new member
  - `ViewMembersSection`: Searchable + filterable list with `MemberCardWidget`
  - `CreateMemberSection`: Registration form
  - `MemberSearchBar`: Real-time name/ID search
  - `MemberFilterChips`: Filter by gender, medical aid status, etc.
- **MemberRegistrationScreen**: Full registration form (used within wellness flow)
- **MemberEventsScreen**: View all events a member has participated in (`MemberEventsViewModel`)

### 9.7 User Management

- **RegistrationManagementScreen**: Tabbed — view users, create new user
  - `ViewUsersSection`: User cards with `StatPill` badges showing role counts
  - `CreateUserSection`: Create user form with role assignment
  - `UserSearchBar` + `UserFilterChips`
  - `UserCardWidget`: Displays user card with navy border; swipe-to-action (edit/delete)
- **UserManagementScreenV2**: Alternative user management screen

### 9.8 Statistics & Reporting

- **StatsReportScreen**: Top-level statistics hub with live event count, past event count, and member count
- **LiveEventsScreen**: Currently in-progress events with real-time screened counts
- **PastEventsScreen**: Completed events list
- **EventStatsDetailScreen** (355 lines): Per-event detailed statistics
  - `EventStatsContent` (598 lines): Charts + metric cards
  - `StatsMetricCard`: Single KPI metric card
  - `StatsStatCard`: Statistic breakdown card
  - `HraStatsCard`, `CancerStatsCard`, `TBStatsCard`, `HCTStatsCard`: Per-screening breakdown
  - `LiveScreeningCountsSection`: Real-time counters during live event
  - `StatsFilterSheet`: Date range and filter bottom sheet

### 9.9 Consent Form

- Digital consent form with check-box acknowledgements
- Nurse digital signature pad (uses `signature` package)
- Stores `hra`, `hct`, `tb`, `cancer` boolean flags per member per event
- Saved to `consents` Firestore collection

### 9.10 Survey

- Post-screening satisfaction/feedback survey
- Submitted at end of wellness flow; increments `screenedCount` on the event

### 9.11 Help Screen

- In-app help and guidance content
- Accessible by all roles

### 9.12 Profile / Settings

- **ProfileScreen**: View and edit own profile (name, phone)
- **MyProfileMenuScreen**: Navigation menu with links to profile, help, theme toggle, logout
- **ThemeProvider**: Light / dark mode toggle (persisted via `shared_preferences`)

---

## 10. Workflow Diagrams

### 10.1 Authentication Flow

```
┌──────────┐     Open App     ┌─────────────────┐
│  User    │ ──────────────→  │  go_router       │
└──────────┘                  │  redirect guard  │
                              └────────┬─────────┘
                                       │
                        ┌──────────────┴──────────────┐
                        │                             │
                Not logged in                    Logged in
                        │                             │
                        ▼                             ▼
               ┌────────────────┐         ┌────────────────────┐
               │  LoginScreen   │         │  MainNavigation    │
               └───────┬────────┘         │  (role-based tabs) │
                       │                  └────────────────────┘
            Enter email + password
                       │
                       ▼
              Firebase Auth.signIn()
                       │
              ┌────────┴────────┐
         Success               Failure
              │                    │
              ▼                    ▼
     ProfileViewModel        Show error
     loads user doc           snackbar
     from Firestore
              │
              ▼
     go_router → '/'
     (MainNavigation)
```

### 10.2 Wellness Flow (Full Participant Journey)

```
Event List
    │
    ▼
Tap "Start Event" (MyEventScreen)
    │
    ▼
WellnessNavigator.startFlow()
    │
    ▼
┌───────────────────────────┐
│  MemberSearchScreen       │ ← Search by name / ID / passport
└──────────────┬────────────┘
               │
    ┌──────────┴────────────┐
    │                       │
 Found member          New member
    │                       │
    │              MemberRegistrationScreen
    │                  (register + save)
    │                       │
    └───────────────────────┘
               │
               ▼
┌──────────────────────────────┐
│  CurrentEventHomeScreen      │ ← Shows progress sections
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│  ConsentScreen               │ ← Checkboxes + digital signature
│  (enables HRA/HCT/TB/Cancer) │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│  HealthScreeningsScreen      │ ← Menu of enabled screenings
└──────────────┬───────────────┘
               │
     ┌─────────┼─────────┬──────────────┐
     ▼         ▼         ▼              ▼
   HRA       HCT        TB           Cancer
   Screen    Screen     Screen       Screen
     │         │         │              │
     ▼         ▼         ▼              ▼
  (save)    (save)    (save)         (save)
  Firestore Firestore Firestore      Firestore
     │
     ▼
┌──────────────────────────────┐
│  SurveyScreen                │ ← Satisfaction survey
└──────────────┬───────────────┘
               │
               ▼
     screenedCount++ on event
               │
               ▼
     Flow complete → return to event home
```

### 10.3 Event Lifecycle

```
┌────────────────────────────────────────────────────────────┐
│                    Event Lifecycle                         │
└────────────────────────────────────────────────────────────┘

Create Event ──→ status: 'scheduled'
     │
     ▼
Allocate Practitioners (AllocateEventScreen)
     │
     ▼
Start Event ──────────────────────────────────────────────────┐
  (EventDetailsScreen: canStartEvent = date is today)         │
  actualStartTime = now                                       │
  status: 'in_progress'                                       │
     │                                                        │
     ▼                                                        │
Conduct Wellness Flows (multiple participants)                │
  screenedCount increments per completed survey               │
     │                                                        │
     ▼                                                        │
Finish Event ──────────────────────────────────────────────── ┘
  actualEndTime = now
  status: 'completed'
     │
     ▼
Event appears in PastEventsScreen
Statistics available in EventStatsDetailScreen
```

### 10.4 Data Sync Flow (Offline-First)

```
Write operation (event/member)
         │
         ├──→ Write to Firestore (primary)
         │         │
         │    Success → Mirror to local Drift DB (cache)
         │    Failure → Write to local Drift DB only
         │
Read operation (event/member)
         │
         ├──→ Try Firestore first
         │         │
         │    Success → Return data + update local cache
         │    Failure → Fall back to local Drift DB
```

---

## 11. UI & Theming

### Brand Colours

| Token | Hex | Usage |
|---|---|---|
| `primaryGreen` | `#90C048` | Primary buttons, active states, success indicators |
| `primaryGreenDark` | `#5E8C1F` | Hover / pressed states |
| `primaryGreenLight` | `#CDE8A0` | Backgrounds, containers |
| `secondaryNavy` | `#201C58` | App bar, primary text, card borders |
| `secondaryNavyDark` | `#111235` | Deep navy |
| `secondaryNavyLight` | `#3B3F86` | Secondary accents |
| `neutralBackground` | `#F6F8F2` | Page backgrounds |
| `success` | `#2E7D32` | Success states |
| `warning` | `#F9A825` | Warning states |
| `error` | `#B3261E` | Error states |

### Theme Support

Both **light** and **dark** themes are implemented using Material 3 `ColorScheme`. The `ThemeProvider` persists the user's choice via `shared_preferences`.

### Shared UI Components

| Component | Location | Purpose |
|---|---|---|
| `KenwellAppBar` | `ui/shared/ui/app_bar/` | Branded app bar with optional subtitle + actions |
| `AppSnackbar` | `ui/shared/ui/snackbars/` | Consistent Success/Error/Info/Warning snackbars |
| `KenwellEmptyState` | `ui/shared/ui/cards/` | Empty list placeholder |
| `KenwellDetailRow` | `ui/shared/ui/cards/` | Label + value row in detail screens |
| `KenwellSectionCard` | `ui/shared/ui/cards/` | Styled card container with title |
| `StatPill` | `ui/shared/ui/badges/` | Icon + text inline badge |
| `NumberBadge` | `ui/shared/ui/badges/` | Numeric notification badge |
| `NursingReferralStatusCard` | (per screening widget) | Animated Healthy/At-Risk result card |

### Responsive Design

`ResponsiveBreakpoints` provides `isDesktop(context)` which controls whether the app shows a `NavigationRail` (desktop/tablet) or `BottomNavigationBar` (mobile). `sizer` package handles responsive font sizes and spacing.

---

## 12. Offline Support Strategy

The app implements a **local-first, cloud-synced** strategy:

1. **Reads** — attempt Firestore first; fall back to local Drift DB on failure.
2. **Writes** — write to Firestore first; mirror to local DB on success; write to local DB only on failure.
3. **Members** — `FirestoreMemberRepository` caches all fetched members to Drift `members` table.
4. **Events** — `EventRepository` caches all fetched events to Drift `events` table.
5. **DataMigrationService** — provides a utility to bulk-migrate local Drift data to Firestore (for initial setup or recovery).
6. **WellnessSessionService** — tracks per-participant session state in Firestore, not locally.

**Current limitation**: Health screening data (HRA, TB, Cancer, HCT, consent, survey) is only stored in Firestore. If the device is offline when a screening is completed, the data will be lost. This is a known gap (see Section 13).

---

## 13. Pending Items & Known Gaps

The following items are identified as incomplete, placeholder, or needing attention:

| # | Area | Description | Priority |
|---|---|---|---|
| 1 | **Offline Screenings** | HRA, TB, Cancer, HCT, consent, and survey data is only saved to Firestore. If offline, submissions fail silently. Add local caching with sync queue. | High |
| 2 | **Allocate Event Route** | `/allocate-event` route in `go_router_config.dart` is a placeholder that navigates to `ProfileScreen`. `AllocateEventScreen` exists but is not wired to this route. | High |
| 3 | **Firestore Security Rules** | No Firestore security rules are defined in the codebase. All data is accessible to any authenticated user. Implement per-collection, per-role security rules. | High |
| 4 | **Windows Desktop** | `main.dart` includes a comment that Firebase on Windows requires the C++ SDK and is not fully supported. | Medium |
| 5 | **Password Storage** | User passwords are stored in plaintext in the local Drift `users` table (the `password` column). Passwords should be hashed or not stored locally at all. | High |
| 6 | **User Management Route** | The `/user-management` route is commented out in `go_router_config.dart` (`/* GoRoute(...) */`). Only `/user-management-version-two` is active. | Low |
| 7 | **Export to Excel** | The `excel` package is included as a dependency but no export functionality is visible in the active screens. This feature is partially pending. | Medium |
| 8 | **Geocoding** | The `geocoding` package is included but its usage within the app is limited to the event location section. Full address autocomplete/validation is not implemented. | Low |
| 9 | **Deep Linking by Event ID** | The `/event/:id` route includes a comment: `"In a real app, you'd fetch the event by ID here"`. Deep linking by ID will show an error screen if no event is passed via `extra`. | Medium |
| 10 | **HIV Screening Stats** | The `hiv_screenings` and `hiv_results` Firestore collections exist and are included in `FirestoreService` constants, but HIV stats cards are not visible in the stats report section (unlike HRA, TB, Cancer, HCT). | Medium |
| 11 | **Coordinators Field** | `WellnessEvent` has a `coordinators` field commented out (`//final int coordinators`). The DB still has the column. | Low |
| 12 | **Wellness Session Linking** | `WellnessSessionService` creates sessions in Firestore but the main wellness flow (`WellnessFlowViewModel`) uses individual screening repositories rather than linking to a session ID consistently. | Medium |
| 13 | **Email Verification Gate** | Firebase email verification is sent but the app does not block login for unverified accounts. `emailVerified` is synced to Firestore but not enforced in the auth guard. | Medium |
| 14 | **Error Handling** | Some repositories use `rethrow` and some silently catch errors. A unified error handling strategy (e.g., `ApiResponse` wrapper everywhere) is not consistently applied. | Medium |
| 15 | **Tests** | No unit or widget tests are present beyond the generated `flutter_test` setup. Business logic in ViewModels and repositories has no test coverage. | Medium |
| 16 | **Commented-Out Services** | Several services (`dental screening`, `eye test`, `psychological assessment`, `posture screening`) are commented out in the `ServiceType` enum, suggesting planned but not yet implemented screenings. | Low |

---

## 14. Future Recommendations

### Architecture & Code Quality

1. **Introduce a proper dependency injection framework** (e.g., `get_it` + `injectable`) to replace manual `ChangeNotifierProvider` chains in `main.dart`. This will improve testability and reduce boilerplate.

2. **Adopt a Result/Either type for repository methods** (e.g., `fpdart` or a custom `Result<T>` class). Currently repositories either return `null` on failure or `rethrow` exceptions, making error handling inconsistent in ViewModels.

3. **Add a comprehensive test suite**: Write unit tests for all ViewModels and repositories (using mock Firestore / in-memory Drift DB). Add widget tests for critical flows like the consent form and HRA.

4. **Resolve the dual User model**: Both `User` (in `domain/models/user.dart`) and `UserModel` (in `domain/models/user_model.dart`) exist. Consolidate into one canonical model.

### Security

5. **Implement Firestore Security Rules** to restrict collection access by user role. For example:
   - Only `ADMIN`, `TOP MANAGEMENT`, `PROJECT MANAGER` should be able to write to `users`
   - Only authenticated users should be able to read `events`
   - Screening data should only be readable by practitioners and managers

6. **Remove password from local Drift DB** (`users.password` column). Firebase Auth already handles authentication. Local passwords create a security risk if the device is compromised.

7. **Enforce email verification** before allowing access to the app (or at minimum, to privileged routes).

8. **Add audit logging** — record who performed each screening, event start/stop, and user management actions to a Firestore `audit_logs` collection.

### Features & Product

9. **Offline-first screening submissions**: Queue HRA, TB, Cancer, and HCT submissions locally (Drift) when offline. Sync to Firestore when connectivity is restored using a background sync service.

10. **Complete the Excel export feature**: Wire the `excel` package to export event statistics and member screening data to `.xlsx` for client reporting.

11. **Activate the Allocate Event flow**: Connect `/allocate-event` route to the existing `AllocateEventScreen`. This allows project coordinators to self-assign to events.

12. **Push Notifications**: Integrate Firebase Cloud Messaging (FCM) to notify practitioners of newly allocated events, event start reminders, and upcoming event alerts.

13. **PDF Report Generation**: Add a PDF export of per-event screening summaries (using `pdf` or `printing` package) for healthcare compliance purposes.

14. **Add missing screenings**: The commented-out `ServiceType` values (dental, eye test, psychological, posture) suggest future planned screenings. When business requirements are confirmed, these can be enabled.

15. **Member history view**: Expand `MemberEventsScreen` to show a participant's full screening history across all events (trend analysis for chronic conditions, repeat HIV testing, etc.).

16. **Dashboard KPIs on HomeScreen**: Add a live stats summary to the `HomeScreen` for managers (today's event count, total screened today, live event status).

17. **Geocoding enhancements**: Integrate Google Maps or `flutter_map` to show event venue locations on a map in `EventDetailsScreen`.

18. **Pagination**: Both member and event lists currently load all records from Firestore. Implement Firestore cursor-based pagination to handle large datasets efficiently.

19. **Internationalisation (i18n)**: The app currently only supports English. Use Flutter's `intl` + ARB files to add multi-language support (relevant for South African markets: Zulu, Xhosa, Afrikaans).

### DevOps

20. **CI/CD Pipeline**: Set up GitHub Actions (or Codemagic) to run `flutter analyze`, `flutter test`, and build the APK/IPA on every pull request.

21. **Environment configuration**: Separate `firebase_options.dart` configurations for `dev`, `staging`, and `production` Firebase projects to prevent development data from polluting production.

22. **Crash reporting**: Integrate `firebase_crashlytics` to capture and report runtime exceptions from production devices.

23. **Analytics**: Integrate `firebase_analytics` to track screen views, wellness flow completion rates, and feature usage.

---

## 15. Glossary

| Term | Definition |
|---|---|
| **AE Contact** | Account Executive contact — the Kenwell sales/account representative for the event |
| **Onsite Contact** | The client-side person present at the venue on the day of the event |
| **HRA** | Health Risk Assessment — a lifestyle and biometric questionnaire |
| **HCT** | HIV Counselling and Testing |
| **TB** | Tuberculosis — symptom screening |
| **Cancer Screening** | Includes breast light exam, Pap smear (liquid cytology), and PSA testing |
| **PSA** | Prostate-Specific Antigen — a blood test for prostate cancer risk |
| **Pap Smear** | Liquid cytology test for cervical cancer screening |
| **BMI** | Body Mass Index — calculated from height and weight |
| **BP** | Blood Pressure — systolic/diastolic reading |
| **Member** | A participant registered at a wellness event |
| **Wellness Session** | A tracked lifecycle record for a single participant's journey through the wellness flow |
| **Screened Count** | The number of participants who completed the full flow (consent → screenings → survey) |
| **Strike-Down Time** | The time at which equipment is packed away after an event |
| **RBAC** | Role-Based Access Control |
| **Drift** | A type-safe SQLite ORM/code-generator for Flutter/Dart |
| **go_router** | A declarative routing library for Flutter built on top of the Navigator 2.0 API |
| **MVVM** | Model–View–ViewModel — the architectural pattern used throughout the app |
| **Provider** | A Flutter state management library based on `InheritedWidget` |
| **NursingReferralStatusCard** | A shared animated widget showing "Healthy" or "At-Risk" outcome after each screening |
| **SANC Number** | South African Nursing Council registration number |

---

*This document was auto-generated from a full code analysis of the Kenwell Health App repository. It should be reviewed and supplemented by the development team with any business context not captured in code.*
