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
  final String townCity;
  final String province;
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
  final String medicalAid;
  final String mobileBooths;
  final String? description;
  final String status;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;

  /// Number of survey submissions (screened participants)
  final int screenedCount;

  WellnessEvent({
    String? id,
    required this.title,
    required this.date,
    required this.venue,
    required this.address,
    required this.townCity,
    required this.province,
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
    this.description,
    required this.medicalAid,
    String status = WellnessEventStatus.scheduled,
    this.actualStartTime,
    this.actualEndTime,
    this.screenedCount = 0,
  })  : id = id ?? const Uuid().v4(),
        status = WellnessEventStatus.isValid(status)
            ? status
            : WellnessEventStatus.scheduled;

  /// Convenience getters
  String get onsiteContactPerson =>
      _joinNameParts(onsiteContactFirstName, onsiteContactLastName);

  String get aeContactPerson =>
      _joinNameParts(aeContactFirstName, aeContactLastName);

  DateTime? get startDateTime => _combineDateWithTime(startTime);
  DateTime? get endDateTime => _combineDateWithTime(endTime);
  DateTime? get setUpDateTime => _combineDateWithTime(setUpTime);
  DateTime? get strikeDownDateTime => _combineDateWithTime(strikeDownTime);

  WellnessEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? venue,
    String? address,
    String? townCity,
    String? province,
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
      townCity: townCity ?? this.townCity,
      address: address ?? this.address,
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
        other.townCity == townCity &&
        other.province == province &&
        other.onsiteContactFirstName == onsiteContactFirstName &&
        other.onsiteContactLastName == onsiteContactLastName &&
        other.onsiteContactNumber == onsiteContactNumber &&
        other.onsiteContactEmail == onsiteContactEmail &&
        other.aeContactFirstName == aeContactFirstName &&
        other.aeContactLastName == aeContactLastName &&
        other.aeContactNumber == aeContactNumber &&
        other.aeContactEmail == aeContactEmail &&
        other.servicesRequested == servicesRequested &&
        other.additionalServicesRequested == additionalServicesRequested &&
        other.expectedParticipation == expectedParticipation &&
        other.nurses == nurses &&
        other.coordinators == coordinators &&
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
        townCity.hashCode ^
        province.hashCode ^
        onsiteContactFirstName.hashCode ^
        onsiteContactLastName.hashCode ^
        onsiteContactNumber.hashCode ^
        onsiteContactEmail.hashCode ^
        aeContactFirstName.hashCode ^
        aeContactLastName.hashCode ^
        aeContactNumber.hashCode ^
        aeContactEmail.hashCode ^
        servicesRequested.hashCode ^
        additionalServicesRequested.hashCode ^
        expectedParticipation.hashCode ^
        nurses.hashCode ^
        coordinators.hashCode ^
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
    if (trimmedFirst.isEmpty) return trimmedLast;
    if (trimmedLast.isEmpty) return trimmedFirst;
    return '$trimmedFirst $trimmedLast';
  }

  DateTime? _combineDateWithTime(String rawTime) {
    final trimmed = rawTime.trim();
    if (trimmed.isEmpty) return null;

    final formats = <DateFormat>[DateFormat.Hm(), DateFormat.jm()];

    for (final format in formats) {
      try {
        final parsed = format.parse(trimmed);
        return DateTime(
            date.year, date.month, date.day, parsed.hour, parsed.minute);
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
