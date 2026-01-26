import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../local/app_database.dart';
import 'firestore_service.dart';

/// Migration result summary
class MigrationResult {
  final int usersMigrated;
  final int eventsMigrated;
  final List<String> errors;
  final bool success;

  MigrationResult({
    required this.usersMigrated,
    required this.eventsMigrated,
    required this.errors,
    required this.success,
  });

  @override
  String toString() =>
      'MigrationResult(users: $usersMigrated, events: $eventsMigrated, errors: ${errors.length}, success: $success)';
}

/// Service to migrate data from local Drift database to Firestore
class DataMigrationService {
  final AppDatabase _localDb;
  final FirestoreService _firestore;
  final FirebaseFirestore _firestoreInstance;

  DataMigrationService({
    AppDatabase? localDatabase,
    FirestoreService? firestoreService,
  })  : _localDb = localDatabase ?? AppDatabase.instance,
        _firestore = firestoreService ?? FirestoreService(),
        _firestoreInstance = FirebaseFirestore.instance;

  /// Migrate all users from Drift to Firestore
  /// Note: Passwords are NOT migrated as Firebase handles authentication
  Future<int> migrateUsers() async {
    try {
      final localUsers = await _localDb.getAllUsers();
      int migratedCount = 0;

      debugPrint('Starting user migration: ${localUsers.length} users found');

      for (final userEntity in localUsers) {
        try {
          // Check if user already exists in Firestore
          final existingDoc = await _firestoreInstance
              .collection(FirestoreService.usersCollection)
              .doc(userEntity.id)
              .get();

          if (existingDoc.exists) {
            debugPrint(
                'User ${userEntity.email} already exists in Firestore, skipping');
            continue;
          }

          // Create user document in Firestore
          // Note: Password is excluded as Firebase Auth manages authentication
          final userData = {
            'id': userEntity.id,
            'email': userEntity.email,
            'role': userEntity.role,
            'firstName': userEntity.firstName,
            'lastName': userEntity.lastName,
            'phoneNumber': userEntity.phoneNumber,
            'createdAt': Timestamp.fromDate(userEntity.createdAt),
            'updatedAt': Timestamp.fromDate(userEntity.updatedAt),
          };

          await _firestore.createDocument(
            collection: FirestoreService.usersCollection,
            documentId: userEntity.id,
            data: userData,
          );

          migratedCount++;
          debugPrint('Migrated user: ${userEntity.email}');
        } catch (e) {
          debugPrint('Error migrating user ${userEntity.email}: $e');
        }
      }

      debugPrint('User migration complete: $migratedCount users migrated');
      return migratedCount;
    } catch (e, stackTrace) {
      debugPrint('User migration error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Migrate all events from Drift to Firestore
  Future<int> migrateEvents() async {
    try {
      final localEvents = await _localDb.getAllEvents();
      int migratedCount = 0;

      debugPrint(
          'Starting event migration: ${localEvents.length} events found');

      for (final eventEntity in localEvents) {
        try {
          // Check if event already exists in Firestore
          final existingDoc = await _firestoreInstance
              .collection(FirestoreService.eventsCollection)
              .doc(eventEntity.id)
              .get();

          if (existingDoc.exists) {
            debugPrint(
                'Event ${eventEntity.title} already exists in Firestore, skipping');
            continue;
          }

          // Create event document in Firestore
          final eventData = _eventEntityToMap(eventEntity);

          await _firestore.createDocument(
            collection: FirestoreService.eventsCollection,
            documentId: eventEntity.id,
            data: eventData,
          );

          migratedCount++;
          debugPrint('Migrated event: ${eventEntity.title}');
        } catch (e) {
          debugPrint('Error migrating event ${eventEntity.title}: $e');
        }
      }

      debugPrint('Event migration complete: $migratedCount events migrated');
      return migratedCount;
    } catch (e, stackTrace) {
      debugPrint('Event migration error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Migrate all data (users and events)
  Future<MigrationResult> migrateAll() async {
    final errors = <String>[];
    int usersMigrated = 0;
    int eventsMigrated = 0;

    try {
      // Migrate users
      try {
        usersMigrated = await migrateUsers();
      } catch (e) {
        errors.add('User migration failed: $e');
      }

      // Migrate events
      try {
        eventsMigrated = await migrateEvents();
      } catch (e) {
        errors.add('Event migration failed: $e');
      }

      return MigrationResult(
        usersMigrated: usersMigrated,
        eventsMigrated: eventsMigrated,
        errors: errors,
        success: errors.isEmpty,
      );
    } catch (e, stackTrace) {
      debugPrint('Migration error: $e');
      debugPrintStack(stackTrace: stackTrace);
      errors.add('General migration error: $e');

      return MigrationResult(
        usersMigrated: usersMigrated,
        eventsMigrated: eventsMigrated,
        errors: errors,
        success: false,
      );
    }
  }

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      // Check if there's local data
      final localUsers = await _localDb.getAllUsers();
      final localEvents = await _localDb.getAllEvents();

      if (localUsers.isEmpty && localEvents.isEmpty) {
        return false; // No local data to migrate
      }

      // Check if Firestore has data
      final usersSnapshot = await _firestoreInstance
          .collection(FirestoreService.usersCollection)
          .limit(1)
          .get();

      final eventsSnapshot = await _firestoreInstance
          .collection(FirestoreService.eventsCollection)
          .limit(1)
          .get();

      // Migration needed if we have local data but Firestore is empty
      return (localUsers.isNotEmpty && usersSnapshot.docs.isEmpty) ||
          (localEvents.isNotEmpty && eventsSnapshot.docs.isEmpty);
    } catch (e) {
      debugPrint('Error checking migration status: $e');
      return false;
    }
  }

  /// Get migration status
  Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      final localUsers = await _localDb.getAllUsers();
      final localEvents = await _localDb.getAllEvents();

      final usersSnapshot = await _firestoreInstance
          .collection(FirestoreService.usersCollection)
          .get();

      final eventsSnapshot = await _firestoreInstance
          .collection(FirestoreService.eventsCollection)
          .get();

      return {
        'local': {
          'users': localUsers.length,
          'events': localEvents.length,
        },
        'firestore': {
          'users': usersSnapshot.docs.length,
          'events': eventsSnapshot.docs.length,
        },
        'needsMigration': await isMigrationNeeded(),
      };
    } catch (e) {
      debugPrint('Error getting migration status: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// Convert EventEntity to Firestore map
  Map<String, dynamic> _eventEntityToMap(EventEntity entity) {
    return {
      'id': entity.id,
      'title': entity.title,
      'date': Timestamp.fromDate(entity.date),
      'venue': entity.venue,
      'address': entity.address,
      'townCity': entity.townCity,
      'province': entity.province,
      'onsiteContactFirstName': entity.onsiteContactFirstName,
      'onsiteContactLastName': entity.onsiteContactLastName,
      'onsiteContactNumber': entity.onsiteContactNumber,
      'onsiteContactEmail': entity.onsiteContactEmail,
      'aeContactFirstName': entity.aeContactFirstName,
      'aeContactLastName': entity.aeContactLastName,
      'aeContactNumber': entity.aeContactNumber,
      'aeContactEmail': entity.aeContactEmail,
      'servicesRequested': entity.servicesRequested,
      'additionalServicesRequested': entity.additionalServicesRequested,
      'expectedParticipation': entity.expectedParticipation,
      'nurses': entity.nurses,
      'coordinators': entity.coordinators,
      'setUpTime': entity.setUpTime,
      'startTime': entity.startTime,
      'endTime': entity.endTime,
      'strikeDownTime': entity.strikeDownTime,
      'mobileBooths': entity.mobileBooths,
      'medicalAid': entity.medicalAid,
      'description': entity.description,
      'status': entity.status,
      'actualStartTime': entity.actualStartTime != null
          ? Timestamp.fromDate(entity.actualStartTime!)
          : null,
      'actualEndTime': entity.actualEndTime != null
          ? Timestamp.fromDate(entity.actualEndTime!)
          : null,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
    };
  }
}
