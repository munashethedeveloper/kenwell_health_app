import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a member's registration and participation record for a wellness event.
/// Stored in the `member_events` Firestore collection.
/// The document ID is `{memberId}_{eventId}` (deterministic).
class MemberEvent {
  final String id;
  final String memberId;
  final String eventId;
  final String eventTitle;
  final dynamic eventDate;
  final String? eventVenue;
  final String? eventLocation;

  /// Whether the member was actually screened (completed at least one screening)
  /// as opposed to just being registered for the event.
  final bool isScreened;

  /// Individual screening completion flags
  final bool hraCompleted;
  final bool hctCompleted;
  final bool tbCompleted;
  final bool cancerCompleted;

  final DateTime registeredAt;
  final DateTime? screenedAt;

  MemberEvent({
    String? id,
    required this.memberId,
    required this.eventId,
    required this.eventTitle,
    this.eventDate,
    this.eventVenue,
    this.eventLocation,
    this.isScreened = false,
    this.hraCompleted = false,
    this.hctCompleted = false,
    this.tbCompleted = false,
    this.cancerCompleted = false,
    DateTime? registeredAt,
    this.screenedAt,
  })  : id = id ?? '${memberId}_$eventId',
        registeredAt = registeredAt ?? DateTime.now();

  MemberEvent copyWith({
    String? id,
    String? memberId,
    String? eventId,
    String? eventTitle,
    dynamic eventDate,
    String? eventVenue,
    String? eventLocation,
    bool? isScreened,
    bool? hraCompleted,
    bool? hctCompleted,
    bool? tbCompleted,
    bool? cancerCompleted,
    DateTime? registeredAt,
    DateTime? screenedAt,
  }) {
    return MemberEvent(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDate: eventDate ?? this.eventDate,
      eventVenue: eventVenue ?? this.eventVenue,
      eventLocation: eventLocation ?? this.eventLocation,
      isScreened: isScreened ?? this.isScreened,
      hraCompleted: hraCompleted ?? this.hraCompleted,
      hctCompleted: hctCompleted ?? this.hctCompleted,
      tbCompleted: tbCompleted ?? this.tbCompleted,
      cancerCompleted: cancerCompleted ?? this.cancerCompleted,
      registeredAt: registeredAt ?? this.registeredAt,
      screenedAt: screenedAt ?? this.screenedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventVenue': eventVenue,
      'eventLocation': eventLocation,
      'isScreened': isScreened,
      'hraCompleted': hraCompleted,
      'hctCompleted': hctCompleted,
      'tbCompleted': tbCompleted,
      'cancerCompleted': cancerCompleted,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'screenedAt': screenedAt != null ? Timestamp.fromDate(screenedAt!) : null,
    };
  }

  factory MemberEvent.fromMap(String id, Map<String, dynamic> data) {
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      // JSON-encoded form used by ScreeningLocalStore: {'_t':'ts','ms':<epochMs>}
      if (value is Map && value['_t'] == 'ts') {
        return DateTime.fromMillisecondsSinceEpoch(value['ms'] as int);
      }
      if (value is Map && value['_t'] == 'dt') {
        return DateTime.fromMillisecondsSinceEpoch(value['ms'] as int);
      }
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return MemberEvent(
      id: id,
      memberId: data['memberId'] as String,
      eventId: data['eventId'] as String,
      eventTitle: data['eventTitle'] as String? ?? 'Unknown Event',
      eventDate: data['eventDate'],
      eventVenue: data['eventVenue'] as String?,
      eventLocation: data['eventLocation'] as String?,
      isScreened: data['isScreened'] as bool? ?? false,
      hraCompleted: data['hraCompleted'] as bool? ?? false,
      hctCompleted: data['hctCompleted'] as bool? ?? false,
      tbCompleted: data['tbCompleted'] as bool? ?? false,
      cancerCompleted: data['cancerCompleted'] as bool? ?? false,
      registeredAt: data['registeredAt'] != null
          ? parseTimestamp(data['registeredAt'])
          : DateTime.now(),
      screenedAt: data['screenedAt'] != null
          ? parseTimestamp(data['screenedAt'])
          : null,
    );
  }
}
