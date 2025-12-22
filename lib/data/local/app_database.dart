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
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MemberEntity')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();
  TextColumn get idNumber => text().nullable()();
  TextColumn get passportNumber => text().nullable()();
  TextColumn get idDocumentType => text()(); // 'ID' or 'Passport'
  TextColumn get dateOfBirth => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get maritalStatus => text().nullable()();
  TextColumn get nationality => text().nullable()();
  TextColumn get citizenshipStatus => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get cellNumber => text().nullable()();
  TextColumn get medicalAidStatus => text().nullable()();
  TextColumn get medicalAidName => text().nullable()();
  TextColumn get medicalAidNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EventEntity')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  TextColumn get venue => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get townCity => text().withDefault(const Constant(''))();
  TextColumn get province => text().nullable()();
  TextColumn get onsiteContactFirstName =>
      text().withDefault(const Constant(''))();
  TextColumn get onsiteContactLastName =>
      text().withDefault(const Constant(''))();
  TextColumn get onsiteContactNumber =>
      text().withDefault(const Constant(''))();
  TextColumn get onsiteContactEmail => text().withDefault(const Constant(''))();
  TextColumn get aeContactFirstName => text().withDefault(const Constant(''))();
  TextColumn get aeContactLastName => text().withDefault(const Constant(''))();
  TextColumn get aeContactNumber => text().withDefault(const Constant(''))();
  TextColumn get aeContactEmail => text().withDefault(const Constant(''))();
  TextColumn get servicesRequested => text().withDefault(const Constant(''))();
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

@DriftDatabase(tables: [Users, Events, Members])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 13;

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
              await migrator.addColumn(
                  events, events.additionalServicesRequested);
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
              // If TableMigration fails, the table likely already matches current schema
              // Safe to continue - app will function with existing table structure
            }
          }

          if (from < 12) {
            // Add default values to Events table text columns to handle NULL values
            // This fixes "Null check operator used on a null value" errors
            // Custom migration to handle NULL values during data copy
            try {
              await customStatement('''
                CREATE TABLE IF NOT EXISTS new_events (
                  id TEXT NOT NULL PRIMARY KEY,
                  title TEXT NOT NULL DEFAULT '',
                  date INTEGER NOT NULL,
                  venue TEXT NOT NULL DEFAULT '',
                  address TEXT NOT NULL DEFAULT '',
                  town_city TEXT NOT NULL DEFAULT '',
                  province TEXT,
                  onsite_contact_first_name TEXT NOT NULL DEFAULT '',
                  onsite_contact_last_name TEXT NOT NULL DEFAULT '',
                  onsite_contact_number TEXT NOT NULL DEFAULT '',
                  onsite_contact_email TEXT NOT NULL DEFAULT '',
                  ae_contact_first_name TEXT NOT NULL DEFAULT '',
                  ae_contact_last_name TEXT NOT NULL DEFAULT '',
                  ae_contact_number TEXT NOT NULL DEFAULT '',
                  ae_contact_email TEXT NOT NULL DEFAULT '',
                  services_requested TEXT NOT NULL DEFAULT '',
                  additional_services_requested TEXT NOT NULL DEFAULT '',
                  expected_participation INTEGER NOT NULL DEFAULT 0,
                  nurses INTEGER NOT NULL DEFAULT 0,
                  coordinators INTEGER NOT NULL DEFAULT 0,
                  set_up_time TEXT NOT NULL DEFAULT '',
                  start_time TEXT NOT NULL DEFAULT '',
                  end_time TEXT NOT NULL DEFAULT '',
                  strike_down_time TEXT NOT NULL DEFAULT '',
                  mobile_booths TEXT NOT NULL DEFAULT '',
                  medical_aid TEXT NOT NULL DEFAULT '',
                  description TEXT,
                  status TEXT NOT NULL DEFAULT 'scheduled',
                  actual_start_time INTEGER,
                  actual_end_time INTEGER,
                  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
                  updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
                );
              ''');

              // Copy data with COALESCE to provide defaults for NULL values
              await customStatement('''
                INSERT INTO new_events (
                  id, title, date, venue, address, town_city, province,
                  onsite_contact_first_name, onsite_contact_last_name,
                  onsite_contact_number, onsite_contact_email,
                  ae_contact_first_name, ae_contact_last_name,
                  ae_contact_number, ae_contact_email,
                  services_requested, additional_services_requested,
                  expected_participation, nurses, coordinators,
                  set_up_time, start_time, end_time, strike_down_time,
                  mobile_booths, medical_aid, description, status,
                  actual_start_time, actual_end_time, created_at, updated_at
                )
                SELECT 
                  id,
                  COALESCE(title, ''),
                  date,
                  COALESCE(venue, ''),
                  COALESCE(address, ''),
                  COALESCE(town_city, ''),
                  province,
                  COALESCE(onsite_contact_first_name, ''),
                  COALESCE(onsite_contact_last_name, ''),
                  COALESCE(onsite_contact_number, ''),
                  COALESCE(onsite_contact_email, ''),
                  COALESCE(ae_contact_first_name, ''),
                  COALESCE(ae_contact_last_name, ''),
                  COALESCE(ae_contact_number, ''),
                  COALESCE(ae_contact_email, ''),
                  COALESCE(services_requested, ''),
                  COALESCE(additional_services_requested, ''),
                  COALESCE(expected_participation, 0),
                  COALESCE(nurses, 0),
                  COALESCE(coordinators, 0),
                  COALESCE(set_up_time, ''),
                  COALESCE(start_time, ''),
                  COALESCE(end_time, ''),
                  COALESCE(strike_down_time, ''),
                  COALESCE(mobile_booths, ''),
                  COALESCE(medical_aid, ''),
                  description,
                  COALESCE(status, 'scheduled'),
                  actual_start_time,
                  actual_end_time,
                  created_at,
                  updated_at
                FROM events;
              ''');

              // Drop old table and rename new one
              await customStatement('DROP TABLE events;');
              await customStatement('ALTER TABLE new_events RENAME TO events;');
            } on SqliteException catch (e) {
              // Log error but don't crash - app can still function
              print('Migration v11->v12 error: $e');
            }
          }

          if (from < 13) {
            // Add Members table
            try {
              await migrator.createTable(members);
              debugPrint('Successfully created Members table');
            } on SqliteException catch (e) {
              // Table already exists - this is expected and can be safely ignored
              debugPrint('Members table migration: ${e.message} (likely already exists)');
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
    )..where((tbl) => tbl.email.equals(email)))
        .getSingleOrNull();
  }

  Future<UserEntity?> getUserByCredentials(String email, String password) {
    return (select(users)
          ..where(
            (tbl) => tbl.email.equals(email) & tbl.password.equals(password),
          ))
        .getSingleOrNull();
  }

  Future<UserEntity?> getUserById(String id) {
    return (select(users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<UserEntity>> getAllUsers() => select(users).get();

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
    )..where((tbl) => tbl.id.equals(id)))
        .write(updates);

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
    )..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertEvent(EventsCompanion entry) async {
    await into(events).insertOnConflictUpdate(entry);
  }

  Future<int> deleteEventById(String id) {
    return (delete(events)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ----------------- MEMBERS CRUD -----------------

  Future<MemberEntity> createMember({
    required String id,
    required String name,
    required String surname,
    String? idNumber,
    String? passportNumber,
    required String idDocumentType,
    String? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? nationality,
    String? citizenshipStatus,
    String? email,
    String? cellNumber,
    String? medicalAidStatus,
    String? medicalAidName,
    String? medicalAidNumber,
  }) {
    final member = MembersCompanion(
      id: Value(id),
      name: Value(name),
      surname: Value(surname),
      idNumber: Value(idNumber),
      passportNumber: Value(passportNumber),
      idDocumentType: Value(idDocumentType),
      dateOfBirth: Value(dateOfBirth),
      gender: Value(gender),
      maritalStatus: Value(maritalStatus),
      nationality: Value(nationality),
      citizenshipStatus: Value(citizenshipStatus),
      email: Value(email),
      cellNumber: Value(cellNumber),
      medicalAidStatus: Value(medicalAidStatus),
      medicalAidName: Value(medicalAidName),
      medicalAidNumber: Value(medicalAidNumber),
    );

    return into(members).insertReturning(member);
  }

  Future<MemberEntity?> getMemberById(String id) {
    return (select(members)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<MemberEntity?> getMemberByIdNumber(String idNumber) {
    return (select(members)..where((tbl) => tbl.idNumber.equals(idNumber)))
        .getSingleOrNull();
  }

  Future<MemberEntity?> getMemberByPassportNumber(String passportNumber) {
    return (select(members)
          ..where((tbl) => tbl.passportNumber.equals(passportNumber)))
        .getSingleOrNull();
  }

  Future<List<MemberEntity>> searchMembers(String query) {
    return (select(members)
          ..where((tbl) =>
              tbl.name.contains(query) |
              tbl.surname.contains(query) |
              (tbl.idNumber.isNotNull() & tbl.idNumber.contains(query)) |
              (tbl.passportNumber.isNotNull() & tbl.passportNumber.contains(query))))
        .get();
  }

  Future<List<MemberEntity>> getAllMembers() => select(members).get();

  Future<void> upsertMember(MembersCompanion entry) async {
    await into(members).insertOnConflictUpdate(entry);
  }

  Future<int> deleteMemberById(String id) {
    return (delete(members)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'kenwell.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}
