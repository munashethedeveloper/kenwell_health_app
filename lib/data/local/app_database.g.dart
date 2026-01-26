// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        password,
        role,
        phoneNumber,
        firstName,
        lastName,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
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
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserEntity extends DataClass implements Insertable<UserEntity> {
  final String id;
  final String email;
  final String password;
  final String role;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserEntity(
      {required this.id,
      required this.email,
      required this.password,
      required this.role,
      required this.phoneNumber,
      required this.firstName,
      required this.lastName,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    map['role'] = Variable<String>(role);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      password: Value(password),
      role: Value(role),
      phoneNumber: Value(phoneNumber),
      firstName: Value(firstName),
      lastName: Value(lastName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntity(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      role: serializer.fromJson<String>(json['role']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'role': serializer.toJson<String>(role),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserEntity copyWith(
          {String? id,
          String? email,
          String? password,
          String? role,
          String? phoneNumber,
          String? firstName,
          String? lastName,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserEntity(
        id: id ?? this.id,
        email: email ?? this.email,
        password: password ?? this.password,
        role: role ?? this.role,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserEntity copyWithCompanion(UsersCompanion data) {
    return UserEntity(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      role: data.role.present ? data.role.value : this.role,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntity(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, password, role, phoneNumber,
      firstName, lastName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == this.id &&
          other.email == this.email &&
          other.password == this.password &&
          other.role == this.role &&
          other.phoneNumber == this.phoneNumber &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<UserEntity> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> password;
  final Value<String> role;
  final Value<String> phoneNumber;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        password = Value(password),
        role = Value(role),
        phoneNumber = Value(phoneNumber),
        firstName = Value(firstName),
        lastName = Value(lastName);
  static Insertable<UserEntity> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? role,
    Expression<String>? phoneNumber,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? password,
      Value<String>? role,
      Value<String>? phoneNumber,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
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
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
      'venue', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _townCityMeta =
      const VerificationMeta('townCity');
  @override
  late final GeneratedColumn<String> townCity = GeneratedColumn<String>(
      'town_city', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _provinceMeta =
      const VerificationMeta('province');
  @override
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
      'province', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onsiteContactFirstNameMeta =
      const VerificationMeta('onsiteContactFirstName');
  @override
  late final GeneratedColumn<String> onsiteContactFirstName =
      GeneratedColumn<String>('onsite_contact_first_name', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _onsiteContactLastNameMeta =
      const VerificationMeta('onsiteContactLastName');
  @override
  late final GeneratedColumn<String> onsiteContactLastName =
      GeneratedColumn<String>('onsite_contact_last_name', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _onsiteContactNumberMeta =
      const VerificationMeta('onsiteContactNumber');
  @override
  late final GeneratedColumn<String> onsiteContactNumber =
      GeneratedColumn<String>('onsite_contact_number', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _onsiteContactEmailMeta =
      const VerificationMeta('onsiteContactEmail');
  @override
  late final GeneratedColumn<String> onsiteContactEmail =
      GeneratedColumn<String>('onsite_contact_email', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _aeContactFirstNameMeta =
      const VerificationMeta('aeContactFirstName');
  @override
  late final GeneratedColumn<String> aeContactFirstName =
      GeneratedColumn<String>('ae_contact_first_name', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _aeContactLastNameMeta =
      const VerificationMeta('aeContactLastName');
  @override
  late final GeneratedColumn<String> aeContactLastName =
      GeneratedColumn<String>('ae_contact_last_name', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _aeContactNumberMeta =
      const VerificationMeta('aeContactNumber');
  @override
  late final GeneratedColumn<String> aeContactNumber = GeneratedColumn<String>(
      'ae_contact_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _aeContactEmailMeta =
      const VerificationMeta('aeContactEmail');
  @override
  late final GeneratedColumn<String> aeContactEmail = GeneratedColumn<String>(
      'ae_contact_email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _servicesRequestedMeta =
      const VerificationMeta('servicesRequested');
  @override
  late final GeneratedColumn<String> servicesRequested =
      GeneratedColumn<String>('services_requested', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _additionalServicesRequestedMeta =
      const VerificationMeta('additionalServicesRequested');
  @override
  late final GeneratedColumn<String> additionalServicesRequested =
      GeneratedColumn<String>(
          'additional_services_requested', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _expectedParticipationMeta =
      const VerificationMeta('expectedParticipation');
  @override
  late final GeneratedColumn<int> expectedParticipation = GeneratedColumn<int>(
      'expected_participation', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nursesMeta = const VerificationMeta('nurses');
  @override
  late final GeneratedColumn<int> nurses = GeneratedColumn<int>(
      'nurses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _coordinatorsMeta =
      const VerificationMeta('coordinators');
  @override
  late final GeneratedColumn<int> coordinators = GeneratedColumn<int>(
      'coordinators', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _setUpTimeMeta =
      const VerificationMeta('setUpTime');
  @override
  late final GeneratedColumn<String> setUpTime = GeneratedColumn<String>(
      'set_up_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _strikeDownTimeMeta =
      const VerificationMeta('strikeDownTime');
  @override
  late final GeneratedColumn<String> strikeDownTime = GeneratedColumn<String>(
      'strike_down_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _mobileBoothsMeta =
      const VerificationMeta('mobileBooths');
  @override
  late final GeneratedColumn<String> mobileBooths = GeneratedColumn<String>(
      'mobile_booths', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _medicalAidMeta =
      const VerificationMeta('medicalAid');
  @override
  late final GeneratedColumn<String> medicalAid = GeneratedColumn<String>(
      'medical_aid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('scheduled'));
  static const VerificationMeta _actualStartTimeMeta =
      const VerificationMeta('actualStartTime');
  @override
  late final GeneratedColumn<DateTime> actualStartTime =
      GeneratedColumn<DateTime>('actual_start_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _actualEndTimeMeta =
      const VerificationMeta('actualEndTime');
  @override
  late final GeneratedColumn<DateTime> actualEndTime =
      GeneratedColumn<DateTime>('actual_end_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _screenedCountMeta =
      const VerificationMeta('screenedCount');
  @override
  late final GeneratedColumn<int> screenedCount = GeneratedColumn<int>(
      'screened_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        date,
        venue,
        address,
        townCity,
        province,
        onsiteContactFirstName,
        onsiteContactLastName,
        onsiteContactNumber,
        onsiteContactEmail,
        aeContactFirstName,
        aeContactLastName,
        aeContactNumber,
        aeContactEmail,
        servicesRequested,
        additionalServicesRequested,
        expectedParticipation,
        nurses,
        coordinators,
        setUpTime,
        startTime,
        endTime,
        strikeDownTime,
        mobileBooths,
        medicalAid,
        description,
        status,
        actualStartTime,
        actualEndTime,
        screenedCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<EventEntity> instance,
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
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('venue')) {
      context.handle(
          _venueMeta, venue.isAcceptableOrUnknown(data['venue']!, _venueMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('town_city')) {
      context.handle(_townCityMeta,
          townCity.isAcceptableOrUnknown(data['town_city']!, _townCityMeta));
    }
    if (data.containsKey('province')) {
      context.handle(_provinceMeta,
          province.isAcceptableOrUnknown(data['province']!, _provinceMeta));
    }
    if (data.containsKey('onsite_contact_first_name')) {
      context.handle(
          _onsiteContactFirstNameMeta,
          onsiteContactFirstName.isAcceptableOrUnknown(
              data['onsite_contact_first_name']!, _onsiteContactFirstNameMeta));
    }
    if (data.containsKey('onsite_contact_last_name')) {
      context.handle(
          _onsiteContactLastNameMeta,
          onsiteContactLastName.isAcceptableOrUnknown(
              data['onsite_contact_last_name']!, _onsiteContactLastNameMeta));
    }
    if (data.containsKey('onsite_contact_number')) {
      context.handle(
          _onsiteContactNumberMeta,
          onsiteContactNumber.isAcceptableOrUnknown(
              data['onsite_contact_number']!, _onsiteContactNumberMeta));
    }
    if (data.containsKey('onsite_contact_email')) {
      context.handle(
          _onsiteContactEmailMeta,
          onsiteContactEmail.isAcceptableOrUnknown(
              data['onsite_contact_email']!, _onsiteContactEmailMeta));
    }
    if (data.containsKey('ae_contact_first_name')) {
      context.handle(
          _aeContactFirstNameMeta,
          aeContactFirstName.isAcceptableOrUnknown(
              data['ae_contact_first_name']!, _aeContactFirstNameMeta));
    }
    if (data.containsKey('ae_contact_last_name')) {
      context.handle(
          _aeContactLastNameMeta,
          aeContactLastName.isAcceptableOrUnknown(
              data['ae_contact_last_name']!, _aeContactLastNameMeta));
    }
    if (data.containsKey('ae_contact_number')) {
      context.handle(
          _aeContactNumberMeta,
          aeContactNumber.isAcceptableOrUnknown(
              data['ae_contact_number']!, _aeContactNumberMeta));
    }
    if (data.containsKey('ae_contact_email')) {
      context.handle(
          _aeContactEmailMeta,
          aeContactEmail.isAcceptableOrUnknown(
              data['ae_contact_email']!, _aeContactEmailMeta));
    }
    if (data.containsKey('services_requested')) {
      context.handle(
          _servicesRequestedMeta,
          servicesRequested.isAcceptableOrUnknown(
              data['services_requested']!, _servicesRequestedMeta));
    }
    if (data.containsKey('additional_services_requested')) {
      context.handle(
          _additionalServicesRequestedMeta,
          additionalServicesRequested.isAcceptableOrUnknown(
              data['additional_services_requested']!,
              _additionalServicesRequestedMeta));
    }
    if (data.containsKey('expected_participation')) {
      context.handle(
          _expectedParticipationMeta,
          expectedParticipation.isAcceptableOrUnknown(
              data['expected_participation']!, _expectedParticipationMeta));
    }
    if (data.containsKey('nurses')) {
      context.handle(_nursesMeta,
          nurses.isAcceptableOrUnknown(data['nurses']!, _nursesMeta));
    }
    if (data.containsKey('coordinators')) {
      context.handle(
          _coordinatorsMeta,
          coordinators.isAcceptableOrUnknown(
              data['coordinators']!, _coordinatorsMeta));
    }
    if (data.containsKey('set_up_time')) {
      context.handle(
          _setUpTimeMeta,
          setUpTime.isAcceptableOrUnknown(
              data['set_up_time']!, _setUpTimeMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('strike_down_time')) {
      context.handle(
          _strikeDownTimeMeta,
          strikeDownTime.isAcceptableOrUnknown(
              data['strike_down_time']!, _strikeDownTimeMeta));
    }
    if (data.containsKey('mobile_booths')) {
      context.handle(
          _mobileBoothsMeta,
          mobileBooths.isAcceptableOrUnknown(
              data['mobile_booths']!, _mobileBoothsMeta));
    }
    if (data.containsKey('medical_aid')) {
      context.handle(
          _medicalAidMeta,
          medicalAid.isAcceptableOrUnknown(
              data['medical_aid']!, _medicalAidMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('actual_start_time')) {
      context.handle(
          _actualStartTimeMeta,
          actualStartTime.isAcceptableOrUnknown(
              data['actual_start_time']!, _actualStartTimeMeta));
    }
    if (data.containsKey('actual_end_time')) {
      context.handle(
          _actualEndTimeMeta,
          actualEndTime.isAcceptableOrUnknown(
              data['actual_end_time']!, _actualEndTimeMeta));
    }
    if (data.containsKey('screened_count')) {
      context.handle(
          _screenedCountMeta,
          screenedCount.isAcceptableOrUnknown(
              data['screened_count']!, _screenedCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      venue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      townCity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}town_city'])!,
      province: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}province']),
      onsiteContactFirstName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}onsite_contact_first_name'])!,
      onsiteContactLastName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}onsite_contact_last_name'])!,
      onsiteContactNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}onsite_contact_number'])!,
      onsiteContactEmail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}onsite_contact_email'])!,
      aeContactFirstName: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}ae_contact_first_name'])!,
      aeContactLastName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ae_contact_last_name'])!,
      aeContactNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ae_contact_number'])!,
      aeContactEmail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ae_contact_email'])!,
      servicesRequested: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}services_requested'])!,
      additionalServicesRequested: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}additional_services_requested'])!,
      expectedParticipation: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}expected_participation'])!,
      nurses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nurses'])!,
      coordinators: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}coordinators'])!,
      setUpTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_up_time'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      strikeDownTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}strike_down_time'])!,
      mobileBooths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mobile_booths'])!,
      medicalAid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medical_aid'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      actualStartTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}actual_start_time']),
      actualEndTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}actual_end_time']),
      screenedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}screened_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventEntity extends DataClass implements Insertable<EventEntity> {
  final String id;
  final String title;
  final DateTime date;
  final String venue;
  final String address;
  final String townCity;
  final String? province;
  final String onsiteContactFirstName;
  final String onsiteContactLastName;
  final String onsiteContactNumber;
  final String onsiteContactEmail;
  final String aeContactFirstName;
  final String aeContactLastName;
  final String aeContactNumber;
  final String aeContactEmail;
  final String servicesRequested;
  final String additionalServicesRequested;
  final int expectedParticipation;
  final int nurses;
  final int coordinators;
  final String setUpTime;
  final String startTime;
  final String endTime;
  final String strikeDownTime;
  final String mobileBooths;
  final String medicalAid;
  final String? description;
  final String status;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final int screenedCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EventEntity(
      {required this.id,
      required this.title,
      required this.date,
      required this.venue,
      required this.address,
      required this.townCity,
      this.province,
      required this.onsiteContactFirstName,
      required this.onsiteContactLastName,
      required this.onsiteContactNumber,
      required this.onsiteContactEmail,
      required this.aeContactFirstName,
      required this.aeContactLastName,
      required this.aeContactNumber,
      required this.aeContactEmail,
      required this.servicesRequested,
      required this.additionalServicesRequested,
      required this.expectedParticipation,
      required this.nurses,
      required this.coordinators,
      required this.setUpTime,
      required this.startTime,
      required this.endTime,
      required this.strikeDownTime,
      required this.mobileBooths,
      required this.medicalAid,
      this.description,
      required this.status,
      this.actualStartTime,
      this.actualEndTime,
      required this.screenedCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['venue'] = Variable<String>(venue);
    map['address'] = Variable<String>(address);
    map['town_city'] = Variable<String>(townCity);
    if (!nullToAbsent || province != null) {
      map['province'] = Variable<String>(province);
    }
    map['onsite_contact_first_name'] = Variable<String>(onsiteContactFirstName);
    map['onsite_contact_last_name'] = Variable<String>(onsiteContactLastName);
    map['onsite_contact_number'] = Variable<String>(onsiteContactNumber);
    map['onsite_contact_email'] = Variable<String>(onsiteContactEmail);
    map['ae_contact_first_name'] = Variable<String>(aeContactFirstName);
    map['ae_contact_last_name'] = Variable<String>(aeContactLastName);
    map['ae_contact_number'] = Variable<String>(aeContactNumber);
    map['ae_contact_email'] = Variable<String>(aeContactEmail);
    map['services_requested'] = Variable<String>(servicesRequested);
    map['additional_services_requested'] =
        Variable<String>(additionalServicesRequested);
    map['expected_participation'] = Variable<int>(expectedParticipation);
    map['nurses'] = Variable<int>(nurses);
    map['coordinators'] = Variable<int>(coordinators);
    map['set_up_time'] = Variable<String>(setUpTime);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['strike_down_time'] = Variable<String>(strikeDownTime);
    map['mobile_booths'] = Variable<String>(mobileBooths);
    map['medical_aid'] = Variable<String>(medicalAid);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || actualStartTime != null) {
      map['actual_start_time'] = Variable<DateTime>(actualStartTime);
    }
    if (!nullToAbsent || actualEndTime != null) {
      map['actual_end_time'] = Variable<DateTime>(actualEndTime);
    }
    map['screened_count'] = Variable<int>(screenedCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      venue: Value(venue),
      address: Value(address),
      townCity: Value(townCity),
      province: province == null && nullToAbsent
          ? const Value.absent()
          : Value(province),
      onsiteContactFirstName: Value(onsiteContactFirstName),
      onsiteContactLastName: Value(onsiteContactLastName),
      onsiteContactNumber: Value(onsiteContactNumber),
      onsiteContactEmail: Value(onsiteContactEmail),
      aeContactFirstName: Value(aeContactFirstName),
      aeContactLastName: Value(aeContactLastName),
      aeContactNumber: Value(aeContactNumber),
      aeContactEmail: Value(aeContactEmail),
      servicesRequested: Value(servicesRequested),
      additionalServicesRequested: Value(additionalServicesRequested),
      expectedParticipation: Value(expectedParticipation),
      nurses: Value(nurses),
      coordinators: Value(coordinators),
      setUpTime: Value(setUpTime),
      startTime: Value(startTime),
      endTime: Value(endTime),
      strikeDownTime: Value(strikeDownTime),
      mobileBooths: Value(mobileBooths),
      medicalAid: Value(medicalAid),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      actualStartTime: actualStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualStartTime),
      actualEndTime: actualEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualEndTime),
      screenedCount: Value(screenedCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EventEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventEntity(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      venue: serializer.fromJson<String>(json['venue']),
      address: serializer.fromJson<String>(json['address']),
      townCity: serializer.fromJson<String>(json['townCity']),
      province: serializer.fromJson<String?>(json['province']),
      onsiteContactFirstName:
          serializer.fromJson<String>(json['onsiteContactFirstName']),
      onsiteContactLastName:
          serializer.fromJson<String>(json['onsiteContactLastName']),
      onsiteContactNumber:
          serializer.fromJson<String>(json['onsiteContactNumber']),
      onsiteContactEmail:
          serializer.fromJson<String>(json['onsiteContactEmail']),
      aeContactFirstName:
          serializer.fromJson<String>(json['aeContactFirstName']),
      aeContactLastName: serializer.fromJson<String>(json['aeContactLastName']),
      aeContactNumber: serializer.fromJson<String>(json['aeContactNumber']),
      aeContactEmail: serializer.fromJson<String>(json['aeContactEmail']),
      servicesRequested: serializer.fromJson<String>(json['servicesRequested']),
      additionalServicesRequested:
          serializer.fromJson<String>(json['additionalServicesRequested']),
      expectedParticipation:
          serializer.fromJson<int>(json['expectedParticipation']),
      nurses: serializer.fromJson<int>(json['nurses']),
      coordinators: serializer.fromJson<int>(json['coordinators']),
      setUpTime: serializer.fromJson<String>(json['setUpTime']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      strikeDownTime: serializer.fromJson<String>(json['strikeDownTime']),
      mobileBooths: serializer.fromJson<String>(json['mobileBooths']),
      medicalAid: serializer.fromJson<String>(json['medicalAid']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      actualStartTime: serializer.fromJson<DateTime?>(json['actualStartTime']),
      actualEndTime: serializer.fromJson<DateTime?>(json['actualEndTime']),
      screenedCount: serializer.fromJson<int>(json['screenedCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'venue': serializer.toJson<String>(venue),
      'address': serializer.toJson<String>(address),
      'townCity': serializer.toJson<String>(townCity),
      'province': serializer.toJson<String?>(province),
      'onsiteContactFirstName':
          serializer.toJson<String>(onsiteContactFirstName),
      'onsiteContactLastName': serializer.toJson<String>(onsiteContactLastName),
      'onsiteContactNumber': serializer.toJson<String>(onsiteContactNumber),
      'onsiteContactEmail': serializer.toJson<String>(onsiteContactEmail),
      'aeContactFirstName': serializer.toJson<String>(aeContactFirstName),
      'aeContactLastName': serializer.toJson<String>(aeContactLastName),
      'aeContactNumber': serializer.toJson<String>(aeContactNumber),
      'aeContactEmail': serializer.toJson<String>(aeContactEmail),
      'servicesRequested': serializer.toJson<String>(servicesRequested),
      'additionalServicesRequested':
          serializer.toJson<String>(additionalServicesRequested),
      'expectedParticipation': serializer.toJson<int>(expectedParticipation),
      'nurses': serializer.toJson<int>(nurses),
      'coordinators': serializer.toJson<int>(coordinators),
      'setUpTime': serializer.toJson<String>(setUpTime),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'strikeDownTime': serializer.toJson<String>(strikeDownTime),
      'mobileBooths': serializer.toJson<String>(mobileBooths),
      'medicalAid': serializer.toJson<String>(medicalAid),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'actualStartTime': serializer.toJson<DateTime?>(actualStartTime),
      'actualEndTime': serializer.toJson<DateTime?>(actualEndTime),
      'screenedCount': serializer.toJson<int>(screenedCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EventEntity copyWith(
          {String? id,
          String? title,
          DateTime? date,
          String? venue,
          String? address,
          String? townCity,
          Value<String?> province = const Value.absent(),
          String? onsiteContactFirstName,
          String? onsiteContactLastName,
          String? onsiteContactNumber,
          String? onsiteContactEmail,
          String? aeContactFirstName,
          String? aeContactLastName,
          String? aeContactNumber,
          String? aeContactEmail,
          String? servicesRequested,
          String? additionalServicesRequested,
          int? expectedParticipation,
          int? nurses,
          int? coordinators,
          String? setUpTime,
          String? startTime,
          String? endTime,
          String? strikeDownTime,
          String? mobileBooths,
          String? medicalAid,
          Value<String?> description = const Value.absent(),
          String? status,
          Value<DateTime?> actualStartTime = const Value.absent(),
          Value<DateTime?> actualEndTime = const Value.absent(),
          int? screenedCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      EventEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        venue: venue ?? this.venue,
        address: address ?? this.address,
        townCity: townCity ?? this.townCity,
        province: province.present ? province.value : this.province,
        onsiteContactFirstName:
            onsiteContactFirstName ?? this.onsiteContactFirstName,
        onsiteContactLastName:
            onsiteContactLastName ?? this.onsiteContactLastName,
        onsiteContactNumber: onsiteContactNumber ?? this.onsiteContactNumber,
        onsiteContactEmail: onsiteContactEmail ?? this.onsiteContactEmail,
        aeContactFirstName: aeContactFirstName ?? this.aeContactFirstName,
        aeContactLastName: aeContactLastName ?? this.aeContactLastName,
        aeContactNumber: aeContactNumber ?? this.aeContactNumber,
        aeContactEmail: aeContactEmail ?? this.aeContactEmail,
        servicesRequested: servicesRequested ?? this.servicesRequested,
        additionalServicesRequested:
            additionalServicesRequested ?? this.additionalServicesRequested,
        expectedParticipation:
            expectedParticipation ?? this.expectedParticipation,
        nurses: nurses ?? this.nurses,
        coordinators: coordinators ?? this.coordinators,
        setUpTime: setUpTime ?? this.setUpTime,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        strikeDownTime: strikeDownTime ?? this.strikeDownTime,
        mobileBooths: mobileBooths ?? this.mobileBooths,
        medicalAid: medicalAid ?? this.medicalAid,
        description: description.present ? description.value : this.description,
        status: status ?? this.status,
        actualStartTime: actualStartTime.present
            ? actualStartTime.value
            : this.actualStartTime,
        actualEndTime:
            actualEndTime.present ? actualEndTime.value : this.actualEndTime,
        screenedCount: screenedCount ?? this.screenedCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  EventEntity copyWithCompanion(EventsCompanion data) {
    return EventEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      venue: data.venue.present ? data.venue.value : this.venue,
      address: data.address.present ? data.address.value : this.address,
      townCity: data.townCity.present ? data.townCity.value : this.townCity,
      province: data.province.present ? data.province.value : this.province,
      onsiteContactFirstName: data.onsiteContactFirstName.present
          ? data.onsiteContactFirstName.value
          : this.onsiteContactFirstName,
      onsiteContactLastName: data.onsiteContactLastName.present
          ? data.onsiteContactLastName.value
          : this.onsiteContactLastName,
      onsiteContactNumber: data.onsiteContactNumber.present
          ? data.onsiteContactNumber.value
          : this.onsiteContactNumber,
      onsiteContactEmail: data.onsiteContactEmail.present
          ? data.onsiteContactEmail.value
          : this.onsiteContactEmail,
      aeContactFirstName: data.aeContactFirstName.present
          ? data.aeContactFirstName.value
          : this.aeContactFirstName,
      aeContactLastName: data.aeContactLastName.present
          ? data.aeContactLastName.value
          : this.aeContactLastName,
      aeContactNumber: data.aeContactNumber.present
          ? data.aeContactNumber.value
          : this.aeContactNumber,
      aeContactEmail: data.aeContactEmail.present
          ? data.aeContactEmail.value
          : this.aeContactEmail,
      servicesRequested: data.servicesRequested.present
          ? data.servicesRequested.value
          : this.servicesRequested,
      additionalServicesRequested: data.additionalServicesRequested.present
          ? data.additionalServicesRequested.value
          : this.additionalServicesRequested,
      expectedParticipation: data.expectedParticipation.present
          ? data.expectedParticipation.value
          : this.expectedParticipation,
      nurses: data.nurses.present ? data.nurses.value : this.nurses,
      coordinators: data.coordinators.present
          ? data.coordinators.value
          : this.coordinators,
      setUpTime: data.setUpTime.present ? data.setUpTime.value : this.setUpTime,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      strikeDownTime: data.strikeDownTime.present
          ? data.strikeDownTime.value
          : this.strikeDownTime,
      mobileBooths: data.mobileBooths.present
          ? data.mobileBooths.value
          : this.mobileBooths,
      medicalAid:
          data.medicalAid.present ? data.medicalAid.value : this.medicalAid,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      actualStartTime: data.actualStartTime.present
          ? data.actualStartTime.value
          : this.actualStartTime,
      actualEndTime: data.actualEndTime.present
          ? data.actualEndTime.value
          : this.actualEndTime,
      screenedCount: data.screenedCount.present
          ? data.screenedCount.value
          : this.screenedCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventEntity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('venue: $venue, ')
          ..write('address: $address, ')
          ..write('townCity: $townCity, ')
          ..write('province: $province, ')
          ..write('onsiteContactFirstName: $onsiteContactFirstName, ')
          ..write('onsiteContactLastName: $onsiteContactLastName, ')
          ..write('onsiteContactNumber: $onsiteContactNumber, ')
          ..write('onsiteContactEmail: $onsiteContactEmail, ')
          ..write('aeContactFirstName: $aeContactFirstName, ')
          ..write('aeContactLastName: $aeContactLastName, ')
          ..write('aeContactNumber: $aeContactNumber, ')
          ..write('aeContactEmail: $aeContactEmail, ')
          ..write('servicesRequested: $servicesRequested, ')
          ..write('additionalServicesRequested: $additionalServicesRequested, ')
          ..write('expectedParticipation: $expectedParticipation, ')
          ..write('nurses: $nurses, ')
          ..write('coordinators: $coordinators, ')
          ..write('setUpTime: $setUpTime, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('strikeDownTime: $strikeDownTime, ')
          ..write('mobileBooths: $mobileBooths, ')
          ..write('medicalAid: $medicalAid, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('actualStartTime: $actualStartTime, ')
          ..write('actualEndTime: $actualEndTime, ')
          ..write('screenedCount: $screenedCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        date,
        venue,
        address,
        townCity,
        province,
        onsiteContactFirstName,
        onsiteContactLastName,
        onsiteContactNumber,
        onsiteContactEmail,
        aeContactFirstName,
        aeContactLastName,
        aeContactNumber,
        aeContactEmail,
        servicesRequested,
        additionalServicesRequested,
        expectedParticipation,
        nurses,
        coordinators,
        setUpTime,
        startTime,
        endTime,
        strikeDownTime,
        mobileBooths,
        medicalAid,
        description,
        status,
        actualStartTime,
        actualEndTime,
        screenedCount,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventEntity &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.venue == this.venue &&
          other.address == this.address &&
          other.townCity == this.townCity &&
          other.province == this.province &&
          other.onsiteContactFirstName == this.onsiteContactFirstName &&
          other.onsiteContactLastName == this.onsiteContactLastName &&
          other.onsiteContactNumber == this.onsiteContactNumber &&
          other.onsiteContactEmail == this.onsiteContactEmail &&
          other.aeContactFirstName == this.aeContactFirstName &&
          other.aeContactLastName == this.aeContactLastName &&
          other.aeContactNumber == this.aeContactNumber &&
          other.aeContactEmail == this.aeContactEmail &&
          other.servicesRequested == this.servicesRequested &&
          other.additionalServicesRequested ==
              this.additionalServicesRequested &&
          other.expectedParticipation == this.expectedParticipation &&
          other.nurses == this.nurses &&
          other.coordinators == this.coordinators &&
          other.setUpTime == this.setUpTime &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.strikeDownTime == this.strikeDownTime &&
          other.mobileBooths == this.mobileBooths &&
          other.medicalAid == this.medicalAid &&
          other.description == this.description &&
          other.status == this.status &&
          other.actualStartTime == this.actualStartTime &&
          other.actualEndTime == this.actualEndTime &&
          other.screenedCount == this.screenedCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EventsCompanion extends UpdateCompanion<EventEntity> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String> venue;
  final Value<String> address;
  final Value<String> townCity;
  final Value<String?> province;
  final Value<String> onsiteContactFirstName;
  final Value<String> onsiteContactLastName;
  final Value<String> onsiteContactNumber;
  final Value<String> onsiteContactEmail;
  final Value<String> aeContactFirstName;
  final Value<String> aeContactLastName;
  final Value<String> aeContactNumber;
  final Value<String> aeContactEmail;
  final Value<String> servicesRequested;
  final Value<String> additionalServicesRequested;
  final Value<int> expectedParticipation;
  final Value<int> nurses;
  final Value<int> coordinators;
  final Value<String> setUpTime;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> strikeDownTime;
  final Value<String> mobileBooths;
  final Value<String> medicalAid;
  final Value<String?> description;
  final Value<String> status;
  final Value<DateTime?> actualStartTime;
  final Value<DateTime?> actualEndTime;
  final Value<int> screenedCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.venue = const Value.absent(),
    this.address = const Value.absent(),
    this.townCity = const Value.absent(),
    this.province = const Value.absent(),
    this.onsiteContactFirstName = const Value.absent(),
    this.onsiteContactLastName = const Value.absent(),
    this.onsiteContactNumber = const Value.absent(),
    this.onsiteContactEmail = const Value.absent(),
    this.aeContactFirstName = const Value.absent(),
    this.aeContactLastName = const Value.absent(),
    this.aeContactNumber = const Value.absent(),
    this.aeContactEmail = const Value.absent(),
    this.servicesRequested = const Value.absent(),
    this.additionalServicesRequested = const Value.absent(),
    this.expectedParticipation = const Value.absent(),
    this.nurses = const Value.absent(),
    this.coordinators = const Value.absent(),
    this.setUpTime = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.strikeDownTime = const Value.absent(),
    this.mobileBooths = const Value.absent(),
    this.medicalAid = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.actualStartTime = const Value.absent(),
    this.actualEndTime = const Value.absent(),
    this.screenedCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required DateTime date,
    this.venue = const Value.absent(),
    this.address = const Value.absent(),
    this.townCity = const Value.absent(),
    this.province = const Value.absent(),
    this.onsiteContactFirstName = const Value.absent(),
    this.onsiteContactLastName = const Value.absent(),
    this.onsiteContactNumber = const Value.absent(),
    this.onsiteContactEmail = const Value.absent(),
    this.aeContactFirstName = const Value.absent(),
    this.aeContactLastName = const Value.absent(),
    this.aeContactNumber = const Value.absent(),
    this.aeContactEmail = const Value.absent(),
    this.servicesRequested = const Value.absent(),
    this.additionalServicesRequested = const Value.absent(),
    this.expectedParticipation = const Value.absent(),
    this.nurses = const Value.absent(),
    this.coordinators = const Value.absent(),
    this.setUpTime = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.strikeDownTime = const Value.absent(),
    this.mobileBooths = const Value.absent(),
    this.medicalAid = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.actualStartTime = const Value.absent(),
    this.actualEndTime = const Value.absent(),
    this.screenedCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date);
  static Insertable<EventEntity> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? venue,
    Expression<String>? address,
    Expression<String>? townCity,
    Expression<String>? province,
    Expression<String>? onsiteContactFirstName,
    Expression<String>? onsiteContactLastName,
    Expression<String>? onsiteContactNumber,
    Expression<String>? onsiteContactEmail,
    Expression<String>? aeContactFirstName,
    Expression<String>? aeContactLastName,
    Expression<String>? aeContactNumber,
    Expression<String>? aeContactEmail,
    Expression<String>? servicesRequested,
    Expression<String>? additionalServicesRequested,
    Expression<int>? expectedParticipation,
    Expression<int>? nurses,
    Expression<int>? coordinators,
    Expression<String>? setUpTime,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? strikeDownTime,
    Expression<String>? mobileBooths,
    Expression<String>? medicalAid,
    Expression<String>? description,
    Expression<String>? status,
    Expression<DateTime>? actualStartTime,
    Expression<DateTime>? actualEndTime,
    Expression<int>? screenedCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (venue != null) 'venue': venue,
      if (address != null) 'address': address,
      if (townCity != null) 'town_city': townCity,
      if (province != null) 'province': province,
      if (onsiteContactFirstName != null)
        'onsite_contact_first_name': onsiteContactFirstName,
      if (onsiteContactLastName != null)
        'onsite_contact_last_name': onsiteContactLastName,
      if (onsiteContactNumber != null)
        'onsite_contact_number': onsiteContactNumber,
      if (onsiteContactEmail != null)
        'onsite_contact_email': onsiteContactEmail,
      if (aeContactFirstName != null)
        'ae_contact_first_name': aeContactFirstName,
      if (aeContactLastName != null) 'ae_contact_last_name': aeContactLastName,
      if (aeContactNumber != null) 'ae_contact_number': aeContactNumber,
      if (aeContactEmail != null) 'ae_contact_email': aeContactEmail,
      if (servicesRequested != null) 'services_requested': servicesRequested,
      if (additionalServicesRequested != null)
        'additional_services_requested': additionalServicesRequested,
      if (expectedParticipation != null)
        'expected_participation': expectedParticipation,
      if (nurses != null) 'nurses': nurses,
      if (coordinators != null) 'coordinators': coordinators,
      if (setUpTime != null) 'set_up_time': setUpTime,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (strikeDownTime != null) 'strike_down_time': strikeDownTime,
      if (mobileBooths != null) 'mobile_booths': mobileBooths,
      if (medicalAid != null) 'medical_aid': medicalAid,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (actualStartTime != null) 'actual_start_time': actualStartTime,
      if (actualEndTime != null) 'actual_end_time': actualEndTime,
      if (screenedCount != null) 'screened_count': screenedCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? date,
      Value<String>? venue,
      Value<String>? address,
      Value<String>? townCity,
      Value<String?>? province,
      Value<String>? onsiteContactFirstName,
      Value<String>? onsiteContactLastName,
      Value<String>? onsiteContactNumber,
      Value<String>? onsiteContactEmail,
      Value<String>? aeContactFirstName,
      Value<String>? aeContactLastName,
      Value<String>? aeContactNumber,
      Value<String>? aeContactEmail,
      Value<String>? servicesRequested,
      Value<String>? additionalServicesRequested,
      Value<int>? expectedParticipation,
      Value<int>? nurses,
      Value<int>? coordinators,
      Value<String>? setUpTime,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String>? strikeDownTime,
      Value<String>? mobileBooths,
      Value<String>? medicalAid,
      Value<String?>? description,
      Value<String>? status,
      Value<DateTime?>? actualStartTime,
      Value<DateTime?>? actualEndTime,
      Value<int>? screenedCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      address: address ?? this.address,
      townCity: townCity ?? this.townCity,
      province: province ?? this.province,
      onsiteContactFirstName:
          onsiteContactFirstName ?? this.onsiteContactFirstName,
      onsiteContactLastName:
          onsiteContactLastName ?? this.onsiteContactLastName,
      onsiteContactNumber: onsiteContactNumber ?? this.onsiteContactNumber,
      onsiteContactEmail: onsiteContactEmail ?? this.onsiteContactEmail,
      aeContactFirstName: aeContactFirstName ?? this.aeContactFirstName,
      aeContactLastName: aeContactLastName ?? this.aeContactLastName,
      aeContactNumber: aeContactNumber ?? this.aeContactNumber,
      aeContactEmail: aeContactEmail ?? this.aeContactEmail,
      servicesRequested: servicesRequested ?? this.servicesRequested,
      additionalServicesRequested:
          additionalServicesRequested ?? this.additionalServicesRequested,
      expectedParticipation:
          expectedParticipation ?? this.expectedParticipation,
      nurses: nurses ?? this.nurses,
      coordinators: coordinators ?? this.coordinators,
      setUpTime: setUpTime ?? this.setUpTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      strikeDownTime: strikeDownTime ?? this.strikeDownTime,
      mobileBooths: mobileBooths ?? this.mobileBooths,
      medicalAid: medicalAid ?? this.medicalAid,
      description: description ?? this.description,
      status: status ?? this.status,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      screenedCount: screenedCount ?? this.screenedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
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
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (townCity.present) {
      map['town_city'] = Variable<String>(townCity.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (onsiteContactFirstName.present) {
      map['onsite_contact_first_name'] =
          Variable<String>(onsiteContactFirstName.value);
    }
    if (onsiteContactLastName.present) {
      map['onsite_contact_last_name'] =
          Variable<String>(onsiteContactLastName.value);
    }
    if (onsiteContactNumber.present) {
      map['onsite_contact_number'] =
          Variable<String>(onsiteContactNumber.value);
    }
    if (onsiteContactEmail.present) {
      map['onsite_contact_email'] = Variable<String>(onsiteContactEmail.value);
    }
    if (aeContactFirstName.present) {
      map['ae_contact_first_name'] = Variable<String>(aeContactFirstName.value);
    }
    if (aeContactLastName.present) {
      map['ae_contact_last_name'] = Variable<String>(aeContactLastName.value);
    }
    if (aeContactNumber.present) {
      map['ae_contact_number'] = Variable<String>(aeContactNumber.value);
    }
    if (aeContactEmail.present) {
      map['ae_contact_email'] = Variable<String>(aeContactEmail.value);
    }
    if (servicesRequested.present) {
      map['services_requested'] = Variable<String>(servicesRequested.value);
    }
    if (additionalServicesRequested.present) {
      map['additional_services_requested'] =
          Variable<String>(additionalServicesRequested.value);
    }
    if (expectedParticipation.present) {
      map['expected_participation'] =
          Variable<int>(expectedParticipation.value);
    }
    if (nurses.present) {
      map['nurses'] = Variable<int>(nurses.value);
    }
    if (coordinators.present) {
      map['coordinators'] = Variable<int>(coordinators.value);
    }
    if (setUpTime.present) {
      map['set_up_time'] = Variable<String>(setUpTime.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (strikeDownTime.present) {
      map['strike_down_time'] = Variable<String>(strikeDownTime.value);
    }
    if (mobileBooths.present) {
      map['mobile_booths'] = Variable<String>(mobileBooths.value);
    }
    if (medicalAid.present) {
      map['medical_aid'] = Variable<String>(medicalAid.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (actualStartTime.present) {
      map['actual_start_time'] = Variable<DateTime>(actualStartTime.value);
    }
    if (actualEndTime.present) {
      map['actual_end_time'] = Variable<DateTime>(actualEndTime.value);
    }
    if (screenedCount.present) {
      map['screened_count'] = Variable<int>(screenedCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('venue: $venue, ')
          ..write('address: $address, ')
          ..write('townCity: $townCity, ')
          ..write('province: $province, ')
          ..write('onsiteContactFirstName: $onsiteContactFirstName, ')
          ..write('onsiteContactLastName: $onsiteContactLastName, ')
          ..write('onsiteContactNumber: $onsiteContactNumber, ')
          ..write('onsiteContactEmail: $onsiteContactEmail, ')
          ..write('aeContactFirstName: $aeContactFirstName, ')
          ..write('aeContactLastName: $aeContactLastName, ')
          ..write('aeContactNumber: $aeContactNumber, ')
          ..write('aeContactEmail: $aeContactEmail, ')
          ..write('servicesRequested: $servicesRequested, ')
          ..write('additionalServicesRequested: $additionalServicesRequested, ')
          ..write('expectedParticipation: $expectedParticipation, ')
          ..write('nurses: $nurses, ')
          ..write('coordinators: $coordinators, ')
          ..write('setUpTime: $setUpTime, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('strikeDownTime: $strikeDownTime, ')
          ..write('mobileBooths: $mobileBooths, ')
          ..write('medicalAid: $medicalAid, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('actualStartTime: $actualStartTime, ')
          ..write('actualEndTime: $actualEndTime, ')
          ..write('screenedCount: $screenedCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members
    with TableInfo<$MembersTable, MemberEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _surnameMeta =
      const VerificationMeta('surname');
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
      'surname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idNumberMeta =
      const VerificationMeta('idNumber');
  @override
  late final GeneratedColumn<String> idNumber = GeneratedColumn<String>(
      'id_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _passportNumberMeta =
      const VerificationMeta('passportNumber');
  @override
  late final GeneratedColumn<String> passportNumber = GeneratedColumn<String>(
      'passport_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _idDocumentTypeMeta =
      const VerificationMeta('idDocumentType');
  @override
  late final GeneratedColumn<String> idDocumentType = GeneratedColumn<String>(
      'id_document_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _maritalStatusMeta =
      const VerificationMeta('maritalStatus');
  @override
  late final GeneratedColumn<String> maritalStatus = GeneratedColumn<String>(
      'marital_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nationalityMeta =
      const VerificationMeta('nationality');
  @override
  late final GeneratedColumn<String> nationality = GeneratedColumn<String>(
      'nationality', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _citizenshipStatusMeta =
      const VerificationMeta('citizenshipStatus');
  @override
  late final GeneratedColumn<String> citizenshipStatus =
      GeneratedColumn<String>('citizenship_status', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cellNumberMeta =
      const VerificationMeta('cellNumber');
  @override
  late final GeneratedColumn<String> cellNumber = GeneratedColumn<String>(
      'cell_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _medicalAidStatusMeta =
      const VerificationMeta('medicalAidStatus');
  @override
  late final GeneratedColumn<String> medicalAidStatus = GeneratedColumn<String>(
      'medical_aid_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _medicalAidNameMeta =
      const VerificationMeta('medicalAidName');
  @override
  late final GeneratedColumn<String> medicalAidName = GeneratedColumn<String>(
      'medical_aid_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _medicalAidNumberMeta =
      const VerificationMeta('medicalAidNumber');
  @override
  late final GeneratedColumn<String> medicalAidNumber = GeneratedColumn<String>(
      'medical_aid_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        surname,
        idNumber,
        passportNumber,
        idDocumentType,
        dateOfBirth,
        gender,
        maritalStatus,
        nationality,
        citizenshipStatus,
        email,
        cellNumber,
        medicalAidStatus,
        medicalAidName,
        medicalAidNumber,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<MemberEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('surname')) {
      context.handle(_surnameMeta,
          surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta));
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    if (data.containsKey('id_number')) {
      context.handle(_idNumberMeta,
          idNumber.isAcceptableOrUnknown(data['id_number']!, _idNumberMeta));
    }
    if (data.containsKey('passport_number')) {
      context.handle(
          _passportNumberMeta,
          passportNumber.isAcceptableOrUnknown(
              data['passport_number']!, _passportNumberMeta));
    }
    if (data.containsKey('id_document_type')) {
      context.handle(
          _idDocumentTypeMeta,
          idDocumentType.isAcceptableOrUnknown(
              data['id_document_type']!, _idDocumentTypeMeta));
    } else if (isInserting) {
      context.missing(_idDocumentTypeMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('marital_status')) {
      context.handle(
          _maritalStatusMeta,
          maritalStatus.isAcceptableOrUnknown(
              data['marital_status']!, _maritalStatusMeta));
    }
    if (data.containsKey('nationality')) {
      context.handle(
          _nationalityMeta,
          nationality.isAcceptableOrUnknown(
              data['nationality']!, _nationalityMeta));
    }
    if (data.containsKey('citizenship_status')) {
      context.handle(
          _citizenshipStatusMeta,
          citizenshipStatus.isAcceptableOrUnknown(
              data['citizenship_status']!, _citizenshipStatusMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('cell_number')) {
      context.handle(
          _cellNumberMeta,
          cellNumber.isAcceptableOrUnknown(
              data['cell_number']!, _cellNumberMeta));
    }
    if (data.containsKey('medical_aid_status')) {
      context.handle(
          _medicalAidStatusMeta,
          medicalAidStatus.isAcceptableOrUnknown(
              data['medical_aid_status']!, _medicalAidStatusMeta));
    }
    if (data.containsKey('medical_aid_name')) {
      context.handle(
          _medicalAidNameMeta,
          medicalAidName.isAcceptableOrUnknown(
              data['medical_aid_name']!, _medicalAidNameMeta));
    }
    if (data.containsKey('medical_aid_number')) {
      context.handle(
          _medicalAidNumberMeta,
          medicalAidNumber.isAcceptableOrUnknown(
              data['medical_aid_number']!, _medicalAidNumberMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      surname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}surname'])!,
      idNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_number']),
      passportNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}passport_number']),
      idDocumentType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}id_document_type'])!,
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_of_birth']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      maritalStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}marital_status']),
      nationality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nationality']),
      citizenshipStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}citizenship_status']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      cellNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cell_number']),
      medicalAidStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medical_aid_status']),
      medicalAidName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medical_aid_name']),
      medicalAidNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medical_aid_number']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class MemberEntity extends DataClass implements Insertable<MemberEntity> {
  final String id;
  final String name;
  final String surname;
  final String? idNumber;
  final String? passportNumber;
  final String idDocumentType;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? nationality;
  final String? citizenshipStatus;
  final String? email;
  final String? cellNumber;
  final String? medicalAidStatus;
  final String? medicalAidName;
  final String? medicalAidNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MemberEntity(
      {required this.id,
      required this.name,
      required this.surname,
      this.idNumber,
      this.passportNumber,
      required this.idDocumentType,
      this.dateOfBirth,
      this.gender,
      this.maritalStatus,
      this.nationality,
      this.citizenshipStatus,
      this.email,
      this.cellNumber,
      this.medicalAidStatus,
      this.medicalAidName,
      this.medicalAidNumber,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['surname'] = Variable<String>(surname);
    if (!nullToAbsent || idNumber != null) {
      map['id_number'] = Variable<String>(idNumber);
    }
    if (!nullToAbsent || passportNumber != null) {
      map['passport_number'] = Variable<String>(passportNumber);
    }
    map['id_document_type'] = Variable<String>(idDocumentType);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || maritalStatus != null) {
      map['marital_status'] = Variable<String>(maritalStatus);
    }
    if (!nullToAbsent || nationality != null) {
      map['nationality'] = Variable<String>(nationality);
    }
    if (!nullToAbsent || citizenshipStatus != null) {
      map['citizenship_status'] = Variable<String>(citizenshipStatus);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || cellNumber != null) {
      map['cell_number'] = Variable<String>(cellNumber);
    }
    if (!nullToAbsent || medicalAidStatus != null) {
      map['medical_aid_status'] = Variable<String>(medicalAidStatus);
    }
    if (!nullToAbsent || medicalAidName != null) {
      map['medical_aid_name'] = Variable<String>(medicalAidName);
    }
    if (!nullToAbsent || medicalAidNumber != null) {
      map['medical_aid_number'] = Variable<String>(medicalAidNumber);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      name: Value(name),
      surname: Value(surname),
      idNumber: idNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(idNumber),
      passportNumber: passportNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(passportNumber),
      idDocumentType: Value(idDocumentType),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      maritalStatus: maritalStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(maritalStatus),
      nationality: nationality == null && nullToAbsent
          ? const Value.absent()
          : Value(nationality),
      citizenshipStatus: citizenshipStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(citizenshipStatus),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      cellNumber: cellNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(cellNumber),
      medicalAidStatus: medicalAidStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalAidStatus),
      medicalAidName: medicalAidName == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalAidName),
      medicalAidNumber: medicalAidNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalAidNumber),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MemberEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      surname: serializer.fromJson<String>(json['surname']),
      idNumber: serializer.fromJson<String?>(json['idNumber']),
      passportNumber: serializer.fromJson<String?>(json['passportNumber']),
      idDocumentType: serializer.fromJson<String>(json['idDocumentType']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      gender: serializer.fromJson<String?>(json['gender']),
      maritalStatus: serializer.fromJson<String?>(json['maritalStatus']),
      nationality: serializer.fromJson<String?>(json['nationality']),
      citizenshipStatus:
          serializer.fromJson<String?>(json['citizenshipStatus']),
      email: serializer.fromJson<String?>(json['email']),
      cellNumber: serializer.fromJson<String?>(json['cellNumber']),
      medicalAidStatus: serializer.fromJson<String?>(json['medicalAidStatus']),
      medicalAidName: serializer.fromJson<String?>(json['medicalAidName']),
      medicalAidNumber: serializer.fromJson<String?>(json['medicalAidNumber']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'surname': serializer.toJson<String>(surname),
      'idNumber': serializer.toJson<String?>(idNumber),
      'passportNumber': serializer.toJson<String?>(passportNumber),
      'idDocumentType': serializer.toJson<String>(idDocumentType),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'gender': serializer.toJson<String?>(gender),
      'maritalStatus': serializer.toJson<String?>(maritalStatus),
      'nationality': serializer.toJson<String?>(nationality),
      'citizenshipStatus': serializer.toJson<String?>(citizenshipStatus),
      'email': serializer.toJson<String?>(email),
      'cellNumber': serializer.toJson<String?>(cellNumber),
      'medicalAidStatus': serializer.toJson<String?>(medicalAidStatus),
      'medicalAidName': serializer.toJson<String?>(medicalAidName),
      'medicalAidNumber': serializer.toJson<String?>(medicalAidNumber),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MemberEntity copyWith(
          {String? id,
          String? name,
          String? surname,
          Value<String?> idNumber = const Value.absent(),
          Value<String?> passportNumber = const Value.absent(),
          String? idDocumentType,
          Value<String?> dateOfBirth = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<String?> maritalStatus = const Value.absent(),
          Value<String?> nationality = const Value.absent(),
          Value<String?> citizenshipStatus = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> cellNumber = const Value.absent(),
          Value<String?> medicalAidStatus = const Value.absent(),
          Value<String?> medicalAidName = const Value.absent(),
          Value<String?> medicalAidNumber = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MemberEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        idNumber: idNumber.present ? idNumber.value : this.idNumber,
        passportNumber:
            passportNumber.present ? passportNumber.value : this.passportNumber,
        idDocumentType: idDocumentType ?? this.idDocumentType,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        gender: gender.present ? gender.value : this.gender,
        maritalStatus:
            maritalStatus.present ? maritalStatus.value : this.maritalStatus,
        nationality: nationality.present ? nationality.value : this.nationality,
        citizenshipStatus: citizenshipStatus.present
            ? citizenshipStatus.value
            : this.citizenshipStatus,
        email: email.present ? email.value : this.email,
        cellNumber: cellNumber.present ? cellNumber.value : this.cellNumber,
        medicalAidStatus: medicalAidStatus.present
            ? medicalAidStatus.value
            : this.medicalAidStatus,
        medicalAidName:
            medicalAidName.present ? medicalAidName.value : this.medicalAidName,
        medicalAidNumber: medicalAidNumber.present
            ? medicalAidNumber.value
            : this.medicalAidNumber,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MemberEntity copyWithCompanion(MembersCompanion data) {
    return MemberEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      surname: data.surname.present ? data.surname.value : this.surname,
      idNumber: data.idNumber.present ? data.idNumber.value : this.idNumber,
      passportNumber: data.passportNumber.present
          ? data.passportNumber.value
          : this.passportNumber,
      idDocumentType: data.idDocumentType.present
          ? data.idDocumentType.value
          : this.idDocumentType,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      maritalStatus: data.maritalStatus.present
          ? data.maritalStatus.value
          : this.maritalStatus,
      nationality:
          data.nationality.present ? data.nationality.value : this.nationality,
      citizenshipStatus: data.citizenshipStatus.present
          ? data.citizenshipStatus.value
          : this.citizenshipStatus,
      email: data.email.present ? data.email.value : this.email,
      cellNumber:
          data.cellNumber.present ? data.cellNumber.value : this.cellNumber,
      medicalAidStatus: data.medicalAidStatus.present
          ? data.medicalAidStatus.value
          : this.medicalAidStatus,
      medicalAidName: data.medicalAidName.present
          ? data.medicalAidName.value
          : this.medicalAidName,
      medicalAidNumber: data.medicalAidNumber.present
          ? data.medicalAidNumber.value
          : this.medicalAidNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('idNumber: $idNumber, ')
          ..write('passportNumber: $passportNumber, ')
          ..write('idDocumentType: $idDocumentType, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('maritalStatus: $maritalStatus, ')
          ..write('nationality: $nationality, ')
          ..write('citizenshipStatus: $citizenshipStatus, ')
          ..write('email: $email, ')
          ..write('cellNumber: $cellNumber, ')
          ..write('medicalAidStatus: $medicalAidStatus, ')
          ..write('medicalAidName: $medicalAidName, ')
          ..write('medicalAidNumber: $medicalAidNumber, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      surname,
      idNumber,
      passportNumber,
      idDocumentType,
      dateOfBirth,
      gender,
      maritalStatus,
      nationality,
      citizenshipStatus,
      email,
      cellNumber,
      medicalAidStatus,
      medicalAidName,
      medicalAidNumber,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.surname == this.surname &&
          other.idNumber == this.idNumber &&
          other.passportNumber == this.passportNumber &&
          other.idDocumentType == this.idDocumentType &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.maritalStatus == this.maritalStatus &&
          other.nationality == this.nationality &&
          other.citizenshipStatus == this.citizenshipStatus &&
          other.email == this.email &&
          other.cellNumber == this.cellNumber &&
          other.medicalAidStatus == this.medicalAidStatus &&
          other.medicalAidName == this.medicalAidName &&
          other.medicalAidNumber == this.medicalAidNumber &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MembersCompanion extends UpdateCompanion<MemberEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> surname;
  final Value<String?> idNumber;
  final Value<String?> passportNumber;
  final Value<String> idDocumentType;
  final Value<String?> dateOfBirth;
  final Value<String?> gender;
  final Value<String?> maritalStatus;
  final Value<String?> nationality;
  final Value<String?> citizenshipStatus;
  final Value<String?> email;
  final Value<String?> cellNumber;
  final Value<String?> medicalAidStatus;
  final Value<String?> medicalAidName;
  final Value<String?> medicalAidNumber;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.surname = const Value.absent(),
    this.idNumber = const Value.absent(),
    this.passportNumber = const Value.absent(),
    this.idDocumentType = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.maritalStatus = const Value.absent(),
    this.nationality = const Value.absent(),
    this.citizenshipStatus = const Value.absent(),
    this.email = const Value.absent(),
    this.cellNumber = const Value.absent(),
    this.medicalAidStatus = const Value.absent(),
    this.medicalAidName = const Value.absent(),
    this.medicalAidNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String name,
    required String surname,
    this.idNumber = const Value.absent(),
    this.passportNumber = const Value.absent(),
    required String idDocumentType,
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.maritalStatus = const Value.absent(),
    this.nationality = const Value.absent(),
    this.citizenshipStatus = const Value.absent(),
    this.email = const Value.absent(),
    this.cellNumber = const Value.absent(),
    this.medicalAidStatus = const Value.absent(),
    this.medicalAidName = const Value.absent(),
    this.medicalAidNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        surname = Value(surname),
        idDocumentType = Value(idDocumentType);
  static Insertable<MemberEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? surname,
    Expression<String>? idNumber,
    Expression<String>? passportNumber,
    Expression<String>? idDocumentType,
    Expression<String>? dateOfBirth,
    Expression<String>? gender,
    Expression<String>? maritalStatus,
    Expression<String>? nationality,
    Expression<String>? citizenshipStatus,
    Expression<String>? email,
    Expression<String>? cellNumber,
    Expression<String>? medicalAidStatus,
    Expression<String>? medicalAidName,
    Expression<String>? medicalAidNumber,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (idNumber != null) 'id_number': idNumber,
      if (passportNumber != null) 'passport_number': passportNumber,
      if (idDocumentType != null) 'id_document_type': idDocumentType,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (nationality != null) 'nationality': nationality,
      if (citizenshipStatus != null) 'citizenship_status': citizenshipStatus,
      if (email != null) 'email': email,
      if (cellNumber != null) 'cell_number': cellNumber,
      if (medicalAidStatus != null) 'medical_aid_status': medicalAidStatus,
      if (medicalAidName != null) 'medical_aid_name': medicalAidName,
      if (medicalAidNumber != null) 'medical_aid_number': medicalAidNumber,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? surname,
      Value<String?>? idNumber,
      Value<String?>? passportNumber,
      Value<String>? idDocumentType,
      Value<String?>? dateOfBirth,
      Value<String?>? gender,
      Value<String?>? maritalStatus,
      Value<String?>? nationality,
      Value<String?>? citizenshipStatus,
      Value<String?>? email,
      Value<String?>? cellNumber,
      Value<String?>? medicalAidStatus,
      Value<String?>? medicalAidName,
      Value<String?>? medicalAidNumber,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      idNumber: idNumber ?? this.idNumber,
      passportNumber: passportNumber ?? this.passportNumber,
      idDocumentType: idDocumentType ?? this.idDocumentType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nationality: nationality ?? this.nationality,
      citizenshipStatus: citizenshipStatus ?? this.citizenshipStatus,
      email: email ?? this.email,
      cellNumber: cellNumber ?? this.cellNumber,
      medicalAidStatus: medicalAidStatus ?? this.medicalAidStatus,
      medicalAidName: medicalAidName ?? this.medicalAidName,
      medicalAidNumber: medicalAidNumber ?? this.medicalAidNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (idNumber.present) {
      map['id_number'] = Variable<String>(idNumber.value);
    }
    if (passportNumber.present) {
      map['passport_number'] = Variable<String>(passportNumber.value);
    }
    if (idDocumentType.present) {
      map['id_document_type'] = Variable<String>(idDocumentType.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (maritalStatus.present) {
      map['marital_status'] = Variable<String>(maritalStatus.value);
    }
    if (nationality.present) {
      map['nationality'] = Variable<String>(nationality.value);
    }
    if (citizenshipStatus.present) {
      map['citizenship_status'] = Variable<String>(citizenshipStatus.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (cellNumber.present) {
      map['cell_number'] = Variable<String>(cellNumber.value);
    }
    if (medicalAidStatus.present) {
      map['medical_aid_status'] = Variable<String>(medicalAidStatus.value);
    }
    if (medicalAidName.present) {
      map['medical_aid_name'] = Variable<String>(medicalAidName.value);
    }
    if (medicalAidNumber.present) {
      map['medical_aid_number'] = Variable<String>(medicalAidNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('surname: $surname, ')
          ..write('idNumber: $idNumber, ')
          ..write('passportNumber: $passportNumber, ')
          ..write('idDocumentType: $idDocumentType, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('maritalStatus: $maritalStatus, ')
          ..write('nationality: $nationality, ')
          ..write('citizenshipStatus: $citizenshipStatus, ')
          ..write('email: $email, ')
          ..write('cellNumber: $cellNumber, ')
          ..write('medicalAidStatus: $medicalAidStatus, ')
          ..write('medicalAidName: $medicalAidName, ')
          ..write('medicalAidNumber: $medicalAidNumber, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $MembersTable members = $MembersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [users, events, members];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String email,
  required String password,
  required String role,
  required String phoneNumber,
  required String firstName,
  required String lastName,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> password,
  Value<String> role,
  Value<String> phoneNumber,
  Value<String> firstName,
  Value<String> lastName,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
    UserEntity,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            password: password,
            role: role,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            required String password,
            required String role,
            required String phoneNumber,
            required String firstName,
            required String lastName,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            password: password,
            role: role,
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
    UserEntity,
    PrefetchHooks Function()>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  Value<String> title,
  required DateTime date,
  Value<String> venue,
  Value<String> address,
  Value<String> townCity,
  Value<String?> province,
  Value<String> onsiteContactFirstName,
  Value<String> onsiteContactLastName,
  Value<String> onsiteContactNumber,
  Value<String> onsiteContactEmail,
  Value<String> aeContactFirstName,
  Value<String> aeContactLastName,
  Value<String> aeContactNumber,
  Value<String> aeContactEmail,
  Value<String> servicesRequested,
  Value<String> additionalServicesRequested,
  Value<int> expectedParticipation,
  Value<int> nurses,
  Value<int> coordinators,
  Value<String> setUpTime,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> strikeDownTime,
  Value<String> mobileBooths,
  Value<String> medicalAid,
  Value<String?> description,
  Value<String> status,
  Value<DateTime?> actualStartTime,
  Value<DateTime?> actualEndTime,
  Value<int> screenedCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> date,
  Value<String> venue,
  Value<String> address,
  Value<String> townCity,
  Value<String?> province,
  Value<String> onsiteContactFirstName,
  Value<String> onsiteContactLastName,
  Value<String> onsiteContactNumber,
  Value<String> onsiteContactEmail,
  Value<String> aeContactFirstName,
  Value<String> aeContactLastName,
  Value<String> aeContactNumber,
  Value<String> aeContactEmail,
  Value<String> servicesRequested,
  Value<String> additionalServicesRequested,
  Value<int> expectedParticipation,
  Value<int> nurses,
  Value<int> coordinators,
  Value<String> setUpTime,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> strikeDownTime,
  Value<String> mobileBooths,
  Value<String> medicalAid,
  Value<String?> description,
  Value<String> status,
  Value<DateTime?> actualStartTime,
  Value<DateTime?> actualEndTime,
  Value<int> screenedCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get townCity => $composableBuilder(
      column: $table.townCity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onsiteContactFirstName => $composableBuilder(
      column: $table.onsiteContactFirstName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onsiteContactLastName => $composableBuilder(
      column: $table.onsiteContactLastName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onsiteContactNumber => $composableBuilder(
      column: $table.onsiteContactNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onsiteContactEmail => $composableBuilder(
      column: $table.onsiteContactEmail,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aeContactFirstName => $composableBuilder(
      column: $table.aeContactFirstName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aeContactLastName => $composableBuilder(
      column: $table.aeContactLastName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aeContactNumber => $composableBuilder(
      column: $table.aeContactNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aeContactEmail => $composableBuilder(
      column: $table.aeContactEmail,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get servicesRequested => $composableBuilder(
      column: $table.servicesRequested,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get additionalServicesRequested => $composableBuilder(
      column: $table.additionalServicesRequested,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expectedParticipation => $composableBuilder(
      column: $table.expectedParticipation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nurses => $composableBuilder(
      column: $table.nurses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coordinators => $composableBuilder(
      column: $table.coordinators, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setUpTime => $composableBuilder(
      column: $table.setUpTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strikeDownTime => $composableBuilder(
      column: $table.strikeDownTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mobileBooths => $composableBuilder(
      column: $table.mobileBooths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicalAid => $composableBuilder(
      column: $table.medicalAid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actualStartTime => $composableBuilder(
      column: $table.actualStartTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actualEndTime => $composableBuilder(
      column: $table.actualEndTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get screenedCount => $composableBuilder(
      column: $table.screenedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get townCity => $composableBuilder(
      column: $table.townCity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onsiteContactFirstName => $composableBuilder(
      column: $table.onsiteContactFirstName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onsiteContactLastName => $composableBuilder(
      column: $table.onsiteContactLastName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onsiteContactNumber => $composableBuilder(
      column: $table.onsiteContactNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onsiteContactEmail => $composableBuilder(
      column: $table.onsiteContactEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aeContactFirstName => $composableBuilder(
      column: $table.aeContactFirstName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aeContactLastName => $composableBuilder(
      column: $table.aeContactLastName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aeContactNumber => $composableBuilder(
      column: $table.aeContactNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aeContactEmail => $composableBuilder(
      column: $table.aeContactEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get servicesRequested => $composableBuilder(
      column: $table.servicesRequested,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get additionalServicesRequested => $composableBuilder(
      column: $table.additionalServicesRequested,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expectedParticipation => $composableBuilder(
      column: $table.expectedParticipation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nurses => $composableBuilder(
      column: $table.nurses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coordinators => $composableBuilder(
      column: $table.coordinators,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setUpTime => $composableBuilder(
      column: $table.setUpTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strikeDownTime => $composableBuilder(
      column: $table.strikeDownTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mobileBooths => $composableBuilder(
      column: $table.mobileBooths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicalAid => $composableBuilder(
      column: $table.medicalAid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actualStartTime => $composableBuilder(
      column: $table.actualStartTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actualEndTime => $composableBuilder(
      column: $table.actualEndTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get screenedCount => $composableBuilder(
      column: $table.screenedCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get townCity =>
      $composableBuilder(column: $table.townCity, builder: (column) => column);

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get onsiteContactFirstName => $composableBuilder(
      column: $table.onsiteContactFirstName, builder: (column) => column);

  GeneratedColumn<String> get onsiteContactLastName => $composableBuilder(
      column: $table.onsiteContactLastName, builder: (column) => column);

  GeneratedColumn<String> get onsiteContactNumber => $composableBuilder(
      column: $table.onsiteContactNumber, builder: (column) => column);

  GeneratedColumn<String> get onsiteContactEmail => $composableBuilder(
      column: $table.onsiteContactEmail, builder: (column) => column);

  GeneratedColumn<String> get aeContactFirstName => $composableBuilder(
      column: $table.aeContactFirstName, builder: (column) => column);

  GeneratedColumn<String> get aeContactLastName => $composableBuilder(
      column: $table.aeContactLastName, builder: (column) => column);

  GeneratedColumn<String> get aeContactNumber => $composableBuilder(
      column: $table.aeContactNumber, builder: (column) => column);

  GeneratedColumn<String> get aeContactEmail => $composableBuilder(
      column: $table.aeContactEmail, builder: (column) => column);

  GeneratedColumn<String> get servicesRequested => $composableBuilder(
      column: $table.servicesRequested, builder: (column) => column);

  GeneratedColumn<String> get additionalServicesRequested => $composableBuilder(
      column: $table.additionalServicesRequested, builder: (column) => column);

  GeneratedColumn<int> get expectedParticipation => $composableBuilder(
      column: $table.expectedParticipation, builder: (column) => column);

  GeneratedColumn<int> get nurses =>
      $composableBuilder(column: $table.nurses, builder: (column) => column);

  GeneratedColumn<int> get coordinators => $composableBuilder(
      column: $table.coordinators, builder: (column) => column);

  GeneratedColumn<String> get setUpTime =>
      $composableBuilder(column: $table.setUpTime, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get strikeDownTime => $composableBuilder(
      column: $table.strikeDownTime, builder: (column) => column);

  GeneratedColumn<String> get mobileBooths => $composableBuilder(
      column: $table.mobileBooths, builder: (column) => column);

  GeneratedColumn<String> get medicalAid => $composableBuilder(
      column: $table.medicalAid, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get actualStartTime => $composableBuilder(
      column: $table.actualStartTime, builder: (column) => column);

  GeneratedColumn<DateTime> get actualEndTime => $composableBuilder(
      column: $table.actualEndTime, builder: (column) => column);

  GeneratedColumn<int> get screenedCount => $composableBuilder(
      column: $table.screenedCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    EventEntity,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventEntity, BaseReferences<_$AppDatabase, $EventsTable, EventEntity>),
    EventEntity,
    PrefetchHooks Function()> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> venue = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> townCity = const Value.absent(),
            Value<String?> province = const Value.absent(),
            Value<String> onsiteContactFirstName = const Value.absent(),
            Value<String> onsiteContactLastName = const Value.absent(),
            Value<String> onsiteContactNumber = const Value.absent(),
            Value<String> onsiteContactEmail = const Value.absent(),
            Value<String> aeContactFirstName = const Value.absent(),
            Value<String> aeContactLastName = const Value.absent(),
            Value<String> aeContactNumber = const Value.absent(),
            Value<String> aeContactEmail = const Value.absent(),
            Value<String> servicesRequested = const Value.absent(),
            Value<String> additionalServicesRequested = const Value.absent(),
            Value<int> expectedParticipation = const Value.absent(),
            Value<int> nurses = const Value.absent(),
            Value<int> coordinators = const Value.absent(),
            Value<String> setUpTime = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> strikeDownTime = const Value.absent(),
            Value<String> mobileBooths = const Value.absent(),
            Value<String> medicalAid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> actualStartTime = const Value.absent(),
            Value<DateTime?> actualEndTime = const Value.absent(),
            Value<int> screenedCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            title: title,
            date: date,
            venue: venue,
            address: address,
            townCity: townCity,
            province: province,
            onsiteContactFirstName: onsiteContactFirstName,
            onsiteContactLastName: onsiteContactLastName,
            onsiteContactNumber: onsiteContactNumber,
            onsiteContactEmail: onsiteContactEmail,
            aeContactFirstName: aeContactFirstName,
            aeContactLastName: aeContactLastName,
            aeContactNumber: aeContactNumber,
            aeContactEmail: aeContactEmail,
            servicesRequested: servicesRequested,
            additionalServicesRequested: additionalServicesRequested,
            expectedParticipation: expectedParticipation,
            nurses: nurses,
            coordinators: coordinators,
            setUpTime: setUpTime,
            startTime: startTime,
            endTime: endTime,
            strikeDownTime: strikeDownTime,
            mobileBooths: mobileBooths,
            medicalAid: medicalAid,
            description: description,
            status: status,
            actualStartTime: actualStartTime,
            actualEndTime: actualEndTime,
            screenedCount: screenedCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> title = const Value.absent(),
            required DateTime date,
            Value<String> venue = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> townCity = const Value.absent(),
            Value<String?> province = const Value.absent(),
            Value<String> onsiteContactFirstName = const Value.absent(),
            Value<String> onsiteContactLastName = const Value.absent(),
            Value<String> onsiteContactNumber = const Value.absent(),
            Value<String> onsiteContactEmail = const Value.absent(),
            Value<String> aeContactFirstName = const Value.absent(),
            Value<String> aeContactLastName = const Value.absent(),
            Value<String> aeContactNumber = const Value.absent(),
            Value<String> aeContactEmail = const Value.absent(),
            Value<String> servicesRequested = const Value.absent(),
            Value<String> additionalServicesRequested = const Value.absent(),
            Value<int> expectedParticipation = const Value.absent(),
            Value<int> nurses = const Value.absent(),
            Value<int> coordinators = const Value.absent(),
            Value<String> setUpTime = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> strikeDownTime = const Value.absent(),
            Value<String> mobileBooths = const Value.absent(),
            Value<String> medicalAid = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> actualStartTime = const Value.absent(),
            Value<DateTime?> actualEndTime = const Value.absent(),
            Value<int> screenedCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            title: title,
            date: date,
            venue: venue,
            address: address,
            townCity: townCity,
            province: province,
            onsiteContactFirstName: onsiteContactFirstName,
            onsiteContactLastName: onsiteContactLastName,
            onsiteContactNumber: onsiteContactNumber,
            onsiteContactEmail: onsiteContactEmail,
            aeContactFirstName: aeContactFirstName,
            aeContactLastName: aeContactLastName,
            aeContactNumber: aeContactNumber,
            aeContactEmail: aeContactEmail,
            servicesRequested: servicesRequested,
            additionalServicesRequested: additionalServicesRequested,
            expectedParticipation: expectedParticipation,
            nurses: nurses,
            coordinators: coordinators,
            setUpTime: setUpTime,
            startTime: startTime,
            endTime: endTime,
            strikeDownTime: strikeDownTime,
            mobileBooths: mobileBooths,
            medicalAid: medicalAid,
            description: description,
            status: status,
            actualStartTime: actualStartTime,
            actualEndTime: actualEndTime,
            screenedCount: screenedCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    EventEntity,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventEntity, BaseReferences<_$AppDatabase, $EventsTable, EventEntity>),
    EventEntity,
    PrefetchHooks Function()>;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  required String name,
  required String surname,
  Value<String?> idNumber,
  Value<String?> passportNumber,
  required String idDocumentType,
  Value<String?> dateOfBirth,
  Value<String?> gender,
  Value<String?> maritalStatus,
  Value<String?> nationality,
  Value<String?> citizenshipStatus,
  Value<String?> email,
  Value<String?> cellNumber,
  Value<String?> medicalAidStatus,
  Value<String?> medicalAidName,
  Value<String?> medicalAidNumber,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> surname,
  Value<String?> idNumber,
  Value<String?> passportNumber,
  Value<String> idDocumentType,
  Value<String?> dateOfBirth,
  Value<String?> gender,
  Value<String?> maritalStatus,
  Value<String?> nationality,
  Value<String?> citizenshipStatus,
  Value<String?> email,
  Value<String?> cellNumber,
  Value<String?> medicalAidStatus,
  Value<String?> medicalAidName,
  Value<String?> medicalAidNumber,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get surname => $composableBuilder(
      column: $table.surname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idNumber => $composableBuilder(
      column: $table.idNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passportNumber => $composableBuilder(
      column: $table.passportNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idDocumentType => $composableBuilder(
      column: $table.idDocumentType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get maritalStatus => $composableBuilder(
      column: $table.maritalStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citizenshipStatus => $composableBuilder(
      column: $table.citizenshipStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cellNumber => $composableBuilder(
      column: $table.cellNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicalAidStatus => $composableBuilder(
      column: $table.medicalAidStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicalAidName => $composableBuilder(
      column: $table.medicalAidName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicalAidNumber => $composableBuilder(
      column: $table.medicalAidNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get surname => $composableBuilder(
      column: $table.surname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idNumber => $composableBuilder(
      column: $table.idNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passportNumber => $composableBuilder(
      column: $table.passportNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idDocumentType => $composableBuilder(
      column: $table.idDocumentType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get maritalStatus => $composableBuilder(
      column: $table.maritalStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citizenshipStatus => $composableBuilder(
      column: $table.citizenshipStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cellNumber => $composableBuilder(
      column: $table.cellNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicalAidStatus => $composableBuilder(
      column: $table.medicalAidStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicalAidName => $composableBuilder(
      column: $table.medicalAidName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicalAidNumber => $composableBuilder(
      column: $table.medicalAidNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get idNumber =>
      $composableBuilder(column: $table.idNumber, builder: (column) => column);

  GeneratedColumn<String> get passportNumber => $composableBuilder(
      column: $table.passportNumber, builder: (column) => column);

  GeneratedColumn<String> get idDocumentType => $composableBuilder(
      column: $table.idDocumentType, builder: (column) => column);

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get maritalStatus => $composableBuilder(
      column: $table.maritalStatus, builder: (column) => column);

  GeneratedColumn<String> get nationality => $composableBuilder(
      column: $table.nationality, builder: (column) => column);

  GeneratedColumn<String> get citizenshipStatus => $composableBuilder(
      column: $table.citizenshipStatus, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get cellNumber => $composableBuilder(
      column: $table.cellNumber, builder: (column) => column);

  GeneratedColumn<String> get medicalAidStatus => $composableBuilder(
      column: $table.medicalAidStatus, builder: (column) => column);

  GeneratedColumn<String> get medicalAidName => $composableBuilder(
      column: $table.medicalAidName, builder: (column) => column);

  GeneratedColumn<String> get medicalAidNumber => $composableBuilder(
      column: $table.medicalAidNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MembersTable,
    MemberEntity,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (MemberEntity, BaseReferences<_$AppDatabase, $MembersTable, MemberEntity>),
    MemberEntity,
    PrefetchHooks Function()> {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> surname = const Value.absent(),
            Value<String?> idNumber = const Value.absent(),
            Value<String?> passportNumber = const Value.absent(),
            Value<String> idDocumentType = const Value.absent(),
            Value<String?> dateOfBirth = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> maritalStatus = const Value.absent(),
            Value<String?> nationality = const Value.absent(),
            Value<String?> citizenshipStatus = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> cellNumber = const Value.absent(),
            Value<String?> medicalAidStatus = const Value.absent(),
            Value<String?> medicalAidName = const Value.absent(),
            Value<String?> medicalAidNumber = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion(
            id: id,
            name: name,
            surname: surname,
            idNumber: idNumber,
            passportNumber: passportNumber,
            idDocumentType: idDocumentType,
            dateOfBirth: dateOfBirth,
            gender: gender,
            maritalStatus: maritalStatus,
            nationality: nationality,
            citizenshipStatus: citizenshipStatus,
            email: email,
            cellNumber: cellNumber,
            medicalAidStatus: medicalAidStatus,
            medicalAidName: medicalAidName,
            medicalAidNumber: medicalAidNumber,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String surname,
            Value<String?> idNumber = const Value.absent(),
            Value<String?> passportNumber = const Value.absent(),
            required String idDocumentType,
            Value<String?> dateOfBirth = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> maritalStatus = const Value.absent(),
            Value<String?> nationality = const Value.absent(),
            Value<String?> citizenshipStatus = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> cellNumber = const Value.absent(),
            Value<String?> medicalAidStatus = const Value.absent(),
            Value<String?> medicalAidName = const Value.absent(),
            Value<String?> medicalAidNumber = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion.insert(
            id: id,
            name: name,
            surname: surname,
            idNumber: idNumber,
            passportNumber: passportNumber,
            idDocumentType: idDocumentType,
            dateOfBirth: dateOfBirth,
            gender: gender,
            maritalStatus: maritalStatus,
            nationality: nationality,
            citizenshipStatus: citizenshipStatus,
            email: email,
            cellNumber: cellNumber,
            medicalAidStatus: medicalAidStatus,
            medicalAidName: medicalAidName,
            medicalAidNumber: medicalAidNumber,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MembersTable,
    MemberEntity,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (MemberEntity, BaseReferences<_$AppDatabase, $MembersTable, MemberEntity>),
    MemberEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
}
