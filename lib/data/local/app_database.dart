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

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 1;

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
