# Kenwell Health App — Documentation

This directory contains the full technical and business documentation for the **Kenwell Health App** — a Flutter-based field health management platform for coordinating mobile wellness events, health screenings, and community member data.

---

## Contents

### Business Documentation

| Document | Description |
|---|---|
| [business/overview.md](business/overview.md) | Product purpose, problem statement, value proposition |
| [business/features.md](business/features.md) | Full feature catalogue with user flows |
| [business/user_roles.md](business/user_roles.md) | User roles, permissions, and role-based access control |

### Technical Documentation

| Document | Description |
|---|---|
| [technical/architecture.md](technical/architecture.md) | Clean Architecture, MVVM pattern, layer boundaries |
| [technical/use_cases.md](technical/use_cases.md) | All 19 domain use cases — purpose, inputs, outputs |
| [technical/data_layer.md](technical/data_layer.md) | Repositories, Firestore schema, SQLite offline queue |
| [technical/testing.md](technical/testing.md) | Test strategy, coverage areas, how to run tests |
| [technical/deployment.md](technical/deployment.md) | CI/CD pipeline, Firebase Hosting, App Hosting, release process |

### Production Readiness

| Document | Description |
|---|---|
| [production_readiness.md](production_readiness.md) | Production readiness score card, gaps, future roadmap |

---

## Quick Reference

- **Framework:** Flutter 3 / Dart ≥ 3.4  
- **Backend:** Firebase (Firestore, Auth, Crashlytics, Performance)  
- **Local storage:** SQLite via Drift ORM  
- **State management:** Provider + ChangeNotifier (MVVM)  
- **Navigation:** go_router  
- **CI:** GitHub Actions → Firebase Hosting preview + production deploy  

---

## Getting Started (Developers)

```bash
# Clone and install
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run in development
flutter run

# Run all tests
flutter test --coverage

# Lint
flutter analyze --fatal-infos
dart format --set-exit-if-changed .
```

See [technical/deployment.md](technical/deployment.md) for full environment setup, signing configuration, and deployment procedures.
