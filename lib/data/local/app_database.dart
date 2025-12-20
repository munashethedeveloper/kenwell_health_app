import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

@DataClassName('UserEntity')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get role => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EventEntity')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get venue => text()();
  TextColumn get address => text()();
  TextColumn get townCity => text()();
  TextColumn get province => text().nullable()();
  TextColumn get onsiteContactFirstName => text()();
  TextColumn get onsiteContactLastName => text()();
  TextColumn get onsiteContactNumber => text()();
  TextColumn get onsiteContactEmail => text()();
  TextColumn get aeContactFirstName => text()();
  TextColumn get aeContactLastName => text()();
  TextColumn get aeContactNumber => text()();
  TextColumn get aeContactEmail => text()();
  TextColumn get servicesRequested => text()();
  TextColumn get additionalServicesRequested =>
      text().withDefault(const Constant(''))();
  IntColumn get expectedParticipation =>
      integer().withDefault(const Constant(0))();
  IntColumn get nurses => integer().withDefault(const Constant(0))();
  IntColumn get coordinators => integer().withDefault(const Constant(0))();
  TextColumn get setUpTime => text().withDefault(const Constant(''))();
  TextColumn get startTime => text().withDefault(const Constant(''))();
  TextColumn get endTime => text().withDefault(const Constant(''))();
  TextColumn get strikeDownTime => text().withDefault(const Constant(''))();
  TextColumn get mobileBooths => text().withDefault(const Constant(''))();
  TextColumn get medicalAid => text().withDefault(const Constant(''))();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  DateTimeColumn get actualStartTime => dateTime().nullable()();
  DateTimeColumn get actualEndTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, Events])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),

    // Migration to handle schema changes
    onUpgrade: (migrator, from, to) async {
      if (from < 10) {
        // Add the additional_services_requested column if upgrading from v7, v8, or v9
        // Note: Column was added to schema in v8 but schema version wasn't incremented
        // So databases upgraded from v7 to v8/v9 don't have this column
        // Databases created fresh at v8/v9 will have it via onCreate
        try {
          await migrator.addColumn(events, events.additionalServicesRequested);
        } on SqliteException catch (_) {
          // Column already exists (database was created fresh at v8 or v9)
          // This is expected and can be safely ignored
        }
      }
      
      if (from < 11) {
        // Remove username column from Users table
        // Note: Old databases (pre-v11) had a NOT NULL username column that was later removed
        // This migration recreates the Users table with only the current schema columns
        // TableMigration preserves existing data while updating the table structure
        try {
          await migrator.alterTable(TableMigration(users));
        } on SqliteException catch (_) {
          // If migration fails, it might already be in correct state
          // Silently continue - table recreation is handled by Drift
        }
      }
    },
  );

  // ----------------- USER CRUD -----------------

  Future<UserEntity> createUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) {
    final user = UsersCompanion(
      id: Value(id),
      email: Value(email),
      password: Value(password),
      role: Value(role),
      phoneNumber: Value(phoneNumber),
      firstName: Value(firstName),
      lastName: Value(lastName),
    );

    return into(users).insertReturning(user);
  }

  Future<UserEntity?> getUserByEmail(String email) {
    return (select(
      users,
    )..where((tbl) => tbl.email.equals(email))).getSingleOrNull();
  }

  Future<UserEntity?> getUserByCredentials(String email, String password) {
    return (select(users)..where(
          (tbl) => tbl.email.equals(email) & tbl.password.equals(password),
        ))
        .getSingleOrNull();
  }

  Future<UserEntity?> getUserById(String id) {
    return (select(users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<UserEntity?> updateUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    final updates = UsersCompanion(
      email: Value(email),
      password: Value(password),
      role: Value(role),
      phoneNumber: Value(phoneNumber),
      firstName: Value(firstName),
      lastName: Value(lastName),
      updatedAt: Value(DateTime.now()),
    );

    final rowsUpdated = await (update(
      users,
    )..where((tbl) => tbl.id.equals(id))).write(updates);

    if (rowsUpdated == 0) {
      return null;
    }

    return getUserById(id);
  }

  // ----------------- EVENTS CRUD -----------------

  Future<List<EventEntity>> getAllEvents() => select(events).get();

  Stream<List<EventEntity>> watchAllEvents() => select(events).watch();

  Future<EventEntity?> getEventById(String id) {
    return (select(
      events,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertEvent(EventsCompanion entry) async {
    await into(events).insertOnConflictUpdate(entry);
  }

  Future<int> deleteEventById(String id) {
    return (delete(events)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'kenwell.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}
