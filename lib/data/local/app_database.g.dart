// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
      'venue', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _onsiteContactFirstNameMeta =
      const VerificationMeta('onsiteContactFirstName');
  @override
  late final GeneratedColumn<String> onsiteContactFirstName =
      GeneratedColumn<String>('onsite_contact_first_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _onsiteContactLastNameMeta =
      const VerificationMeta('onsiteContactLastName');
  @override
  late final GeneratedColumn<String> onsiteContactLastName =
      GeneratedColumn<String>('onsite_contact_last_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _onsiteContactNumberMeta =
      const VerificationMeta('onsiteContactNumber');
  @override
  late final GeneratedColumn<String> onsiteContactNumber =
      GeneratedColumn<String>('onsite_contact_number', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _onsiteContactEmailMeta =
      const VerificationMeta('onsiteContactEmail');
  @override
  late final GeneratedColumn<String> onsiteContactEmail =
      GeneratedColumn<String>('onsite_contact_email', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aeContactFirstNameMeta =
      const VerificationMeta('aeContactFirstName');
  @override
  late final GeneratedColumn<String> aeContactFirstName =
      GeneratedColumn<String>('ae_contact_first_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aeContactLastNameMeta =
      const VerificationMeta('aeContactLastName');
  @override
  late final GeneratedColumn<String> aeContactLastName =
      GeneratedColumn<String>('ae_contact_last_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aeContactNumberMeta =
      const VerificationMeta('aeContactNumber');
  @override
  late final GeneratedColumn<String> aeContactNumber = GeneratedColumn<String>(
      'ae_contact_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aeContactEmailMeta =
      const VerificationMeta('aeContactEmail');
  @override
  late final GeneratedColumn<String> aeContactEmail = GeneratedColumn<String>(
      'ae_contact_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _servicesRequestedMeta =
      const VerificationMeta('servicesRequested');
  @override
  late final GeneratedColumn<String> servicesRequested =
      GeneratedColumn<String>('services_requested', aliasedName, false,
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
  static const VerificationMeta _nonMembersMeta =
      const VerificationMeta('nonMembers');
  @override
  late final GeneratedColumn<int> nonMembers = GeneratedColumn<int>(
      'non_members', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _passportsMeta =
      const VerificationMeta('passports');
  @override
  late final GeneratedColumn<int> passports = GeneratedColumn<int>(
      'passports', aliasedName, false,
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
  static const VerificationMeta _multiplyPromotersMeta =
      const VerificationMeta('multiplyPromoters');
  @override
  late final GeneratedColumn<int> multiplyPromoters = GeneratedColumn<int>(
      'multiply_promoters', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _processedCountMeta =
      const VerificationMeta('processedCount');
  @override
  late final GeneratedColumn<int> processedCount = GeneratedColumn<int>(
      'processed_count', aliasedName, false,
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
      defaultValue: const Constant('No'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _medicalAidMeta =
      const VerificationMeta('medicalAid');
  @override
  late final GeneratedColumn<String> medicalAid = GeneratedColumn<String>(
      'medical_aid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('No'));
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        date,
        venue,
        address,
        onsiteContactFirstName,
        onsiteContactLastName,
        onsiteContactNumber,
        onsiteContactEmail,
        aeContactFirstName,
        aeContactLastName,
        aeContactNumber,
        aeContactEmail,
        servicesRequested,
        expectedParticipation,
        nonMembers,
        passports,
        nurses,
        coordinators,
        multiplyPromoters,
        processedCount,
        setUpTime,
        startTime,
        endTime,
        strikeDownTime,
        mobileBooths,
        description,
        medicalAid,
        status,
        actualStartTime,
        actualEndTime
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
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    } else if (isInserting) {
      context.missing(_venueMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('onsite_contact_first_name')) {
      context.handle(
          _onsiteContactFirstNameMeta,
          onsiteContactFirstName.isAcceptableOrUnknown(
              data['onsite_contact_first_name']!, _onsiteContactFirstNameMeta));
    } else if (isInserting) {
      context.missing(_onsiteContactFirstNameMeta);
    }
    if (data.containsKey('onsite_contact_last_name')) {
      context.handle(
          _onsiteContactLastNameMeta,
          onsiteContactLastName.isAcceptableOrUnknown(
              data['onsite_contact_last_name']!, _onsiteContactLastNameMeta));
    } else if (isInserting) {
      context.missing(_onsiteContactLastNameMeta);
    }
    if (data.containsKey('onsite_contact_number')) {
      context.handle(
          _onsiteContactNumberMeta,
          onsiteContactNumber.isAcceptableOrUnknown(
              data['onsite_contact_number']!, _onsiteContactNumberMeta));
    } else if (isInserting) {
      context.missing(_onsiteContactNumberMeta);
    }
    if (data.containsKey('onsite_contact_email')) {
      context.handle(
          _onsiteContactEmailMeta,
          onsiteContactEmail.isAcceptableOrUnknown(
              data['onsite_contact_email']!, _onsiteContactEmailMeta));
    } else if (isInserting) {
      context.missing(_onsiteContactEmailMeta);
    }
    if (data.containsKey('ae_contact_first_name')) {
      context.handle(
          _aeContactFirstNameMeta,
          aeContactFirstName.isAcceptableOrUnknown(
              data['ae_contact_first_name']!, _aeContactFirstNameMeta));
    } else if (isInserting) {
      context.missing(_aeContactFirstNameMeta);
    }
    if (data.containsKey('ae_contact_last_name')) {
      context.handle(
          _aeContactLastNameMeta,
          aeContactLastName.isAcceptableOrUnknown(
              data['ae_contact_last_name']!, _aeContactLastNameMeta));
    } else if (isInserting) {
      context.missing(_aeContactLastNameMeta);
    }
    if (data.containsKey('ae_contact_number')) {
      context.handle(
          _aeContactNumberMeta,
          aeContactNumber.isAcceptableOrUnknown(
              data['ae_contact_number']!, _aeContactNumberMeta));
    } else if (isInserting) {
      context.missing(_aeContactNumberMeta);
    }
    if (data.containsKey('ae_contact_email')) {
      context.handle(
          _aeContactEmailMeta,
          aeContactEmail.isAcceptableOrUnknown(
              data['ae_contact_email']!, _aeContactEmailMeta));
    } else if (isInserting) {
      context.missing(_aeContactEmailMeta);
    }
    if (data.containsKey('services_requested')) {
      context.handle(
          _servicesRequestedMeta,
          servicesRequested.isAcceptableOrUnknown(
              data['services_requested']!, _servicesRequestedMeta));
    }
    if (data.containsKey('expected_participation')) {
      context.handle(
          _expectedParticipationMeta,
          expectedParticipation.isAcceptableOrUnknown(
              data['expected_participation']!, _expectedParticipationMeta));
    }
    if (data.containsKey('non_members')) {
      context.handle(
          _nonMembersMeta,
          nonMembers.isAcceptableOrUnknown(
              data['non_members']!, _nonMembersMeta));
    }
    if (data.containsKey('passports')) {
      context.handle(_passportsMeta,
          passports.isAcceptableOrUnknown(data['passports']!, _passportsMeta));
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
    if (data.containsKey('multiply_promoters')) {
      context.handle(
          _multiplyPromotersMeta,
          multiplyPromoters.isAcceptableOrUnknown(
              data['multiply_promoters']!, _multiplyPromotersMeta));
    }
    if (data.containsKey('processed_count')) {
      context.handle(
          _processedCountMeta,
          processedCount.isAcceptableOrUnknown(
              data['processed_count']!, _processedCountMeta));
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
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('medical_aid')) {
      context.handle(
          _medicalAidMeta,
          medicalAid.isAcceptableOrUnknown(
              data['medical_aid']!, _medicalAidMeta));
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
      expectedParticipation: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}expected_participation'])!,
      nonMembers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}non_members'])!,
      passports: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}passports'])!,
      nurses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nurses'])!,
      coordinators: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}coordinators'])!,
      multiplyPromoters: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}multiply_promoters'])!,
      processedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}processed_count'])!,
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
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      medicalAid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medical_aid'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      actualStartTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}actual_start_time']),
      actualEndTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}actual_end_time']),
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
  final String onsiteContactFirstName;
  final String onsiteContactLastName;
  final String onsiteContactNumber;
  final String onsiteContactEmail;
  final String aeContactFirstName;
  final String aeContactLastName;
  final String aeContactNumber;
  final String aeContactEmail;
  final String servicesRequested;
  final int expectedParticipation;
  final int nonMembers;
  final int passports;
  final int nurses;
  final int coordinators;
  final int multiplyPromoters;
  final int processedCount;
  final String setUpTime;
  final String startTime;
  final String endTime;
  final String strikeDownTime;
  final String mobileBooths;
  final String? description;
  final String medicalAid;
  final String status;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  const EventEntity(
      {required this.id,
      required this.title,
      required this.date,
      required this.venue,
      required this.address,
      required this.onsiteContactFirstName,
      required this.onsiteContactLastName,
      required this.onsiteContactNumber,
      required this.onsiteContactEmail,
      required this.aeContactFirstName,
      required this.aeContactLastName,
      required this.aeContactNumber,
      required this.aeContactEmail,
      required this.servicesRequested,
      required this.expectedParticipation,
      required this.nonMembers,
      required this.passports,
      required this.nurses,
      required this.coordinators,
      required this.multiplyPromoters,
      required this.processedCount,
      required this.setUpTime,
      required this.startTime,
      required this.endTime,
      required this.strikeDownTime,
      required this.mobileBooths,
      this.description,
      required this.medicalAid,
      required this.status,
      this.actualStartTime,
      this.actualEndTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['venue'] = Variable<String>(venue);
    map['address'] = Variable<String>(address);
    map['onsite_contact_first_name'] = Variable<String>(onsiteContactFirstName);
    map['onsite_contact_last_name'] = Variable<String>(onsiteContactLastName);
    map['onsite_contact_number'] = Variable<String>(onsiteContactNumber);
    map['onsite_contact_email'] = Variable<String>(onsiteContactEmail);
    map['ae_contact_first_name'] = Variable<String>(aeContactFirstName);
    map['ae_contact_last_name'] = Variable<String>(aeContactLastName);
    map['ae_contact_number'] = Variable<String>(aeContactNumber);
    map['ae_contact_email'] = Variable<String>(aeContactEmail);
    map['services_requested'] = Variable<String>(servicesRequested);
    map['expected_participation'] = Variable<int>(expectedParticipation);
    map['non_members'] = Variable<int>(nonMembers);
    map['passports'] = Variable<int>(passports);
    map['nurses'] = Variable<int>(nurses);
    map['coordinators'] = Variable<int>(coordinators);
    map['multiply_promoters'] = Variable<int>(multiplyPromoters);
    map['processed_count'] = Variable<int>(processedCount);
    map['set_up_time'] = Variable<String>(setUpTime);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['strike_down_time'] = Variable<String>(strikeDownTime);
    map['mobile_booths'] = Variable<String>(mobileBooths);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['medical_aid'] = Variable<String>(medicalAid);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || actualStartTime != null) {
      map['actual_start_time'] = Variable<DateTime>(actualStartTime);
    }
    if (!nullToAbsent || actualEndTime != null) {
      map['actual_end_time'] = Variable<DateTime>(actualEndTime);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      venue: Value(venue),
      address: Value(address),
      onsiteContactFirstName: Value(onsiteContactFirstName),
      onsiteContactLastName: Value(onsiteContactLastName),
      onsiteContactNumber: Value(onsiteContactNumber),
      onsiteContactEmail: Value(onsiteContactEmail),
      aeContactFirstName: Value(aeContactFirstName),
      aeContactLastName: Value(aeContactLastName),
      aeContactNumber: Value(aeContactNumber),
      aeContactEmail: Value(aeContactEmail),
      servicesRequested: Value(servicesRequested),
      expectedParticipation: Value(expectedParticipation),
      nonMembers: Value(nonMembers),
      passports: Value(passports),
      nurses: Value(nurses),
      coordinators: Value(coordinators),
      multiplyPromoters: Value(multiplyPromoters),
      processedCount: Value(processedCount),
      setUpTime: Value(setUpTime),
      startTime: Value(startTime),
      endTime: Value(endTime),
      strikeDownTime: Value(strikeDownTime),
      mobileBooths: Value(mobileBooths),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      medicalAid: Value(medicalAid),
      status: Value(status),
      actualStartTime: actualStartTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualStartTime),
      actualEndTime: actualEndTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualEndTime),
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
      expectedParticipation:
          serializer.fromJson<int>(json['expectedParticipation']),
      nonMembers: serializer.fromJson<int>(json['nonMembers']),
      passports: serializer.fromJson<int>(json['passports']),
      nurses: serializer.fromJson<int>(json['nurses']),
      coordinators: serializer.fromJson<int>(json['coordinators']),
      multiplyPromoters: serializer.fromJson<int>(json['multiplyPromoters']),
      processedCount: serializer.fromJson<int>(json['processedCount']),
      setUpTime: serializer.fromJson<String>(json['setUpTime']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      strikeDownTime: serializer.fromJson<String>(json['strikeDownTime']),
      mobileBooths: serializer.fromJson<String>(json['mobileBooths']),
      description: serializer.fromJson<String?>(json['description']),
      medicalAid: serializer.fromJson<String>(json['medicalAid']),
      status: serializer.fromJson<String>(json['status']),
      actualStartTime: serializer.fromJson<DateTime?>(json['actualStartTime']),
      actualEndTime: serializer.fromJson<DateTime?>(json['actualEndTime']),
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
      'expectedParticipation': serializer.toJson<int>(expectedParticipation),
      'nonMembers': serializer.toJson<int>(nonMembers),
      'passports': serializer.toJson<int>(passports),
      'nurses': serializer.toJson<int>(nurses),
      'coordinators': serializer.toJson<int>(coordinators),
      'multiplyPromoters': serializer.toJson<int>(multiplyPromoters),
      'processedCount': serializer.toJson<int>(processedCount),
      'setUpTime': serializer.toJson<String>(setUpTime),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'strikeDownTime': serializer.toJson<String>(strikeDownTime),
      'mobileBooths': serializer.toJson<String>(mobileBooths),
      'description': serializer.toJson<String?>(description),
      'medicalAid': serializer.toJson<String>(medicalAid),
      'status': serializer.toJson<String>(status),
      'actualStartTime': serializer.toJson<DateTime?>(actualStartTime),
      'actualEndTime': serializer.toJson<DateTime?>(actualEndTime),
    };
  }

  EventEntity copyWith(
          {String? id,
          String? title,
          DateTime? date,
          String? venue,
          String? address,
          String? onsiteContactFirstName,
          String? onsiteContactLastName,
          String? onsiteContactNumber,
          String? onsiteContactEmail,
          String? aeContactFirstName,
          String? aeContactLastName,
          String? aeContactNumber,
          String? aeContactEmail,
          String? servicesRequested,
          int? expectedParticipation,
          int? nonMembers,
          int? passports,
          int? nurses,
          int? coordinators,
          int? multiplyPromoters,
          int? processedCount,
          String? setUpTime,
          String? startTime,
          String? endTime,
          String? strikeDownTime,
          String? mobileBooths,
          Value<String?> description = const Value.absent(),
          String? medicalAid,
          String? status,
          Value<DateTime?> actualStartTime = const Value.absent(),
          Value<DateTime?> actualEndTime = const Value.absent()}) =>
      EventEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        venue: venue ?? this.venue,
        address: address ?? this.address,
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
        expectedParticipation:
            expectedParticipation ?? this.expectedParticipation,
        nonMembers: nonMembers ?? this.nonMembers,
        passports: passports ?? this.passports,
        nurses: nurses ?? this.nurses,
        coordinators: coordinators ?? this.coordinators,
        multiplyPromoters: multiplyPromoters ?? this.multiplyPromoters,
        processedCount: processedCount ?? this.processedCount,
        setUpTime: setUpTime ?? this.setUpTime,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        strikeDownTime: strikeDownTime ?? this.strikeDownTime,
        mobileBooths: mobileBooths ?? this.mobileBooths,
        description: description.present ? description.value : this.description,
        medicalAid: medicalAid ?? this.medicalAid,
        status: status ?? this.status,
        actualStartTime: actualStartTime.present
            ? actualStartTime.value
            : this.actualStartTime,
        actualEndTime:
            actualEndTime.present ? actualEndTime.value : this.actualEndTime,
      );
  EventEntity copyWithCompanion(EventsCompanion data) {
    return EventEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      venue: data.venue.present ? data.venue.value : this.venue,
      address: data.address.present ? data.address.value : this.address,
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
      expectedParticipation: data.expectedParticipation.present
          ? data.expectedParticipation.value
          : this.expectedParticipation,
      nonMembers:
          data.nonMembers.present ? data.nonMembers.value : this.nonMembers,
      passports: data.passports.present ? data.passports.value : this.passports,
      nurses: data.nurses.present ? data.nurses.value : this.nurses,
      coordinators: data.coordinators.present
          ? data.coordinators.value
          : this.coordinators,
      multiplyPromoters: data.multiplyPromoters.present
          ? data.multiplyPromoters.value
          : this.multiplyPromoters,
      processedCount: data.processedCount.present
          ? data.processedCount.value
          : this.processedCount,
      setUpTime: data.setUpTime.present ? data.setUpTime.value : this.setUpTime,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      strikeDownTime: data.strikeDownTime.present
          ? data.strikeDownTime.value
          : this.strikeDownTime,
      mobileBooths: data.mobileBooths.present
          ? data.mobileBooths.value
          : this.mobileBooths,
      description:
          data.description.present ? data.description.value : this.description,
      medicalAid:
          data.medicalAid.present ? data.medicalAid.value : this.medicalAid,
      status: data.status.present ? data.status.value : this.status,
      actualStartTime: data.actualStartTime.present
          ? data.actualStartTime.value
          : this.actualStartTime,
      actualEndTime: data.actualEndTime.present
          ? data.actualEndTime.value
          : this.actualEndTime,
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
          ..write('onsiteContactFirstName: $onsiteContactFirstName, ')
          ..write('onsiteContactLastName: $onsiteContactLastName, ')
          ..write('onsiteContactNumber: $onsiteContactNumber, ')
          ..write('onsiteContactEmail: $onsiteContactEmail, ')
          ..write('aeContactFirstName: $aeContactFirstName, ')
          ..write('aeContactLastName: $aeContactLastName, ')
          ..write('aeContactNumber: $aeContactNumber, ')
          ..write('aeContactEmail: $aeContactEmail, ')
          ..write('servicesRequested: $servicesRequested, ')
          ..write('expectedParticipation: $expectedParticipation, ')
          ..write('nonMembers: $nonMembers, ')
          ..write('passports: $passports, ')
          ..write('nurses: $nurses, ')
          ..write('coordinators: $coordinators, ')
          ..write('multiplyPromoters: $multiplyPromoters, ')
          ..write('processedCount: $processedCount, ')
          ..write('setUpTime: $setUpTime, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('strikeDownTime: $strikeDownTime, ')
          ..write('mobileBooths: $mobileBooths, ')
          ..write('description: $description, ')
          ..write('medicalAid: $medicalAid, ')
          ..write('status: $status, ')
          ..write('actualStartTime: $actualStartTime, ')
          ..write('actualEndTime: $actualEndTime')
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
        onsiteContactFirstName,
        onsiteContactLastName,
        onsiteContactNumber,
        onsiteContactEmail,
        aeContactFirstName,
        aeContactLastName,
        aeContactNumber,
        aeContactEmail,
        servicesRequested,
        expectedParticipation,
        nonMembers,
        passports,
        nurses,
        coordinators,
        multiplyPromoters,
        processedCount,
        setUpTime,
        startTime,
        endTime,
        strikeDownTime,
        mobileBooths,
        description,
        medicalAid,
        status,
        actualStartTime,
        actualEndTime
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
          other.onsiteContactFirstName == this.onsiteContactFirstName &&
          other.onsiteContactLastName == this.onsiteContactLastName &&
          other.onsiteContactNumber == this.onsiteContactNumber &&
          other.onsiteContactEmail == this.onsiteContactEmail &&
          other.aeContactFirstName == this.aeContactFirstName &&
          other.aeContactLastName == this.aeContactLastName &&
          other.aeContactNumber == this.aeContactNumber &&
          other.aeContactEmail == this.aeContactEmail &&
          other.servicesRequested == this.servicesRequested &&
          other.expectedParticipation == this.expectedParticipation &&
          other.nonMembers == this.nonMembers &&
          other.passports == this.passports &&
          other.nurses == this.nurses &&
          other.coordinators == this.coordinators &&
          other.multiplyPromoters == this.multiplyPromoters &&
          other.processedCount == this.processedCount &&
          other.setUpTime == this.setUpTime &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.strikeDownTime == this.strikeDownTime &&
          other.mobileBooths == this.mobileBooths &&
          other.description == this.description &&
          other.medicalAid == this.medicalAid &&
          other.status == this.status &&
          other.actualStartTime == this.actualStartTime &&
          other.actualEndTime == this.actualEndTime);
}

class EventsCompanion extends UpdateCompanion<EventEntity> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String> venue;
  final Value<String> address;
  final Value<String> onsiteContactFirstName;
  final Value<String> onsiteContactLastName;
  final Value<String> onsiteContactNumber;
  final Value<String> onsiteContactEmail;
  final Value<String> aeContactFirstName;
  final Value<String> aeContactLastName;
  final Value<String> aeContactNumber;
  final Value<String> aeContactEmail;
  final Value<String> servicesRequested;
  final Value<int> expectedParticipation;
  final Value<int> nonMembers;
  final Value<int> passports;
  final Value<int> nurses;
  final Value<int> coordinators;
  final Value<int> multiplyPromoters;
  final Value<int> processedCount;
  final Value<String> setUpTime;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> strikeDownTime;
  final Value<String> mobileBooths;
  final Value<String?> description;
  final Value<String> medicalAid;
  final Value<String> status;
  final Value<DateTime?> actualStartTime;
  final Value<DateTime?> actualEndTime;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.venue = const Value.absent(),
    this.address = const Value.absent(),
    this.onsiteContactFirstName = const Value.absent(),
    this.onsiteContactLastName = const Value.absent(),
    this.onsiteContactNumber = const Value.absent(),
    this.onsiteContactEmail = const Value.absent(),
    this.aeContactFirstName = const Value.absent(),
    this.aeContactLastName = const Value.absent(),
    this.aeContactNumber = const Value.absent(),
    this.aeContactEmail = const Value.absent(),
    this.servicesRequested = const Value.absent(),
    this.expectedParticipation = const Value.absent(),
    this.nonMembers = const Value.absent(),
    this.passports = const Value.absent(),
    this.nurses = const Value.absent(),
    this.coordinators = const Value.absent(),
    this.multiplyPromoters = const Value.absent(),
    this.processedCount = const Value.absent(),
    this.setUpTime = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.strikeDownTime = const Value.absent(),
    this.mobileBooths = const Value.absent(),
    this.description = const Value.absent(),
    this.medicalAid = const Value.absent(),
    this.status = const Value.absent(),
    this.actualStartTime = const Value.absent(),
    this.actualEndTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String title,
    required DateTime date,
    required String venue,
    required String address,
    required String onsiteContactFirstName,
    required String onsiteContactLastName,
    required String onsiteContactNumber,
    required String onsiteContactEmail,
    required String aeContactFirstName,
    required String aeContactLastName,
    required String aeContactNumber,
    required String aeContactEmail,
    this.servicesRequested = const Value.absent(),
    this.expectedParticipation = const Value.absent(),
    this.nonMembers = const Value.absent(),
    this.passports = const Value.absent(),
    this.nurses = const Value.absent(),
    this.coordinators = const Value.absent(),
    this.multiplyPromoters = const Value.absent(),
    this.processedCount = const Value.absent(),
    this.setUpTime = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.strikeDownTime = const Value.absent(),
    this.mobileBooths = const Value.absent(),
    this.description = const Value.absent(),
    this.medicalAid = const Value.absent(),
    this.status = const Value.absent(),
    this.actualStartTime = const Value.absent(),
    this.actualEndTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        date = Value(date),
        venue = Value(venue),
        address = Value(address),
        onsiteContactFirstName = Value(onsiteContactFirstName),
        onsiteContactLastName = Value(onsiteContactLastName),
        onsiteContactNumber = Value(onsiteContactNumber),
        onsiteContactEmail = Value(onsiteContactEmail),
        aeContactFirstName = Value(aeContactFirstName),
        aeContactLastName = Value(aeContactLastName),
        aeContactNumber = Value(aeContactNumber),
        aeContactEmail = Value(aeContactEmail);
  static Insertable<EventEntity> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? venue,
    Expression<String>? address,
    Expression<String>? onsiteContactFirstName,
    Expression<String>? onsiteContactLastName,
    Expression<String>? onsiteContactNumber,
    Expression<String>? onsiteContactEmail,
    Expression<String>? aeContactFirstName,
    Expression<String>? aeContactLastName,
    Expression<String>? aeContactNumber,
    Expression<String>? aeContactEmail,
    Expression<String>? servicesRequested,
    Expression<int>? expectedParticipation,
    Expression<int>? nonMembers,
    Expression<int>? passports,
    Expression<int>? nurses,
    Expression<int>? coordinators,
    Expression<int>? multiplyPromoters,
    Expression<int>? processedCount,
    Expression<String>? setUpTime,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? strikeDownTime,
    Expression<String>? mobileBooths,
    Expression<String>? description,
    Expression<String>? medicalAid,
    Expression<String>? status,
    Expression<DateTime>? actualStartTime,
    Expression<DateTime>? actualEndTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (venue != null) 'venue': venue,
      if (address != null) 'address': address,
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
      if (expectedParticipation != null)
        'expected_participation': expectedParticipation,
      if (nonMembers != null) 'non_members': nonMembers,
      if (passports != null) 'passports': passports,
      if (nurses != null) 'nurses': nurses,
      if (coordinators != null) 'coordinators': coordinators,
      if (multiplyPromoters != null) 'multiply_promoters': multiplyPromoters,
      if (processedCount != null) 'processed_count': processedCount,
      if (setUpTime != null) 'set_up_time': setUpTime,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (strikeDownTime != null) 'strike_down_time': strikeDownTime,
      if (mobileBooths != null) 'mobile_booths': mobileBooths,
      if (description != null) 'description': description,
      if (medicalAid != null) 'medical_aid': medicalAid,
      if (status != null) 'status': status,
      if (actualStartTime != null) 'actual_start_time': actualStartTime,
      if (actualEndTime != null) 'actual_end_time': actualEndTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? date,
      Value<String>? venue,
      Value<String>? address,
      Value<String>? onsiteContactFirstName,
      Value<String>? onsiteContactLastName,
      Value<String>? onsiteContactNumber,
      Value<String>? onsiteContactEmail,
      Value<String>? aeContactFirstName,
      Value<String>? aeContactLastName,
      Value<String>? aeContactNumber,
      Value<String>? aeContactEmail,
      Value<String>? servicesRequested,
      Value<int>? expectedParticipation,
      Value<int>? nonMembers,
      Value<int>? passports,
      Value<int>? nurses,
      Value<int>? coordinators,
      Value<int>? multiplyPromoters,
      Value<int>? processedCount,
      Value<String>? setUpTime,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String>? strikeDownTime,
      Value<String>? mobileBooths,
      Value<String?>? description,
      Value<String>? medicalAid,
      Value<String>? status,
      Value<DateTime?>? actualStartTime,
      Value<DateTime?>? actualEndTime,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      address: address ?? this.address,
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
      expectedParticipation:
          expectedParticipation ?? this.expectedParticipation,
      nonMembers: nonMembers ?? this.nonMembers,
      passports: passports ?? this.passports,
      nurses: nurses ?? this.nurses,
      coordinators: coordinators ?? this.coordinators,
      multiplyPromoters: multiplyPromoters ?? this.multiplyPromoters,
      processedCount: processedCount ?? this.processedCount,
      setUpTime: setUpTime ?? this.setUpTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      strikeDownTime: strikeDownTime ?? this.strikeDownTime,
      mobileBooths: mobileBooths ?? this.mobileBooths,
      description: description ?? this.description,
      medicalAid: medicalAid ?? this.medicalAid,
      status: status ?? this.status,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
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
    if (expectedParticipation.present) {
      map['expected_participation'] =
          Variable<int>(expectedParticipation.value);
    }
    if (nonMembers.present) {
      map['non_members'] = Variable<int>(nonMembers.value);
    }
    if (passports.present) {
      map['passports'] = Variable<int>(passports.value);
    }
    if (nurses.present) {
      map['nurses'] = Variable<int>(nurses.value);
    }
    if (coordinators.present) {
      map['coordinators'] = Variable<int>(coordinators.value);
    }
    if (multiplyPromoters.present) {
      map['multiply_promoters'] = Variable<int>(multiplyPromoters.value);
    }
    if (processedCount.present) {
      map['processed_count'] = Variable<int>(processedCount.value);
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (medicalAid.present) {
      map['medical_aid'] = Variable<String>(medicalAid.value);
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
          ..write('onsiteContactFirstName: $onsiteContactFirstName, ')
          ..write('onsiteContactLastName: $onsiteContactLastName, ')
          ..write('onsiteContactNumber: $onsiteContactNumber, ')
          ..write('onsiteContactEmail: $onsiteContactEmail, ')
          ..write('aeContactFirstName: $aeContactFirstName, ')
          ..write('aeContactLastName: $aeContactLastName, ')
          ..write('aeContactNumber: $aeContactNumber, ')
          ..write('aeContactEmail: $aeContactEmail, ')
          ..write('servicesRequested: $servicesRequested, ')
          ..write('expectedParticipation: $expectedParticipation, ')
          ..write('nonMembers: $nonMembers, ')
          ..write('passports: $passports, ')
          ..write('nurses: $nurses, ')
          ..write('coordinators: $coordinators, ')
          ..write('multiplyPromoters: $multiplyPromoters, ')
          ..write('processedCount: $processedCount, ')
          ..write('setUpTime: $setUpTime, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('strikeDownTime: $strikeDownTime, ')
          ..write('mobileBooths: $mobileBooths, ')
          ..write('description: $description, ')
          ..write('medicalAid: $medicalAid, ')
          ..write('status: $status, ')
          ..write('actualStartTime: $actualStartTime, ')
          ..write('actualEndTime: $actualEndTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
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
        username,
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
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
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
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
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
  final String username;
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
      required this.username,
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
    map['username'] = Variable<String>(username);
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
      username: Value(username),
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
      username: serializer.fromJson<String>(json['username']),
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
      'username': serializer.toJson<String>(username),
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
          String? username,
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
        username: username ?? this.username,
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
      username: data.username.present ? data.username.value : this.username,
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
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, password, role, phoneNumber,
      username, firstName, lastName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == this.id &&
          other.email == this.email &&
          other.password == this.password &&
          other.role == this.role &&
          other.phoneNumber == this.phoneNumber &&
          other.username == this.username &&
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
  final Value<String> username;
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
    this.username = const Value.absent(),
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
    this.role = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.username = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        password = Value(password);
  static Insertable<UserEntity> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? role,
    Expression<String>? phoneNumber,
    Expression<String>? username,
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
      if (username != null) 'username': username,
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
      Value<String>? username,
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
      username: username ?? this.username,
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
    if (username.present) {
      map['username'] = Variable<String>(username.value);
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
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
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
  late final $EventsTable events = $EventsTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [events, users];
}

typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String title,
  required DateTime date,
  required String venue,
  required String address,
  required String onsiteContactFirstName,
  required String onsiteContactLastName,
  required String onsiteContactNumber,
  required String onsiteContactEmail,
  required String aeContactFirstName,
  required String aeContactLastName,
  required String aeContactNumber,
  required String aeContactEmail,
  Value<String> servicesRequested,
  Value<int> expectedParticipation,
  Value<int> nonMembers,
  Value<int> passports,
  Value<int> nurses,
  Value<int> coordinators,
  Value<int> multiplyPromoters,
  Value<int> processedCount,
  Value<String> setUpTime,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> strikeDownTime,
  Value<String> mobileBooths,
  Value<String?> description,
  Value<String> medicalAid,
  Value<String> status,
  Value<DateTime?> actualStartTime,
  Value<DateTime?> actualEndTime,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> date,
  Value<String> venue,
  Value<String> address,
  Value<String> onsiteContactFirstName,
  Value<String> onsiteContactLastName,
  Value<String> onsiteContactNumber,
  Value<String> onsiteContactEmail,
  Value<String> aeContactFirstName,
  Value<String> aeContactLastName,
  Value<String> aeContactNumber,
  Value<String> aeContactEmail,
  Value<String> servicesRequested,
  Value<int> expectedParticipation,
  Value<int> nonMembers,
  Value<int> passports,
  Value<int> nurses,
  Value<int> coordinators,
  Value<int> multiplyPromoters,
  Value<int> processedCount,
  Value<String> setUpTime,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> strikeDownTime,
  Value<String> mobileBooths,
  Value<String?> description,
  Value<String> medicalAid,
  Value<String> status,
  Value<DateTime?> actualStartTime,
  Value<DateTime?> actualEndTime,
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

  ColumnFilters<int> get expectedParticipation => $composableBuilder(
      column: $table.expectedParticipation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nonMembers => $composableBuilder(
      column: $table.nonMembers, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get passports => $composableBuilder(
      column: $table.passports, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nurses => $composableBuilder(
      column: $table.nurses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coordinators => $composableBuilder(
      column: $table.coordinators, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get multiplyPromoters => $composableBuilder(
      column: $table.multiplyPromoters,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get processedCount => $composableBuilder(
      column: $table.processedCount,
      builder: (column) => ColumnFilters(column));

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

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicalAid => $composableBuilder(
      column: $table.medicalAid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actualStartTime => $composableBuilder(
      column: $table.actualStartTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actualEndTime => $composableBuilder(
      column: $table.actualEndTime, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<int> get expectedParticipation => $composableBuilder(
      column: $table.expectedParticipation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nonMembers => $composableBuilder(
      column: $table.nonMembers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get passports => $composableBuilder(
      column: $table.passports, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nurses => $composableBuilder(
      column: $table.nurses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coordinators => $composableBuilder(
      column: $table.coordinators,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get multiplyPromoters => $composableBuilder(
      column: $table.multiplyPromoters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get processedCount => $composableBuilder(
      column: $table.processedCount,
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

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicalAid => $composableBuilder(
      column: $table.medicalAid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actualStartTime => $composableBuilder(
      column: $table.actualStartTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actualEndTime => $composableBuilder(
      column: $table.actualEndTime,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<int> get expectedParticipation => $composableBuilder(
      column: $table.expectedParticipation, builder: (column) => column);

  GeneratedColumn<int> get nonMembers => $composableBuilder(
      column: $table.nonMembers, builder: (column) => column);

  GeneratedColumn<int> get passports =>
      $composableBuilder(column: $table.passports, builder: (column) => column);

  GeneratedColumn<int> get nurses =>
      $composableBuilder(column: $table.nurses, builder: (column) => column);

  GeneratedColumn<int> get coordinators => $composableBuilder(
      column: $table.coordinators, builder: (column) => column);

  GeneratedColumn<int> get multiplyPromoters => $composableBuilder(
      column: $table.multiplyPromoters, builder: (column) => column);

  GeneratedColumn<int> get processedCount => $composableBuilder(
      column: $table.processedCount, builder: (column) => column);

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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get medicalAid => $composableBuilder(
      column: $table.medicalAid, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get actualStartTime => $composableBuilder(
      column: $table.actualStartTime, builder: (column) => column);

  GeneratedColumn<DateTime> get actualEndTime => $composableBuilder(
      column: $table.actualEndTime, builder: (column) => column);
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
            Value<String> onsiteContactFirstName = const Value.absent(),
            Value<String> onsiteContactLastName = const Value.absent(),
            Value<String> onsiteContactNumber = const Value.absent(),
            Value<String> onsiteContactEmail = const Value.absent(),
            Value<String> aeContactFirstName = const Value.absent(),
            Value<String> aeContactLastName = const Value.absent(),
            Value<String> aeContactNumber = const Value.absent(),
            Value<String> aeContactEmail = const Value.absent(),
            Value<String> servicesRequested = const Value.absent(),
            Value<int> expectedParticipation = const Value.absent(),
            Value<int> nonMembers = const Value.absent(),
            Value<int> passports = const Value.absent(),
            Value<int> nurses = const Value.absent(),
            Value<int> coordinators = const Value.absent(),
            Value<int> multiplyPromoters = const Value.absent(),
            Value<int> processedCount = const Value.absent(),
            Value<String> setUpTime = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> strikeDownTime = const Value.absent(),
            Value<String> mobileBooths = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> medicalAid = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> actualStartTime = const Value.absent(),
            Value<DateTime?> actualEndTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            title: title,
            date: date,
            venue: venue,
            address: address,
            onsiteContactFirstName: onsiteContactFirstName,
            onsiteContactLastName: onsiteContactLastName,
            onsiteContactNumber: onsiteContactNumber,
            onsiteContactEmail: onsiteContactEmail,
            aeContactFirstName: aeContactFirstName,
            aeContactLastName: aeContactLastName,
            aeContactNumber: aeContactNumber,
            aeContactEmail: aeContactEmail,
            servicesRequested: servicesRequested,
            expectedParticipation: expectedParticipation,
            nonMembers: nonMembers,
            passports: passports,
            nurses: nurses,
            coordinators: coordinators,
            multiplyPromoters: multiplyPromoters,
            processedCount: processedCount,
            setUpTime: setUpTime,
            startTime: startTime,
            endTime: endTime,
            strikeDownTime: strikeDownTime,
            mobileBooths: mobileBooths,
            description: description,
            medicalAid: medicalAid,
            status: status,
            actualStartTime: actualStartTime,
            actualEndTime: actualEndTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required DateTime date,
            required String venue,
            required String address,
            required String onsiteContactFirstName,
            required String onsiteContactLastName,
            required String onsiteContactNumber,
            required String onsiteContactEmail,
            required String aeContactFirstName,
            required String aeContactLastName,
            required String aeContactNumber,
            required String aeContactEmail,
            Value<String> servicesRequested = const Value.absent(),
            Value<int> expectedParticipation = const Value.absent(),
            Value<int> nonMembers = const Value.absent(),
            Value<int> passports = const Value.absent(),
            Value<int> nurses = const Value.absent(),
            Value<int> coordinators = const Value.absent(),
            Value<int> multiplyPromoters = const Value.absent(),
            Value<int> processedCount = const Value.absent(),
            Value<String> setUpTime = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> strikeDownTime = const Value.absent(),
            Value<String> mobileBooths = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> medicalAid = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> actualStartTime = const Value.absent(),
            Value<DateTime?> actualEndTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            title: title,
            date: date,
            venue: venue,
            address: address,
            onsiteContactFirstName: onsiteContactFirstName,
            onsiteContactLastName: onsiteContactLastName,
            onsiteContactNumber: onsiteContactNumber,
            onsiteContactEmail: onsiteContactEmail,
            aeContactFirstName: aeContactFirstName,
            aeContactLastName: aeContactLastName,
            aeContactNumber: aeContactNumber,
            aeContactEmail: aeContactEmail,
            servicesRequested: servicesRequested,
            expectedParticipation: expectedParticipation,
            nonMembers: nonMembers,
            passports: passports,
            nurses: nurses,
            coordinators: coordinators,
            multiplyPromoters: multiplyPromoters,
            processedCount: processedCount,
            setUpTime: setUpTime,
            startTime: startTime,
            endTime: endTime,
            strikeDownTime: strikeDownTime,
            mobileBooths: mobileBooths,
            description: description,
            medicalAid: medicalAid,
            status: status,
            actualStartTime: actualStartTime,
            actualEndTime: actualEndTime,
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
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String email,
  required String password,
  Value<String> role,
  Value<String> phoneNumber,
  Value<String> username,
  Value<String> firstName,
  Value<String> lastName,
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
  Value<String> username,
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

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

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
            Value<String> username = const Value.absent(),
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
            username: username,
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
            Value<String> role = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
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
            username: username,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
