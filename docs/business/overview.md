# Business Overview — Kenwell Health App

## Problem Statement

Millions of people in underserved communities in South Africa lack access to preventive health care. Mobile wellness events — where nurses and health practitioners travel to communities to provide free health screenings — are a proven way to bridge this gap. However, coordinating these events, capturing clinical data on low-connectivity devices, managing patient consent, and reporting outcomes to programme managers currently relies on paper forms and disconnected spreadsheets.

The **Kenwell Health App** digitises the entire workflow: from scheduling a wellness event and registering community members, through conducting health screenings, to generating management reports — all on a single mobile-first platform that works offline.

---

## Value Proposition

| Stakeholder | Value Delivered |
|---|---|
| **Community Members** | Free, structured health assessments with clear referral outcomes and a personal health record |
| **Health Practitioners (Nurses)** | Guided digital screening workflows replace paper forms; smart risk flags reduce clinical errors |
| **Project Coordinators** | Real-time event progress visibility; easy member allocation and event management |
| **Project Managers / Top Management** | Live statistics, exportable reports, province-level participation rates, no manual aggregation |
| **System Administrators** | Role-based user management; audit log; Firebase-backed security rules |

---

## Product Goals

1. **Eliminate paper** — all clinical data captured digitally at the point of care.
2. **Work offline** — data is saved locally (SQLite) and synced to Firestore when connectivity is restored.
3. **Ensure consent** — no clinical screening proceeds without a recorded informed consent form.
4. **Referral traceability** — every health screening produces a clear "healthy / at-risk" outcome with risk flags.
5. **Accessible reports** — management dashboards and downloadable PDF/CSV reports with zero manual work.

---

## Target Market

- Non-profit organisations and NGOs running community health programmes in South Africa
- Corporate wellness programme providers
- Government and clinic-based mobile health outreach teams

---

## Core Entities

| Entity | Description |
|---|---|
| **Wellness Event** | A scheduled mobile health event at a specific venue and date |
| **Member** | A community participant registered at an event |
| **Consent Form** | Signed informed consent captured before any screening |
| **Health Screening** | HIV test, TB test, Cancer screening, or Health Risk Assessment (HRA) |
| **HIV Test Result** | Clinical result of an HIV rapid test |
| **Nurse Intervention / Referral** | Documented nursing action or clinic referral following a screening |
| **Survey** | Post-screening feedback questionnaire |
| **User** | A platform user (nurse, coordinator, manager, admin) |

---

## Success Metrics

- Number of members registered per event
- Screening completion rate (members screened / members registered)
- Referral rate (at-risk outcomes / total screened)
- Data sync rate (pending writes resolved within 24 hours)
- Report export time (target: < 30 seconds per event)