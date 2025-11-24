// GENERATED CODE - HANDWRITTEN DUE TO TOOLING LIMITATIONS.

part of 'app_database.dart';

class $EventEntriesTable extends EventEntries
    with TableInfo<$EventEntriesTable, EventEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventEntriesTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _titleMeta = VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _dateMeta = VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date =
      GeneratedColumn<DateTime>('date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);

  static const VerificationMeta _payloadMeta = VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _updatedAtMeta =
      VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt =
      GeneratedColumn<DateTime>('updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);

  @override
  List<GeneratedColumn> get $columns => [id, title, date, payload, updatedAt];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => 'event_entries';

  @override
  VerificationContext validateIntegrity(Insertable<EventEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
          _updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(
              data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  EventEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EventEntriesTable createAlias(String alias) =>
      $EventEntriesTable(attachedDatabase, alias);
}

class EventEntry extends DataClass implements Insertable<EventEntry> {
  final String id;
  final String title;
  final DateTime date;
  final String payload;
  final DateTime updatedAt;

  const EventEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.payload,
    required this.updatedAt,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return {
      'id': Variable<String>(id),
      'title': Variable<String>(title),
      'date': Variable<DateTime>(date),
      'payload': Variable<String>(payload),
      'updated_at': Variable<DateTime>(updatedAt),
    };
  }

  EventEntriesCompanion toCompanion(bool nullToAbsent) {
    return EventEntriesCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory EventEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EventEntry copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? payload,
    DateTime? updatedAt,
  }) =>
      EventEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() {
    return (StringBuffer('EventEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, date, payload, updatedAt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventEntry &&
          other.id == id &&
          other.title == title &&
          other.date == date &&
          other.payload == payload &&
          other.updatedAt == updatedAt);
}

class EventEntriesCompanion extends UpdateCompanion<EventEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String> payload;
  final Value<DateTime> updatedAt;

  const EventEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });

  EventEntriesCompanion.insert({
    required String id,
    required String title,
    required DateTime date,
    required String payload,
    this.updatedAt = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        date = Value(date),
        payload = Value(payload);

  static Insertable<EventEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EventEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? date,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
  }) {
    return EventEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserEntriesTable extends UserEntries
    with TableInfo<$UserEntriesTable, UserEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserEntriesTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _emailMeta = VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _passwordMeta = VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _roleMeta = VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _phoneNumberMeta =
      VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _usernameMeta = VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _firstNameMeta = VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _lastNameMeta = VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _isCurrentMeta = VerificationMeta('isCurrent');
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultValue: const Constant(false),
  );

  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        password,
        role,
        phoneNumber,
        username,
        firstName,
        lastName,
        isCurrent,
      ];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => 'user_entries';

  @override
  VerificationContext validateIntegrity(Insertable<UserEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(_emailMeta,
          email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
          _firstNameMeta,
          firstName.isAcceptableOrUnknown(
              data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
          _lastNameMeta,
          lastName.isAcceptableOrUnknown(
              data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
          _isCurrentMeta,
          isCurrent.isAcceptableOrUnknown(
              data['is_current']!, _isCurrentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  UserEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      phoneNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      firstName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      isCurrent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_current'])!,
    );
  }

  @override
  $UserEntriesTable createAlias(String alias) =>
      $UserEntriesTable(attachedDatabase, alias);
}

class UserEntry extends DataClass implements Insertable<UserEntry> {
  final String id;
  final String email;
  final String password;
  final String role;
  final String phoneNumber;
  final String username;
  final String firstName;
  final String lastName;
  final bool isCurrent;

  const UserEntry({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.phoneNumber,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.isCurrent,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return {
      'id': Variable<String>(id),
      'email': Variable<String>(email),
      'password': Variable<String>(password),
      'role': Variable<String>(role),
      'phone_number': Variable<String>(phoneNumber),
      'username': Variable<String>(username),
      'first_name': Variable<String>(firstName),
      'last_name': Variable<String>(lastName),
      'is_current': Variable<bool>(isCurrent),
    };
  }

  UserEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserEntriesCompanion(
      id: Value(id),
      email: Value(email),
      password: Value(password),
      role: Value(role),
      phoneNumber: Value(phoneNumber),
      username: Value(username),
      firstName: Value(firstName),
      lastName: Value(lastName),
      isCurrent: Value(isCurrent),
    );
  }

  factory UserEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntry(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      role: serializer.fromJson<String>(json['role']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      username: serializer.fromJson<String>(json['username']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
    );
  }

  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'role': serializer.toJson<String>(role),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'username': serializer.toJson<String>(username),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'isCurrent': serializer.toJson<bool>(isCurrent),
    };
  }

  UserEntry copyWith({
    String? id,
    String? email,
    String? password,
    String? role,
    String? phoneNumber,
    String? username,
    String? firstName,
    String? lastName,
    bool? isCurrent,
  }) =>
      UserEntry(
        id: id ?? this.id,
        email: email ?? this.email,
        password: password ?? this.password,
        role: role ?? this.role,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        username: username ?? this.username,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isCurrent: isCurrent ?? this.isCurrent,
      );

  @override
  String toString() {
    return (StringBuffer('UserEntry(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, email, password, role, phoneNumber, username, firstName, lastName, isCurrent);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntry &&
          other.id == id &&
          other.email == email &&
          other.password == password &&
          other.role == role &&
          other.phoneNumber == phoneNumber &&
          other.username == username &&
          other.firstName == firstName &&
          other.lastName == lastName &&
          other.isCurrent == isCurrent);
}

class UserEntriesCompanion extends UpdateCompanion<UserEntry> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> password;
  final Value<String> role;
  final Value<String> phoneNumber;
  final Value<String> username;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<bool> isCurrent;

  const UserEntriesCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.username = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.isCurrent = const Value.absent(),
  });

  UserEntriesCompanion.insert({
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String username,
    required String firstName,
    required String lastName,
    this.isCurrent = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        password = Value(password),
        role = Value(role),
        phoneNumber = Value(phoneNumber),
        username = Value(username),
        firstName = Value(firstName),
        lastName = Value(lastName);

  static Insertable<UserEntry> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? role,
    Expression<String>? phoneNumber,
    Expression<String>? username,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<bool>? isCurrent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (username != null) 'username': username,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (isCurrent != null) 'is_current': isCurrent,
    });
  }

  UserEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? password,
    Value<String>? role,
    Value<String>? phoneNumber,
    Value<String>? username,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<bool>? isCurrent,
  }) {
    return UserEntriesCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserEntriesCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $EventEntriesTable eventEntries =
      $EventEntriesTable(this);
  late final $UserEntriesTable userEntries = $UserEntriesTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [eventEntries, userEntries];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [eventEntries, userEntries];
}
