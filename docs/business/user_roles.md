# User Roles & Permissions

The Kenwell Health App uses **Firebase Authentication** combined with a Firestore `users` collection to implement role-based access control (RBAC). Each user document has a `role` field that controls which screens and operations are accessible.

Firestore Security Rules enforce these boundaries at the server side (`firestore.rules`).

---

## Roles

### 1. Admin

**Purpose:** Full system access for IT administrators and system owners.

**Capabilities:**
- All capabilities of every other role
- Create, edit, and delete user accounts
- View the audit log
- Manage Firebase configuration

**Firestore rule function:** `isAdmin()`

---

### 2. Top Management

**Purpose:** Executive overview with read-only access to all data.

**Capabilities:**
- View all events and event statistics
- Export reports (PDF / CSV)
- View member lists and screening outcomes
- No data entry

**Firestore rule function:** `isTopManager()`

---

### 3. Project Manager

**Purpose:** Programme oversight and resource allocation.

**Capabilities:**
- Create, edit, and delete wellness events
- View event statistics and reports
- Allocate/unallocate staff and community members to events
- View member data and screening outcomes

**Firestore rule function:** `isProjectManager()`

---

### 4. Project Coordinator

**Purpose:** Day-to-day event coordination and member management.

**Capabilities:**
- Create and manage wellness events
- Register community members
- Allocate members and staff to events
- View screening outcomes for their events
- Cannot delete members or export reports

**Firestore rule function:** `isCoordinator()`

---

### 5. Health Practitioner (Nurse)

**Purpose:** Clinical data capture during wellness events.

**Capabilities:**
- Access the wellness flow for assigned events
- Record informed consent
- Conduct and submit:
  - HIV test
  - HIV test result
  - TB screening
  - Cancer screening
  - Health Risk Assessment (HRA)
  - Health metrics
  - Nurse intervention / referral
  - Post-screening survey
- View their own event assignments ("My Events")

**Firestore rule function:** `isPractitioner()`

---

### 6. Client

**Purpose:** Community member self-service (future roadmap).

**Capabilities:**
- View own health record (read-only)
- View own event history

**Firestore rule function:** `isClient()`

---

## Staff vs Client

The Firestore rules use a composite `isStaff()` helper that grants elevated read access to Admin, Top Management, Project Manager, Project Coordinator, and Health Practitioner roles. Clients only access their own records.

```
isStaff() = isAdmin() || isTopManager() || isProjectManager() || isCoordinator() || isPractitioner()
```

---

## Role Assignment

Roles are assigned by an Admin through the **User Management** screen. The admin sets the `role` field on the user's Firestore document. Role changes take effect immediately on the next authenticated request.

---

## Wellness Flow Access Control

The **Wellness Flow** (the guided multi-step screening wizard) is only accessible to Health Practitioners. The flow steps rendered are configured per-event and may include any combination of:

1. Member Registration
2. Consent Form
3. HIV Test
4. HIV Test Results
5. TB Screening
6. Cancer Screening
7. Health Risk Assessment
8. Health Metrics
9. Nurse Intervention / Referral
10. Survey

Steps not configured for an event are skipped automatically.
