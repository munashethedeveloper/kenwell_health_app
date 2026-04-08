# Kenwell Health App — Management Overview

> **Version:** 1.0  
> **Date:** March 2026  
> **Prepared for:** Kenwell Health — Executive & Management Team  
> **Classification:** Internal — Management Use

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [The Problem We Are Solving](#2-the-problem-we-are-solving)
3. [The Solution](#3-the-solution)
4. [Who Uses the System](#4-who-uses-the-system)
5. [How a Wellness Day Works with the App](#5-how-a-wellness-day-works-with-the-app)
6. [Features — What Has Been Built](#6-features--what-has-been-built)
7. [Platform & Availability](#7-platform--availability)
8. [Data, Privacy & Security](#8-data-privacy--security)
9. [Current Status of the Product](#9-current-status-of-the-product)
10. [Risks & Issues Requiring Management Attention](#10-risks--issues-requiring-management-attention)
11. [Recommended Roadmap & Next Investments](#11-recommended-roadmap--next-investments)
12. [Glossary](#12-glossary)

---

## 1. Executive Summary

The **Kenwell Health App** is a purpose-built digital platform that allows Kenwell Health to plan, execute, and report on corporate wellness events end-to-end — entirely from a mobile or web device, with no paperwork.

The application replaces manual, paper-based wellness day processes with a structured digital flow. Nurses, coordinators, and project managers each have a dedicated view tailored to their role. Data captured during screenings is stored securely in the cloud and is immediately available for reporting and analysis.

**At a glance:**

| Item | Detail |
|---|---|
| **Product Name** | Kenwell Health App |
| **Version** | 1.0 (initial release) |
| **Platforms** | Android · iOS · Web browser |
| **Primary Users** | Health Practitioners, Project Coordinators, Project Managers, Administrators, Clients |
| **Core Purpose** | Digital wellness event management and health screening |
| **Data Storage** | Cloud (Google Firebase) + on-device offline cache |
| **Development Status** | Feature-complete core; several enhancements pending |

---

## 2. The Problem We Are Solving

Before this application, Kenwell Health's wellness day operations relied heavily on:

- **Paper-based consent forms** — requiring manual scanning, filing, and storage
- **Spreadsheets for member registration** — prone to data entry errors and duplication
- **No real-time reporting** — results could only be compiled after the event, delaying insights for clients
- **No audit trail** — no reliable record of which nurse conducted which screening for which participant
- **Manual staff allocation** — tracking which nurse or coordinator is assigned to which event was managed informally

These manual processes created risks around **data accuracy**, **participant privacy**, **clinical documentation standards**, and **client reporting turnaround time**.

---

## 3. The Solution

The Kenwell Health App digitalises the entire wellness event lifecycle:

```
Plan Event  →  Allocate Staff  →  Run the Day  →  Report Results
    │                │                  │                │
Create &         Assign nurses     Nurses use        Management
schedule         & coordinators    the app to        views stats
events in        to events via     screen each       instantly
the system       the app           participant       after the day
```

**Key outcomes the app delivers:**

| Outcome | How |
|---|---|
| Paperless consent | Digital consent form with nurse's digital signature captured on-screen |
| Accurate participant records | Members registered by SA ID number or Passport; duplicates automatically detected |
| Real-time screening data | Each screening is saved to the cloud the moment it is completed |
| Live event monitoring | Managers can see how many participants have been screened during an active event |
| Instant reporting | Historical event statistics, screening outcomes, and referral rates are available at any time |
| Compliance-ready records | All screenings include the nurse's name, SANC registration number, date, and digital signature |
| Role-based access | Each staff member only sees and can do what their role permits |

---

## 4. Who Uses the System

The app supports **six user roles**, each with a specific set of permissions:

### 4.1 Role Overview

| Role | Who They Are | What They Can Do |
|---|---|---|
| **Admin** | System administrator | Full access to everything — users, events, reports, settings |
| **Top Management** | Executives / directors | Full access except permanent user deletion; access to all reports |
| **Project Manager** | Senior event planner | Create and manage events; manage users; view statistics and reports |
| **Project Coordinator** | On-site event coordinator | Conduct wellness flows; allocate staff to events; view calendar |
| **Health Practitioner** | Nurse / clinician | Conduct wellness flows and health screenings; view own events |
| **Client** | Corporate client contact | View event statistics and reports only |

### 4.2 Role Access Summary

```
                          ADMIN   TOP    PROJ    PROJ    HEALTH   CLIENT
                                  MGMT   MGR    COORD   PRACT
─────────────────────────────────────────────────────────────────────────
Create / Edit Events         ✅     ✅     ✅      ✗       ✗        ✗
Delete Events                ✅     ✅     ✅      ✗       ✗        ✗
Allocate Staff to Events     ✅     ✅     ✗       ✅      ✗        ✗
View Calendar                ✅     ✅     ✅      ✅      ✅        ✅
Conduct Wellness Flow        ✅     ✅     ✅      ✅      ✅        ✗
Register Members             ✅     ✅     ✅      ✅      ✅        ✗
View Statistics              ✅     ✅     ✅      ✗       ✗        ✅
Manage Users                 ✅     ✅     ✅      ✗       ✗        ✗
Delete Users                 ✅     ✗      ✗       ✗       ✗        ✗
Export Data                  ✅     ✅     ✅      ✗       ✗        ✗
```

---

## 5. How a Wellness Day Works with the App

The following is a plain-English description of a complete wellness day, from the morning setup to end-of-day reporting.

### Step 1: Before the Event — Planning & Setup

A **Project Manager** logs in and creates an event with:
- Event name, date, venue, address, and province
- Onsite contact and Account Executive contact details
- Services to be offered (e.g. HRA, TB screening, HCT, Cancer screening)
- Number of nurses and coordinators required
- Expected participant count and medical aid information
- Setup time, start time, end time, and strike-down time

### Step 2: Staff Allocation

A **Project Coordinator or Manager** allocates nurses and coordinators to the event through the app. Each allocated staff member then sees the event in their **"My Events"** screen.

### Step 3: On the Day — Starting the Event

The assigned practitioner or coordinator **starts the event** via the app (the start button only becomes active on the day of the event). The event status changes from *Scheduled* to *In Progress*.

### Step 4: Participant Wellness Flow

For every participant (called a **"member"** in the app), the nurse or coordinator guides them through a structured digital flow:

```
1. MEMBER SEARCH
   └─ Search by name, SA ID, or Passport number
   └─ If not found → Register as new member

2. CONSENT FORM
   └─ Participant confirms consent digitally
   └─ Nurse captures digital signature
   └─ Selected screenings are noted (HRA / HCT / TB / Cancer)

3. HEALTH SCREENINGS (only those consented to)
   │
   ├─ Health Risk Assessment (HRA)
   │   └─ Lifestyle questions (exercise, smoking, alcohol)
   │   └─ Biometrics (height, weight, BMI, blood pressure, cholesterol, blood sugar)
   │   └─ Gender-specific questions (Pap smear, mammogram, prostate)
   │   └─ Outcome: Healthy ✅ or At-Risk ⚠️ card shown to participant
   │
   ├─ HCT (HIV Counselling & Testing)
   │   └─ Pre-test counselling captured
   │   └─ Test result recorded (Reactive / Non-Reactive / Indeterminate)
   │   └─ Post-test counselling and nursing intervention recorded
   │
   ├─ TB Screening
   │   └─ 4 symptom questions (cough, blood in sputum, weight loss, night sweats)
   │   └─ TB history questions
   │   └─ Nurse intervention and referral decision
   │   └─ Nurse signs off with digital signature and SANC number
   │
   └─ Cancer Screening
       └─ Symptom checklist
       └─ Breast light examination findings
       └─ Liquid cytology (Pap smear) collection and result
       └─ PSA result
       └─ Referral decision and follow-up date

4. POST-SCREENING SURVEY
   └─ Brief satisfaction / feedback survey

5. COMPLETION
   └─ Participant screened count increments automatically
```

### Step 5: Ending the Event

When all participants have been seen, the practitioner **finishes the event** via the app. The event status changes to *Completed*.

### Step 6: After the Event — Reporting

Any authorised user can navigate to **Statistics** to view:
- Total participants screened
- Per-screening breakdown (HRA outcomes, TB referrals, HCT results, Cancer referrals)
- Comparison across past events
- Live count during an active event

---

## 6. Features — What Has Been Built

### 6.1 Feature Status Overview

| Feature | Status | Notes |
|---|---|---|
| User login & logout | ✅ Complete | Email + password via Firebase |
| Password reset by email | ✅ Complete | Firebase password reset flow |
| Role-based access control | ✅ Complete | 6 roles; enforced on every screen |
| Create / edit / delete events | ✅ Complete | Full event form with all required fields |
| Event calendar view | ✅ Complete | Monthly calendar with event dots and event list |
| Allocate staff to events | ⚠️ Partial | Screen exists but the route link is broken (see Section 10) |
| Start / finish event (lifecycle) | ✅ Complete | Time-locked to event date; status tracking |
| Member registration | ✅ Complete | SA ID and Passport supported; offline cache |
| Member search | ✅ Complete | Search by name, ID, or Passport |
| Informed consent form + digital signature | ✅ Complete | Captured and stored in the cloud |
| Health Risk Assessment (HRA) | ✅ Complete | Lifestyle + biometrics + gender-specific questions |
| HCT Screening | ✅ Complete | Counselling, test result, and nursing intervention |
| TB Screening | ✅ Complete | Symptom questions, TB history, nurse sign-off |
| Cancer Screening | ✅ Complete | Breast exam, Pap smear, PSA, referral |
| Nursing referral status cards | ✅ Complete | Animated Healthy / At-Risk result card per screening |
| Post-screening survey | ✅ Complete | Satisfaction and feedback capture |
| User management (create/edit/delete users) | ✅ Complete | Admin and management users only |
| Statistics and reporting | ✅ Complete | Per-event and cross-event stats with charts |
| Live screening count during event | ✅ Complete | Real-time counter visible to management |
| Past events reporting | ✅ Complete | Full history of completed events |
| Light and dark mode | ✅ Complete | User preference persisted across sessions |
| Help screen | ✅ Complete | In-app guidance |
| Profile management | ✅ Complete | Edit own details, change theme, log out |
| Excel data export | ⚠️ Partial | Package installed; export screens not yet wired up |
| HIV screening statistics in reports | ⚠️ Partial | Data captured but not shown in statistics cards |
| Push notifications | ❌ Not built | Planned feature; not yet implemented |
| PDF report generation | ❌ Not built | Planned feature; not yet implemented |
| Offline health screening submissions | ❌ Not built | Currently requires internet at time of screening |

### 6.2 Screening Services Currently Supported

| Screening | Status |
|---|---|
| Health Risk Assessment (HRA) | ✅ Active |
| HIV Counselling & Testing (HCT) | ✅ Active |
| TB Screening | ✅ Active |
| Cancer Screening (Breast, Pap Smear, PSA) | ✅ Active |
| Dental Screening | 🔲 Planned (not yet enabled) |
| Eye Test | 🔲 Planned (not yet enabled) |
| Psychological Assessment | 🔲 Planned (not yet enabled) |
| Posture Screening | 🔲 Planned (not yet enabled) |
| Massage Therapy | 🔲 Additional service (not a screening) |
| Smoothie Bar | 🔲 Additional service (not a screening) |
| Paediatric Care | 🔲 Additional service (not a screening) |

---

## 7. Platform & Availability

### 7.1 Where the App Runs

| Platform | Support | Notes |
|---|---|---|
| **Android** | ✅ Supported | Phones and tablets |
| **iOS** | ✅ Supported | iPhone and iPad |
| **Web browser** | ✅ Supported | Chrome, Edge, Safari — responsive layout adapts for desktop |
| **Windows desktop** | ⚠️ Partial | Build configuration exists; full Firebase support pending |

Because it is built with **Flutter**, a single codebase runs across all platforms. This means updates and new features are deployed to all platforms simultaneously, minimising maintenance cost.

### 7.2 Responsive Design

The app adapts its layout based on screen size:
- **Mobile (phones):** Bottom navigation bar
- **Desktop / Tablet (web):** Side navigation rail — more content visible at once

### 7.3 Connectivity

The app works in two modes:

| Mode | Behaviour |
|---|---|
| **Online (internet available)** | All data is read from and written to the cloud in real time |
| **Offline (no internet)** | Events and member records are available from the local device cache. *Note: health screening submissions currently require internet connectivity — see Section 10.* |

---

## 8. Data, Privacy & Security

### 8.1 Where Data Is Stored

All data is stored in two places:

| Storage | What It Holds | Accessible From |
|---|---|---|
| **Google Firebase (cloud)** | All user accounts, events, member records, consent forms, screening results, statistics | Any authorised device with internet access |
| **On-device database (SQLite)** | Local cache of events and member records for offline viewing | The specific device only |

Google Firebase is a **globally recognised, enterprise-grade cloud platform** used by thousands of healthcare and enterprise applications. All data in transit is protected by industry-standard **TLS encryption (HTTPS)**.

### 8.2 Who Can Access What

Access is strictly controlled:
- Every user must log in with an email address and password
- Firebase Authentication handles login security (no passwords are transmitted in plain text over the network)
- Every screen and every function is gated by the user's assigned role
- A nurse, for example, cannot access the statistics dashboard; a client cannot conduct screenings

### 8.3 Consent & POPIA Compliance

- Every participant gives **digital informed consent** before any screening commences
- The nurse's **digital signature** and **SANC registration number** are recorded against every screening
- Consent records store which specific screenings the participant agreed to
- Participant data includes SA ID numbers, health information, and contact details — this is **personal information** under POPIA (Protection of Personal Information Act) and must be treated accordingly

### 8.4 Data Sensitivity Classification

| Data Type | Sensitivity | Examples |
|---|---|---|
| User credentials | High | Passwords (managed by Firebase) |
| Participant health data | Very High | HIV results, TB screening, biometrics |
| Participant identity data | High | SA ID number, Passport number, date of birth |
| Event logistics data | Medium | Venue, date, contact details |
| Statistics / aggregate data | Low | Total screened count, referral rates |

### 8.5 Important Security Actions Required

> ⚠️ **Management Attention Required:** The following security items are not yet in place and represent risk to the business. See Section 10 for details.

1. Firestore database security rules need to be configured to prevent any authenticated user from accessing all data regardless of role.
2. Passwords stored in the local device database should be removed.
3. Email verification should be enforced before a new account can be used.

---

## 9. Current Status of the Product

### 9.1 Overall Readiness Assessment

| Area | Status | Confidence |
|---|---|---|
| Core wellness event workflow | ✅ Production-ready | High |
| Health screenings (HRA, HCT, TB, Cancer) | ✅ Production-ready | High |
| User and member management | ✅ Production-ready | High |
| Statistics and reporting | ✅ Production-ready | High |
| Role-based access control | ✅ Production-ready | High |
| Cloud data storage | ✅ Production-ready | High |
| Offline support (events & members) | ✅ Functional | Medium (screenings not yet offline) |
| Security hardening | ⚠️ Needs attention | Low (see Section 10) |
| Staff allocation (event assignment) | ⚠️ Partially broken | Medium (routing bug to fix) |
| Excel export | ⚠️ Incomplete | Not yet available to users |
| Push notifications | ❌ Not available | Not built |
| PDF reporting | ❌ Not available | Not built |
| Automated testing coverage | ❌ Not available | Risk to regression |

### 9.2 What Is Ready to Use Today

The following capabilities are complete and suitable for live use:

✅ **Wellness event management** — full event creation, scheduling, and status tracking  
✅ **Participant wellness flow** — end-to-end: consent → screenings → survey  
✅ **HRA, HCT, TB, Cancer screenings** — all four screening modules fully operational  
✅ **Digital consent with nurse signature** — legally documented  
✅ **Member registration and search** — SA ID and Passport  
✅ **User account management** — create, edit, assign roles  
✅ **Statistics and reporting** — per-event and historical  
✅ **Multi-platform** — Android, iOS, and Web  

### 9.3 What Needs to Be Done Before Full Production Rollout

| Item | Effort Estimate | Risk if Deferred |
|---|---|---|
| Fix Firestore security rules | Low (1–2 days developer time) | High — data exposure risk |
| Remove plain-text passwords from device | Low (1 day developer time) | High — device compromise risk |
| Fix staff allocation route | Low (half a day) | Medium — process gap |
| Enforce email verification on new accounts | Low (1 day developer time) | Medium — unauthorised access risk |

---

## 10. Risks & Issues Requiring Management Attention

The following issues have been identified in the current product. They are presented in priority order with recommended actions.

---

### 🔴 CRITICAL — Firestore Database Security Rules Not Configured

**What this means:**  
Currently, any user who is logged in can theoretically read or write any data in the cloud database — regardless of their role. The role restrictions that work correctly inside the app (a nurse cannot see the stats page) are enforced only within the application itself, not at the database level. A technically skilled person with a valid login could bypass the app and query data directly.

**Business Risk:** A data breach or unauthorised access to participant health data could result in POPIA violations, reputational damage, and legal liability.

**Recommended Action:** A developer should implement Firestore Security Rules (a standard Firebase feature) to enforce role-based access at the database level. Estimated effort: 1–2 working days.

---

### 🔴 CRITICAL — User Passwords Stored on Device in Plain Text

**What this means:**  
When a user logs in, their password is saved in a database file on the physical device. If someone gained physical access to the device, they could retrieve passwords.

**Business Risk:** Potential account compromise if a device is lost, stolen, or inspected.

**Recommended Action:** Remove the local password storage. Firebase Authentication (already in use) handles authentication securely — the local copy is redundant and risky. Estimated effort: 1 working day.

---

### 🟠 HIGH — Offline Health Screening Submissions Not Supported

**What this means:**  
If a nurse loses internet connectivity during a wellness event (poor signal at venue), any health screening data captured after connectivity is lost will not be saved to the cloud. The data would be lost.

**Business Risk:** Loss of participant health records; requirement to re-screen participants; potential complaints; compliance risk.

**Recommended Action:** Implement an offline queue that saves screenings locally and automatically uploads them when connectivity is restored. This is a moderate development effort (1–2 weeks).

---

### 🟠 HIGH — Staff Allocation Route Is Broken

**What this means:**  
The "Allocate Event" feature — which should allow coordinators to be assigned to specific events — has a programming error where clicking it takes the user to the wrong screen (Profile screen instead of the Allocate Event screen). The allocation screen exists in the app but is unreachable.

**Business Risk:** Staff cannot self-allocate to events through the app; coordinators must be allocated via a manual workaround.

**Recommended Action:** A developer needs to fix one configuration line. Estimated effort: less than 1 hour.

---

### 🟡 MEDIUM — Email Verification Not Enforced

**What this means:**  
When a new user account is created, they are sent a verification email by Firebase. However, they can log in and use the system even without verifying their email address.

**Business Risk:** Invalid email addresses on accounts; difficulty recovering access; slightly reduced security.

**Recommended Action:** Add a check that prevents login until email is verified. Estimated effort: half a day.

---

### 🟡 MEDIUM — No Automated Tests

**What this means:**  
The application has no automated test suite. This means that every time a developer makes a change, there is no automated safety net to catch if an existing feature was accidentally broken.

**Business Risk:** Regressions (previously working features breaking) may go undetected until they reach users.

**Recommended Action:** Commission the development of a core test suite covering the wellness flow, authentication, and reporting. Estimated effort: 2–3 weeks.

---

### 🟡 MEDIUM — HIV Statistics Not Visible in Reports

**What this means:**  
HIV screening data is captured during the HCT (HIV Counselling & Testing) flow and is stored in the cloud. However, HIV results are not yet shown in the Statistics & Reporting screens the way HRA, TB, and Cancer results are displayed.

**Business Risk:** Clients and management cannot see HCT outcomes in reports; incomplete picture for health risk analysis.

**Recommended Action:** Wire up existing HIV data to the statistics dashboard. Estimated effort: 1–2 days.

---

### 🟢 LOW — Excel Export Not Yet Available to Users

**What this means:**  
The technology for generating Excel files has been included in the app, but the actual export buttons/screens have not yet been built.

**Business Risk:** Clients cannot receive spreadsheet exports; reports must be communicated via the in-app statistics screens.

**Recommended Action:** Build the export screens and connect them to the data. Estimated effort: 3–5 days.

---

## 11. Recommended Roadmap & Next Investments

The following recommendations are grouped into timeframes based on urgency and business impact.

### Immediate Priorities (0–4 weeks) — Fix Before Full Rollout

| # | Action | Why | Effort |
|---|---|---|---|
| 1 | Fix Firestore security rules | Prevents data exposure; compliance with POPIA | 1–2 days |
| 2 | Remove plain-text password from device | Eliminates credential theft risk | 1 day |
| 3 | Fix staff allocation route | Restore broken business workflow | < 1 day |
| 4 | Enforce email verification | Stronger account security | 0.5 day |
| 5 | Show HIV statistics in reports | Complete the reporting picture | 1–2 days |

---

### Short-Term (1–3 months) — Strengthen and Complete

| # | Action | Business Benefit |
|---|---|---|
| 6 | **Offline screening submissions** | Protects against data loss at venues with poor connectivity; critical for field use |
| 7 | **Excel data export** | Allows client reporting in familiar spreadsheet format; reduces manual work |
| 8 | **Push notifications** | Notify practitioners of new event allocations; send reminders before event day |
| 9 | **PDF report generation** | Provide clients with branded, printable screening summary reports |
| 10 | **Automated test suite** | Protect against regressions as the app grows |

---

### Medium-Term (3–6 months) — Grow the Platform

| # | Action | Business Benefit |
|---|---|---|
| 11 | **Member health history** | Show a participant's screening trends across multiple events (valuable for wellness programmes) |
| 12 | **Management dashboard on home screen** | Live KPIs: events today, screened count, referral rate — visible at a glance for managers |
| 13 | **Activate additional screenings** | Enable dental, eye test, psychological, and posture screening modules when operationally ready |
| 14 | **POPIA / compliance audit trail** | Detailed log of every data access and modification for regulatory purposes |

---

### Long-Term (6–12 months) — Scale & Intelligence

| # | Action | Business Benefit |
|---|---|---|
| 15 | **Client self-service portal** | Allow client contacts to view their own event reports and statistics independently |
| 16 | **Aggregate analytics** | Cross-client anonymised health trend reports (industry benchmarking) |
| 17 | **Multi-language support** | Afrikaans, Zulu, Xhosa support for broader South African participant accessibility |
| 18 | **Firebase Crashlytics + Analytics** | Real-time crash reporting and usage analytics to guide product decisions |
| 19 | **CI/CD pipeline** | Automated build and release pipeline (faster, safer deployments) |
| 20 | **API integrations** | Potential integration with medical aid scheme portals or occupational health management systems |

---

## 12. Glossary

> Plain-language definitions of terms used in this document and in the app.

| Term | Meaning |
|---|---|
| **Member / Participant** | A person who attends a wellness event and undergoes screenings |
| **Wellness Event / Wellness Day** | A corporate health day organised by Kenwell Health for a client company |
| **HRA** | Health Risk Assessment — a questionnaire + biometric measurement covering lifestyle risk factors |
| **HCT** | HIV Counselling and Testing — includes pre-test counselling, the test, and post-test counselling |
| **TB Screening** | Tuberculosis symptom screening — checking for cough, night sweats, weight loss, and other TB indicators |
| **Cancer Screening** | Includes breast examination, Pap smear (cervical cancer), and PSA (prostate cancer) |
| **Pap Smear** | A test for early detection of cervical cancer; conducted via liquid cytology |
| **PSA** | Prostate-Specific Antigen — a blood test used to screen for prostate cancer risk |
| **Consent Form** | A digital form the participant signs to give permission for screenings to be performed |
| **Nursing Referral** | When a nurse determines a participant needs follow-up care at a medical facility |
| **SANC Number** | South African Nursing Council registration number — legally required for practising nurses |
| **Screened Count** | The total number of participants who completed the full wellness flow at an event |
| **AE Contact** | Account Executive — the Kenwell sales/account representative for a specific client |
| **Onsite Contact** | The client's representative present at the venue on the event day |
| **Strike-Down Time** | The time at which Kenwell's equipment is packed away after an event ends |
| **Firebase** | Google's cloud platform used to store and manage app data securely |
| **POPIA** | Protection of Personal Information Act — South African data privacy law |
| **Flutter** | The software framework used to build the app (runs on Android, iOS, and Web from one codebase) |
| **Offline Mode** | The app's ability to operate without an internet connection using locally cached data |
| **Role / User Role** | A defined set of permissions assigned to a user (e.g. Admin, Nurse, Client) |

---

*This document was prepared for internal management and executive use. For the full technical reference, see `TECHNICAL_DOCUMENT.md`. For questions, contact the development team.*
