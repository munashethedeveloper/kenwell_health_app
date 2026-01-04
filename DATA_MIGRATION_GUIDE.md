# Data Migration and Synchronization Guide

This guide explains how to migrate data from local Drift database to Firestore and the synchronization strategy.

## Overview

The app currently stores data locally using **Drift (SQLite)**. To use Firebase, you need to:
1. **Migrate existing local data** to Firestore (one-time operation)
2. **Switch to using Firestore** for all new data operations
3. **Understand the sync strategy** (automatic real-time sync)

## Migration Strategy

### One-Time Migration (Recommended)

Migrate all existing local data to Firestore once, then use Firestore exclusively.

**Advantages:**
- ✅ Simple architecture
- ✅ Single source of truth (Firestore)
- ✅ Real-time sync across devices
- ✅ No sync conflicts
- ✅ Firestore handles offline caching automatically

**Disadvantages:**
- ❌ Requires internet connection for first migration
- ❌ Local data becomes read-only after migration

### Hybrid Approach (Not Recommended)

Keep both local and Firestore databases and sync between them.

**Disadvantages:**
- ❌ Complex sync logic needed
- ❌ Potential data conflicts
- ❌ Increased maintenance burden
- ❌ Duplicate storage

**Our Recommendation:** Use **one-time migration** to Firestore.

## Implementation

### 1. Migration Service

The `DataMigrationService` handles migrating data from Drift to Firestore.

**Location:** `lib/data/services/data_migration_service.dart`

**Features:**
- Migrates users (excluding passwords - Firebase handles auth)
- Migrates events with all fields
- Checks for existing data to avoid duplicates
- Provides migration status and results

**Usage:**

```dart
import 'package:kenwell_health_app/data/services/data_migration_service.dart';

final migrationService = DataMigrationService();

// Check if migration is needed
final needsMigration = await migrationService.isMigrationNeeded();

if (needsMigration) {
  // Get current status
  final status = await migrationService.getMigrationStatus();
  print('Local users: ${status['local']['users']}');
  print('Local events: ${status['local']['events']}');
  print('Firestore users: ${status['firestore']['users']}');
  print('Firestore events: ${status['firestore']['events']}');
  
  // Perform migration
  final result = await migrationService.migrateAll();
  
  if (result.success) {
    print('Migration successful!');
    print('Users migrated: ${result.usersMigrated}');
    print('Events migrated: ${result.eventsMigrated}');
  } else {
    print('Migration had errors: ${result.errors}');
  }
}
```

### 2. Adding Migration UI

Create a migration screen or button in your app:

**Example Migration Button in Settings:**

```dart
// In SettingsScreen or similar
import 'package:kenwell_health_app/data/services/data_migration_service.dart';

class MigrationButton extends StatefulWidget {
  const MigrationButton({super.key});

  @override
  State<MigrationButton> createState() => _MigrationButtonState();
}

class _MigrationButtonState extends State<MigrationButton> {
  final _migrationService = DataMigrationService();
  bool _isMigrating = false;
  bool _needsMigration = false;

  @override
  void initState() {
    super.initState();
    _checkMigrationStatus();
  }

  Future<void> _checkMigrationStatus() async {
    final needsMigration = await _migrationService.isMigrationNeeded();
    setState(() {
      _needsMigration = needsMigration;
    });
  }

  Future<void> _performMigration() async {
    setState(() => _isMigrating = true);

    try {
      final result = await _migrationService.migrateAll();

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Migration successful! '
              'Users: ${result.usersMigrated}, '
              'Events: ${result.eventsMigrated}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() => _needsMigration = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migration errors: ${result.errors.join(', ')}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Migration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isMigrating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsMigration) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Migration Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have local data that needs to be migrated to the cloud. '
              'This is a one-time operation and requires internet connection.',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isMigrating ? null : _performMigration,
              icon: _isMigrating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isMigrating ? 'Migrating...' : 'Migrate to Cloud'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Automatic Migration on First Launch

You can also perform migration automatically when the app detects local data:

**In your main app initialization:**

```dart
// In main.dart or splash screen
Future<void> _initializeApp() async {
  final migrationService = DataMigrationService();
  final needsMigration = await migrationService.isMigrationNeeded();

  if (needsMigration) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Migrating data to cloud...'),
          ],
        ),
      ),
    );

    // Perform migration
    final result = await migrationService.migrateAll();

    // Close loading dialog
    Navigator.of(context).pop();

    // Show result
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data migrated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Continue with app initialization
}
```

## Synchronization Strategy

### Firestore Automatic Sync

Once you switch to Firestore, synchronization is **automatic and real-time**:

**How it works:**
1. **Write operations** are sent to Firestore immediately
2. **Offline support** - Firestore caches data locally and syncs when online
3. **Real-time listeners** update UI automatically when data changes
4. **Multi-device sync** - Changes sync across all devices automatically

**No manual sync needed!** Firestore handles everything.

### Using Firestore Event Repository

Replace `EventRepository` (Drift) with `FirestoreEventRepository`:

**Before (Drift):**
```dart
import 'package:kenwell_health_app/data/repositories_dcl/event_repository.dart';

final repository = EventRepository();
final events = await repository.fetchAllEvents();
```

**After (Firestore):**
```dart
import 'package:kenwell_health_app/data/repositories_dcl/firestore_event_repository.dart';

final repository = FirestoreEventRepository();
final events = await repository.fetchAllEvents(); // Auto-syncs
```

### Real-Time Updates

Use streams for live updates:

```dart
final repository = FirestoreEventRepository();

// Watch all events - updates automatically
StreamBuilder<List<WellnessEvent>>(
  stream: repository.watchAllEvents(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final events = snapshot.data!;
      return ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(event: events[index]);
        },
      );
    }
    return const CircularProgressIndicator();
  },
)

// Watch single event
StreamBuilder<WellnessEvent?>(
  stream: repository.watchEvent(eventId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final event = snapshot.data!;
      return EventDetails(event: event);
    }
    return const CircularProgressIndicator();
  },
)
```

## Data Structure in Firestore

### Users Collection

```
firestore/users/{userId}
  - id: string
  - email: string
  - role: string
  - firstName: string
  - lastName: string
  - phoneNumber: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

**Note:** Passwords are NOT stored. Firebase Authentication manages credentials.

### Events Collection

```
firestore/events/{eventId}
  - id: string
  - title: string
  - date: timestamp
  - venue: string
  - address: string
  - townCity: string
  - province: string
  - onsiteContactFirstName: string
  - onsiteContactLastName: string
  - onsiteContactNumber: string
  - onsiteContactEmail: string
  - aeContactFirstName: string
  - aeContactLastName: string
  - aeContactNumber: string
  - aeContactEmail: string
  - servicesRequested: string
  - additionalServicesRequested: string
  - expectedParticipation: number
  - nurses: number
  - coordinators: number
  - setUpTime: string
  - startTime: string
  - endTime: string
  - strikeDownTime: string
  - mobileBooths: string
  - medicalAid: string
  - description: string (nullable)
  - status: string
  - actualStartTime: timestamp (nullable)
  - actualEndTime: timestamp (nullable)
  - createdAt: timestamp
  - updatedAt: timestamp
```

## Migration Checklist

- [ ] **1. Set up Firebase** (complete `flutterfire configure`)
- [ ] **2. Enable Firestore** in Firebase Console
- [ ] **3. Configure security rules** (see ROLE_BASED_ACCESS_CONTROL.md)
- [ ] **4. Add migration button** to your app (optional)
- [ ] **5. Perform migration** (either manually or automatically)
- [ ] **6. Verify data** in Firebase Console
- [ ] **7. Update repositories** to use Firestore
- [ ] **8. Test sync** across devices
- [ ] **9. (Optional) Clear local database** after successful migration

## Testing Migration

### Test Locally

1. **Before migration:**
   ```dart
   final status = await migrationService.getMigrationStatus();
   print(status);
   ```

2. **Perform migration:**
   ```dart
   final result = await migrationService.migrateAll();
   print(result);
   ```

3. **Verify in Firebase Console:**
   - Go to Firestore Database
   - Check `users` collection
   - Check `events` collection
   - Verify data matches local database

### Test Sync

1. **Add event on Device A:**
   ```dart
   await firestoreEventRepository.addEvent(newEvent);
   ```

2. **Check Device B:**
   - Event should appear automatically (if using `watchAllEvents()`)
   - Or refresh to see new event

3. **Update event on Device B:**
   ```dart
   await firestoreEventRepository.updateEvent(updatedEvent);
   ```

4. **Check Device A:**
   - Changes should appear automatically

## Offline Support

Firestore provides built-in offline support:

**How it works:**
1. **While online:** Data syncs immediately
2. **Going offline:** Firestore caches all accessed data locally
3. **While offline:** Reads work from cache, writes queue for sync
4. **Back online:** Queued writes sync automatically

**No code changes needed!** It's automatic.

**Configure offline persistence:**
```dart
// In main.dart, after Firebase.initializeApp()
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## Important Notes

### User Migration

**Passwords are NOT migrated** because:
- Firebase Authentication handles passwords securely
- Local passwords can't be imported into Firebase Auth
- Users need to use Firebase Auth (already implemented)

**What happens to local users:**
- User metadata (email, role, name, phone) is migrated
- Users must authenticate with Firebase Auth
- On first login, Firebase creates auth user + links to profile

### Event Migration

**All event data is migrated:**
- All fields preserved
- Dates converted to Firestore timestamps
- No data loss

### After Migration

**Local database:**
- Can be kept as backup (read-only)
- Can be cleared to save space
- Won't be updated with new data

**Firestore:**
- Becomes primary data source
- All new data goes here
- Syncs across devices automatically

## Troubleshooting

**"Migration shows 0 items migrated":**
- Check that local database has data
- Verify Firestore connection
- Check for existing data in Firestore

**"Permission denied during migration":**
- Update Firestore security rules
- Ensure user is authenticated
- Check role permissions

**"Events not syncing":**
- Check internet connection
- Verify Firestore rules allow read/write
- Check for console errors

**"Duplicate data after migration":**
- Migration service checks for existing data
- Safe to run multiple times
- Only new data is migrated

## Summary

**Recommended Approach:**
1. ✅ Perform **one-time migration** using `DataMigrationService`
2. ✅ Switch all repositories to use **Firestore** versions
3. ✅ Use **real-time streams** for automatic sync
4. ✅ Let **Firestore handle offline support** automatically
5. ❌ **No manual sync button needed** - it's automatic!

**Result:**
- Data syncs automatically across devices
- Offline support built-in
- Real-time updates in UI
- Single source of truth (Firestore)
- Firebase handles all the complexity

For implementation examples, see:
- `lib/data/services/data_migration_service.dart`
- `lib/data/repositories_dcl/firestore_event_repository.dart`
- `FIREBASE_SETUP.md` for Firestore configuration
