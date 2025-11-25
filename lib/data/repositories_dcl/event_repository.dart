import 'dart:convert';

import 'package:drift/drift.dart';

import '../../local/app_database.dart';
import '../../../../domain/models/wellness_event.dart';

class EventRepository {
  EventRepository(this._database);

  final AppDatabase _database;

  Future<WellnessEvent?> fetchEventById(String id) async {
    final entry = await _database.getEventById(id);
    return entry == null ? null : _fromEntry(entry);
  }

  Stream<List<WellnessEvent>> watchEvents() {
    final query = (_database.select(_database.eventEntries)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.date)]));
    return query.watch().map(_mapEntries);
  }

  Future<List<WellnessEvent>> listEvents() async {
    final entries = await _database.listAllEvents();
    return _mapEntries(entries);
  }

  Future<List<EventEntry>> listPendingEntries() =>
      _database.listEventsBySyncStatus('pending');

  Future<void> deleteEvent(String id) => _database.deleteEventById(id);

  Future<void> updateEvent(WellnessEvent updatedEvent) =>
      _database.upsertEvent(_toCompanion(updatedEvent));

  Future<void> addEvent(WellnessEvent event) =>
      _database.upsertEvent(_toCompanion(event));

  Future<void> upsertRemoteEvent(
    WellnessEvent event,
    DateTime remoteUpdatedAt,
  ) =>
      _database.upsertEvent(
        _toCompanion(
          event,
          syncStatus: 'synced',
          remoteUpdatedAt: remoteUpdatedAt,
        ),
      );

  Future<void> markEventSynced(String id, DateTime remoteUpdatedAt) =>
      _database.markEventSynced(id, remoteUpdatedAt);

  Future<EventEntry?> getEventEntry(String id) =>
      _database.getEventEntry(id);

  Future<void> updateSyncStatus(String id, String status) =>
      _database.updateEventSyncStatus(id, status);

  List<WellnessEvent> _mapEntries(List<EventEntry> entries) {
    return entries.map(_fromEntry).toList();
  }

  EventEntriesCompanion _toCompanion(
    WellnessEvent event, {
    String syncStatus = 'pending',
    DateTime? remoteUpdatedAt,
  }) {
    return EventEntriesCompanion(
      id: Value(event.id),
      title: Value(event.title),
      date: Value(event.date),
      payload: Value(jsonEncode(event.toJson())),
      syncStatus: Value(syncStatus),
      updatedAt: Value(DateTime.now()),
      remoteUpdatedAt: remoteUpdatedAt == null
          ? const Value.absent()
          : Value(remoteUpdatedAt),
    );
  }

  WellnessEvent _fromEntry(EventEntry entry) {
    final decoded = jsonDecode(entry.payload) as Map<String, dynamic>;
    return WellnessEvent.fromJson(decoded);
  }
}
