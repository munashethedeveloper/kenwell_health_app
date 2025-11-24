import 'dart:async';

import 'package:drift/drift.dart';

import 'connection_factory_stub.dart'
    if (dart.library.io) 'connection_factory_io.dart'
    if (dart.library.html) 'connection_factory_web.dart' as connection_factory;

part 'app_database.g.dart';

class EventEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime())();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [EventEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
      : super(executor ?? connection_factory.createExecutor());

  @override
  int get schemaVersion => 1;

  Future<List<EventEntry>> listAllEvents() => select(eventEntries).get();

  Stream<List<EventEntry>> watchEvents() => select(eventEntries).watch();

  Future<EventEntry?> getEventById(String id) =>
      (select(eventEntries)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<void> upsertEvent(EventEntriesCompanion entry) =>
      into(eventEntries).insertOnConflictUpdate(entry);

  Future<int> deleteEventById(String id) =>
      (delete(eventEntries)..where((tbl) => tbl.id.equals(id))).go();
}
