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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $EventEntriesTable eventEntries =
      $EventEntriesTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [eventEntries];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [eventEntries];
}
