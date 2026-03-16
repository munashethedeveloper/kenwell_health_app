import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import '../../domain/models/wellness_event.dart';
import '../local/app_database.dart';

/// Repository that provides a **local-first, offline-capable** data layer for
/// wellness events.
///
/// ## Sync strategy
///
/// | Operation   | Online behaviour                         | Offline behaviour                  |
/// |-------------|------------------------------------------|------------------------------------|
/// | `fetchAll`  | Fetches from Firestore, caches to local  | Returns cached local rows          |
/// | `upsert`    | Writes to Firestore, mirrors to local    | **Throws** – caller should surface an offline error |
/// | `delete`    | Deletes from Firestore + local cache     | **Throws**                         |
/// | `fetchById` | Firestore first, falls back to local     | Returns cached local row           |
///
/// > The local Drift database acts as a read-through **cache**.  The source of
/// > truth is always Firestore; the local cache ensures the app can show
/// > previously loaded events without a network connection.
class EventRepository {
  EventRepository({FirebaseFirestore? firestore, AppDatabase? localDb})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _localDb = localDb ?? AppDatabase.instance;

  final FirebaseFirestore _firestore;
  final AppDatabase _localDb;
  static const String _collectionName = 'events';

  // ── Read operations ────────────────────────────────────────────────────────

  /// Fetches all events.
  ///
  /// **Online**: Reads from Firestore and silently refreshes the local cache.
  /// **Offline**: Falls back to the locally cached rows so the calendar can
  ///              still be displayed without a network connection.
  Future<List<WellnessEvent>> fetchAllEvents() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      final events = snapshot.docs
          .map((doc) => _mapFirestoreToDomain(doc.id, doc.data()))
          .toList();
      debugPrint(
          'EventRepository: Fetched ${events.length} events from Firestore');

      // Cache the fresh data into the local Drift DB.
      await _cacheEventsLocally(events);
      return events;
    } catch (e, stackTrace) {
      debugPrint('EventRepository: Firestore fetch failed – $e');
      debugPrint('EventRepository: Stack trace: $stackTrace');

      // Attempt to serve from the local cache.
      try {
        final cached = await _localDb.getAllEvents();
        if (cached.isNotEmpty) {
          debugPrint(
              'EventRepository: Serving ${cached.length} events from local cache');
          return cached.map(_mapEntityToDomain).toList();
        }
      } catch (localErr) {
        debugPrint('EventRepository: Local cache read failed – $localErr');
      }

      // Re-throw the original Firestore error when no cached data is available.
      rethrow;
    }
  }

  /// Fetches a single event by [id].
  ///
  /// Falls back to the local cache when Firestore is unreachable.
  Future<WellnessEvent?> fetchEventById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return _mapFirestoreToDomain(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('EventRepository: Firestore fetchById failed – $e');
      // Fallback to local cache
      try {
        final entity = await _localDb.getEventById(id);
        if (entity != null) return _mapEntityToDomain(entity);
      } catch (_) {}
      rethrow;
    }
  }

  // ── Write operations ───────────────────────────────────────────────────────

  Future<void> addEvent(WellnessEvent event) => upsertEvent(event);

  Future<void> updateEvent(WellnessEvent updatedEvent) =>
      upsertEvent(updatedEvent);

  /// Saves an event to Firestore **and** mirrors it in the local cache.
  Future<void> upsertEvent(WellnessEvent event) async {
    try {
      debugPrint(
          'EventRepository: Saving event "${event.title}" id=${event.id}');
      await _firestore
          .collection(_collectionName)
          .doc(event.id)
          .set(_mapDomainToFirestore(event));
      debugPrint('EventRepository: Event saved to Firestore');

      // Mirror into local cache so it is immediately available offline.
      await _localDb.upsertEvent(_mapDomainToEntity(event));
    } catch (e, stackTrace) {
      debugPrint('EventRepository: ERROR saving event – $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Deletes an event from Firestore **and** removes it from the local cache.
  Future<void> deleteEvent(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
    await _localDb.deleteEventById(id);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Writes all [events] into the local Drift DB using upsert semantics.
  Future<void> _cacheEventsLocally(List<WellnessEvent> events) async {
    try {
      for (final event in events) {
        await _localDb.upsertEvent(_mapDomainToEntity(event));
      }
    } catch (e) {
      // Non-fatal: caching is best-effort.
      debugPrint('EventRepository: Local cache write failed – $e');
    }
  }

  WellnessEvent _mapFirestoreToDomain(String id, Map<String, dynamic> data) {
    return WellnessEvent(
      id: id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      venue: data['venue'] ?? '',
      address: data['address'] ?? '',
      townCity: data['townCity'] ?? '',
      province: data['province'] ?? '',
      onsiteContactFirstName: data['onsiteContactFirstName'] ?? '',
      onsiteContactLastName: data['onsiteContactLastName'] ?? '',
      onsiteContactNumber: data['onsiteContactNumber'] ?? '',
      onsiteContactEmail: data['onsiteContactEmail'] ?? '',
      aeContactFirstName: data['aeContactFirstName'] ?? '',
      aeContactLastName: data['aeContactLastName'] ?? '',
      aeContactNumber: data['aeContactNumber'] ?? '',
      aeContactEmail: data['aeContactEmail'] ?? '',
      servicesRequested: data['servicesRequested'] ?? '',
      //  additionalServicesRequested: data['additionalServicesRequested'] ?? '',
      expectedParticipation: data['expectedParticipation'] ?? 0,
      nurses: data['nurses'] ?? 0,
      //   coordinators: data['coordinators'] ?? 0,
      setUpTime: data['setUpTime'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      strikeDownTime: data['strikeDownTime'] ?? '',
      mobileBooths: data['mobileBooths'] ?? 0,
      description: data['description'] ?? '',
      medicalAid: data['medicalAid'] ?? '',
      status: data['status'] ?? '',
      actualStartTime: (data['actualStartTime'] as Timestamp?)?.toDate(),
      actualEndTime: (data['actualEndTime'] as Timestamp?)?.toDate(),
      screenedCount: data['screenedCount'] ?? 0,
    );
  }

  Map<String, dynamic> _mapDomainToFirestore(WellnessEvent event) {
    return {
      'title': event.title,
      'date': Timestamp.fromDate(event.date),
      'venue': event.venue,
      'address': event.address,
      'townCity': event.townCity,
      'province': event.province,
      'onsiteContactFirstName': event.onsiteContactFirstName,
      'onsiteContactLastName': event.onsiteContactLastName,
      'onsiteContactNumber': event.onsiteContactNumber,
      'onsiteContactEmail': event.onsiteContactEmail,
      'aeContactFirstName': event.aeContactFirstName,
      'aeContactLastName': event.aeContactLastName,
      'aeContactNumber': event.aeContactNumber,
      'aeContactEmail': event.aeContactEmail,
      'servicesRequested': event.servicesRequested,
      //  'additionalServicesRequested': event.additionalServicesRequested,
      'expectedParticipation': event.expectedParticipation,
      'nurses': event.nurses,
      //   'coordinators': event.coordinators,
      'setUpTime': event.setUpTime,
      'startTime': event.startTime,
      'endTime': event.endTime,
      'strikeDownTime': event.strikeDownTime,
      'mobileBooths': event.mobileBooths,
      'medicalAid': event.medicalAid,
      'description': event.description,
      'status': event.status,
      'actualStartTime': event.actualStartTime != null
          ? Timestamp.fromDate(event.actualStartTime!)
          : null,
      'actualEndTime': event.actualEndTime != null
          ? Timestamp.fromDate(event.actualEndTime!)
          : null,
      'screenedCount': event.screenedCount,
    };
  }

  /// Converts a [WellnessEvent] domain object to a Drift [EventsCompanion]
  /// so it can be stored in the local SQLite cache.
  EventsCompanion _mapDomainToEntity(WellnessEvent e) {
    return EventsCompanion(
      id: Value(e.id),
      title: Value(e.title),
      date: Value(e.date),
      venue: Value(e.venue),
      address: Value(e.address),
      townCity: Value(e.townCity),
      province: Value(e.province.isNotEmpty ? e.province : null),
      onsiteContactFirstName: Value(e.onsiteContactFirstName),
      onsiteContactLastName: Value(e.onsiteContactLastName),
      onsiteContactNumber: Value(e.onsiteContactNumber),
      onsiteContactEmail: Value(e.onsiteContactEmail),
      aeContactFirstName: Value(e.aeContactFirstName),
      aeContactLastName: Value(e.aeContactLastName),
      aeContactNumber: Value(e.aeContactNumber),
      aeContactEmail: Value(e.aeContactEmail),
      servicesRequested: Value(e.servicesRequested),
      expectedParticipation: Value(e.expectedParticipation),
      nurses: Value(e.nurses),
      setUpTime: Value(e.setUpTime),
      startTime: Value(e.startTime),
      endTime: Value(e.endTime),
      strikeDownTime: Value(e.strikeDownTime),
      mobileBooths: Value(e.mobileBooths),
      medicalAid: Value(e.medicalAid),
      description: Value(e.description),
      status: Value(e.status.isNotEmpty ? e.status : 'scheduled'),
      actualStartTime: Value(e.actualStartTime),
      actualEndTime: Value(e.actualEndTime),
      screenedCount: Value(e.screenedCount),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Converts a Drift [EventEntity] (local cache row) back to the domain
  /// [WellnessEvent] object.
  WellnessEvent _mapEntityToDomain(EventEntity e) {
    return WellnessEvent(
      id: e.id,
      title: e.title,
      date: e.date,
      venue: e.venue,
      address: e.address,
      townCity: e.townCity,
      province: e.province ?? '',
      onsiteContactFirstName: e.onsiteContactFirstName,
      onsiteContactLastName: e.onsiteContactLastName,
      onsiteContactNumber: e.onsiteContactNumber,
      onsiteContactEmail: e.onsiteContactEmail,
      aeContactFirstName: e.aeContactFirstName,
      aeContactLastName: e.aeContactLastName,
      aeContactNumber: e.aeContactNumber,
      aeContactEmail: e.aeContactEmail,
      servicesRequested: e.servicesRequested,
      expectedParticipation: e.expectedParticipation,
      nurses: e.nurses,
      setUpTime: e.setUpTime,
      startTime: e.startTime,
      endTime: e.endTime,
      strikeDownTime: e.strikeDownTime,
      mobileBooths: e.mobileBooths,
      medicalAid: e.medicalAid,
      description: e.description,
      status: e.status,
      actualStartTime: e.actualStartTime,
      actualEndTime: e.actualEndTime,
      screenedCount: e.screenedCount,
    );
  }
}
