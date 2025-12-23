# CRITICAL: Database Code Generation Required

## ⚠️ ACTION REQUIRED BEFORE RUNNING THE APP

The database schema has been updated to include a new `Members` table. The auto-generated code file (`lib/data/local/app_database.g.dart`) needs to be regenerated to include this new table.

### How to Regenerate

Run the following command in the project root:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or use the provided script:

```bash
./regenerate_db.sh
```

### Why is this needed?

The Drift ORM (Object-Relational Mapping) library requires code generation to create:
1. Table definitions
2. Entity classes
3. Companion classes for inserts/updates
4. Query builders
5. Type-safe database access methods

Without regenerating the code, you will see compilation errors like:
- "The getter 'members' isn't defined for the type 'AppDatabase'"
- "Undefined class 'MemberEntity'"
- "Undefined class 'MembersCompanion'"

### What changed?

In `lib/data/local/app_database.dart`:
1. Added `Members` table definition (lines 25-46)
2. Updated `@DriftDatabase` annotation to include `Members`
3. Incremented schema version from 12 to 13
4. Added migration logic for version 13
5. Added CRUD operations for members (lines 318-383)

### If regeneration fails

1. Make sure Flutter SDK is properly installed: `flutter --version`
2. Clean the project: `flutter clean`
3. Get dependencies: `flutter pub get`
4. Try regenerating again: `flutter pub run build_runner build --delete-conflicting-outputs`

If errors persist, check:
- Syntax in `lib/data/local/app_database.dart`
- All imports are correct
- `pubspec.yaml` has the correct Drift dependencies
