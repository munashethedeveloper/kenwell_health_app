import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class WellnessEventStatus {
  const WellnessEventStatus._();

  static const String scheduled = 'scheduled';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';

  static bool isValid(String value) =>
      value == scheduled || value == inProgress || value == completed;
}

class WellnessEvent {
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
  final String setUpTime;
  final String startTime;
  final String endTime;
  final String strikeDownTime;
  //final String medicalAidOption;
  final String medicalAid;
  final String mobileBooths;
  final String? description; // optional
  final String status;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final int screenedCount;

  WellnessEvent({
    String? id,
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
    required this.setUpTime,
    required this.startTime,
    required this.endTime,
    required this.strikeDownTime,
    //required this.medicalAidOption,
    required this.mobileBooths,
    this.description,
    required this.medicalAid,
    String status = WellnessEventStatus.scheduled,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    int screenedCount = 0,
  })  : id = id ?? const Uuid().v4(), // <-- auto-generate unique ID
        status = WellnessEventStatus.isValid(status)
            ? status
            : WellnessEventStatus.scheduled,
        actualStartTime = actualStartTime,
        actualEndTime = actualEndTime,
        screenedCount = screenedCount;

  /// Convenience getters to keep compatibility with previous single fields.
  String get onsiteContactPerson =>
      _joinNameParts(onsiteContactFirstName, onsiteContactLastName);

  String get aeContactPerson =>
      _joinNameParts(aeContactFirstName, aeContactLastName);

  DateTime? get startDateTime => _combineDateWithTime(startTime);

  DateTime? get endDateTime => _combineDateWithTime(endTime);

  DateTime? get setUpDateTime => _combineDateWithTime(setUpTime);

  /// Creates a copy of this event with the given fields replaced with new values
  WellnessEvent copyWith({
    String? id,
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
    String? setUpTime,
    String? startTime,
    String? endTime,
    String? strikeDownTime,
    String? mobileBooths,
    String? description,
    String? medicalAid,
    String? status,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    int? screenedCount,
  }) {
    return WellnessEvent(
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
      screenedCount: screenedCount ?? this.screenedCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WellnessEvent &&
        other.id == id &&
        other.title == title &&
        other.date == date &&
        other.venue == venue &&
        other.address == address &&
        other.onsiteContactFirstName == onsiteContactFirstName &&
        other.onsiteContactLastName == onsiteContactLastName &&
        other.onsiteContactNumber == onsiteContactNumber &&
        other.onsiteContactEmail == onsiteContactEmail &&
        other.aeContactFirstName == aeContactFirstName &&
        other.aeContactLastName == aeContactLastName &&
        other.aeContactNumber == aeContactNumber &&
        other.aeContactEmail == aeContactEmail &&
        other.servicesRequested == servicesRequested &&
        other.expectedParticipation == expectedParticipation &&
        other.nonMembers == nonMembers &&
        other.passports == passports &&
        other.nurses == nurses &&
        other.coordinators == coordinators &&
        other.multiplyPromoters == multiplyPromoters &&
        other.setUpTime == setUpTime &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.strikeDownTime == strikeDownTime &&
        other.mobileBooths == mobileBooths &&
        other.description == description &&
        other.medicalAid == medicalAid &&
        other.status == status &&
        other.actualStartTime == actualStartTime &&
        other.actualEndTime == actualEndTime &&
        other.screenedCount == screenedCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        date.hashCode ^
        venue.hashCode ^
        address.hashCode ^
        onsiteContactFirstName.hashCode ^
        onsiteContactLastName.hashCode ^
        onsiteContactNumber.hashCode ^
        onsiteContactEmail.hashCode ^
        aeContactFirstName.hashCode ^
        aeContactLastName.hashCode ^
        aeContactNumber.hashCode ^
        aeContactEmail.hashCode ^
        servicesRequested.hashCode ^
        expectedParticipation.hashCode ^
        nonMembers.hashCode ^
        passports.hashCode ^
        nurses.hashCode ^
        coordinators.hashCode ^
        multiplyPromoters.hashCode ^
        setUpTime.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        strikeDownTime.hashCode ^
        mobileBooths.hashCode ^
        description.hashCode ^
        medicalAid.hashCode ^
        status.hashCode ^
        actualStartTime.hashCode ^
        actualEndTime.hashCode ^
        screenedCount.hashCode;
  }

  static String _joinNameParts(String first, String last) {
    final trimmedFirst = first.trim();
    final trimmedLast = last.trim();
    if (trimmedFirst.isEmpty) {
      return trimmedLast;
    }
    if (trimmedLast.isEmpty) {
      return trimmedFirst;
    }
    return '$trimmedFirst $trimmedLast';
  }

  DateTime? _combineDateWithTime(String rawTime) {
    final trimmed = rawTime.trim();
    if (trimmed.isEmpty) return null;

    final formats = <DateFormat>[
      DateFormat.Hm(),
      DateFormat.jm(),
    ];

    for (final format in formats) {
      try {
        final parsed = format.parse(trimmed);
        return DateTime(
          date.year,
          date.month,
          date.day,
          parsed.hour,
          parsed.minute,
        );
      } catch (_) {
        continue;
      }
    }

    final match =
        RegExp(r'^(?<hour>\d{1,2}):(?<minute>\d{2})').firstMatch(trimmed);
    if (match != null) {
      final hour = int.tryParse(match.namedGroup('hour') ?? '');
      final minute = int.tryParse(match.namedGroup('minute') ?? '');
      if (hour != null && minute != null && hour < 24 && minute < 60) {
        return DateTime(date.year, date.month, date.day, hour, minute);
      }
    }

    return null;
  }
}
