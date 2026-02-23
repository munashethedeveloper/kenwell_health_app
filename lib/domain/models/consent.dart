class Consent {
  final String id;
  final String? memberId; // ID of the member who gave consent
  final String? eventId; // ID of the wellness event
  final String venue;
  final DateTime date;
  final String practitioner;
  final bool hra; // Health Risk Assessment
  final bool hiv; // HIV screening
  final bool tb; // TB screening
  final bool cancer; // Cancer screening
  final String? signatureData; // Base64 encoded signature image
  final DateTime createdAt;
  final DateTime? updatedAt;

  Consent({
    required this.id,
    this.memberId,
    this.eventId,
    required this.venue,
    required this.date,
    required this.practitioner,
    required this.hra,
    required this.hiv,
    required this.tb,
    this.cancer = false,
    this.signatureData,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'eventId': eventId,
      'venue': venue,
      'date': date.toIso8601String(),
      'practitioner': practitioner,
      'hra': hra,
      'hiv': hiv,
      'tb': tb,
      'cancer': cancer,
      'signatureData': signatureData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory Consent.fromMap(Map<String, dynamic> map) {
    return Consent(
      id: map['id'] as String,
      memberId: map['memberId'] as String?,
      eventId: map['eventId'] as String?,
      venue: map['venue'] as String,
      date: DateTime.parse(map['date'] as String),
      practitioner: map['practitioner'] as String,
      hra: map['hra'] as bool,
      hiv: map['hiv'] as bool,
      tb: map['tb'] as bool,
      cancer: (map['cancer'] as bool?) ?? false,
      signatureData: map['signatureData'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  // CopyWith method for updates
  Consent copyWith({
    String? id,
    String? memberId,
    String? eventId,
    String? venue,
    DateTime? date,
    String? practitioner,
    bool? hra,
    bool? hiv,
    bool? tb,
    bool? cancer,
    String? signatureData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Consent(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      eventId: eventId ?? this.eventId,
      venue: venue ?? this.venue,
      date: date ?? this.date,
      practitioner: practitioner ?? this.practitioner,
      hra: hra ?? this.hra,
      hiv: hiv ?? this.hiv,
      tb: tb ?? this.tb,
      cancer: cancer ?? this.cancer,
      signatureData: signatureData ?? this.signatureData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
