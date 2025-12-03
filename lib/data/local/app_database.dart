import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('UserEntity')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get role => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get username => text()();
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
  TextColumn get onsiteContactFirstName => text()();
  TextColumn get onsiteContactLastName => text()();
  TextColumn get onsiteContactNumber => text()();
  TextColumn get onsiteContactEmail => text()();
  TextColumn get aeContactFirstName => text()();
  TextColumn get aeContactLastName => text()();
  TextColumn get aeContactNumber => text()();
  TextColumn get aeContactEmail => text()();
  TextColumn get servicesRequested => text()();
  IntColumn get expectedParticipation =>
      integer().withDefault(const Constant(0))();
  IntColumn get nonMembers => integer().withDefault(const Constant(0))();
  IntColumn get passports => integer().withDefault(const Constant(0))();
  IntColumn get nurses => integer().withDefault(const Constant(0))();
  IntColumn get coordinators => integer().withDefault(const Constant(0))();
  IntColumn get multiplyPromoters => integer().withDefault(const Constant(0))();
  IntColumn get screenedCount => integer().withDefault(const Constant(0))();
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAllTables(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(events);
          }
          if (from < 3) {
            await migrator.addColumn(events, events.screenedCount);
          }
        },
      );

  Future<UserEntity> createUser({
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
  }) {
    final user = UsersCompanion(
      id: Value(id),
      email: Value(email),
      password: Value(password),
      role: Value(role),
      phoneNumber: Value(phoneNumber),
      username: Value(username),
      firstName: Value(firstName),
      lastName: Value(lastName),
    );

    return into(users).insertReturning(user);
  }

  Future<UserEntity?> getUserByEmail(String email) {
    return (select(users)..where((tbl) => tbl.email.equals(email)))
        .getSingleOrNull();
  }

  Future<UserEntity?> getUserByCredentials(
    String email,
    String password,
  ) {
    return (select(users)
          ..where(
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
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final updates = UsersCompanion(
      email: Value(email),
      password: Value(password),
      role: Value(role),
      phoneNumber: Value(phoneNumber),
      username: Value(username),
      firstName: Value(firstName),
      lastName: Value(lastName),
      updatedAt: Value(DateTime.now()),
    );

    final rowsUpdated =
        await (update(users)..where((tbl) => tbl.id.equals(id))).write(updates);

    if (rowsUpdated == 0) {
      return null;
    }

    return getUserById(id);
  }

  Future<List<EventEntity>> getAllEvents() => select(events).get();

  Stream<List<EventEntity>> watchAllEvents() => select(events).watch();

  Future<EventEntity?> getEventById(String id) {
    return (select(events)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
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
    return NativeDatabase.createInBackground(
      file,
      logStatements: false,
    );
  });
}
