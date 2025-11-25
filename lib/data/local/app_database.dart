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
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime())();
  DateTimeColumn get remoteUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserEntries extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get password => text()();
  TextColumn get role => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get username => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  BoolColumn get isCurrent =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [EventEntries, UserEntries])
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

  Future<List<EventEntry>> listEventsBySyncStatus(String status) =>
      (select(eventEntries)..where((tbl) => tbl.syncStatus.equals(status)))
          .get();

  Future<void> markEventSynced(String id, DateTime remoteUpdatedAt) =>
      (update(eventEntries)..where((tbl) => tbl.id.equals(id))).write(
        EventEntriesCompanion(
          syncStatus: const Value('synced'),
          remoteUpdatedAt: Value(remoteUpdatedAt),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<EventEntry?> getEventEntry(String id) =>
      (select(eventEntries)..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

  Future<void> updateEventSyncStatus(String id, String status) =>
      (update(eventEntries)..where((tbl) => tbl.id.equals(id))).write(
        EventEntriesCompanion(
          syncStatus: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<List<UserEntry>> listUsers() => select(userEntries).get();

  Future<UserEntry?> getUserByEmail(String email) =>
      (select(userEntries)..where((tbl) => tbl.email.equals(email))).getSingleOrNull();

  Future<UserEntry?> getCurrentUserEntry() =>
      (select(userEntries)..where((tbl) => tbl.isCurrent.equals(true))).getSingleOrNull();

  Future<void> upsertUser(UserEntriesCompanion entry) =>
      into(userEntries).insertOnConflictUpdate(entry);

  Future<void> setCurrentUser(String userId) => transaction(() async {
        await (update(userEntries)..where((tbl) => tbl.isCurrent.equals(true)))
            .write(const UserEntriesCompanion(isCurrent: Value(false)));
        await (update(userEntries)..where((tbl) => tbl.id.equals(userId)))
            .write(const UserEntriesCompanion(isCurrent: Value(true)));
      });

  Future<void> clearCurrentUser() async {
    await (update(userEntries)..where((tbl) => tbl.isCurrent.equals(true)))
        .write(const UserEntriesCompanion(isCurrent: Value(false)));
  }

  Future<int> deleteUserById(String id) =>
      (delete(userEntries)..where((tbl) => tbl.id.equals(id))).go();
}
