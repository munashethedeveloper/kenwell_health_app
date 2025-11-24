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

  Future<void> deleteEvent(String id) => _database.deleteEventById(id);

  Future<void> updateEvent(WellnessEvent updatedEvent) =>
      _database.upsertEvent(_toCompanion(updatedEvent));

  Future<void> addEvent(WellnessEvent event) =>
      _database.upsertEvent(_toCompanion(event));

  List<WellnessEvent> _mapEntries(List<EventEntry> entries) {
    return entries.map(_fromEntry).toList();
  }

  EventEntriesCompanion _toCompanion(WellnessEvent event) {
    return EventEntriesCompanion(
      id: Value(event.id),
      title: Value(event.title),
      date: Value(event.date),
      payload: Value(jsonEncode(event.toJson())),
      updatedAt: Value(DateTime.now()),
    );
  }

  WellnessEvent _fromEntry(EventEntry entry) {
    final decoded = jsonDecode(entry.payload) as Map<String, dynamic>;
    return WellnessEvent.fromJson(decoded);
  }
}
