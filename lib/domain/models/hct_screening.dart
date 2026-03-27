class HctScreening {
  final String id;
  final String? memberId;
  final String? eventId;
  final String? firstHctTest;
  final String? lastTestMonth;
  final String? lastTestYear;
  final String? lastTestResult;
  final String? sharedNeedles;
  final String? unprotectedSex;
  final String? treatedSTI;
  final String? knowPartnerStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HctScreening({
    required this.id,
    this.memberId,
    this.eventId,
    this.firstHctTest,
    this.lastTestMonth,
    this.lastTestYear,
    this.lastTestResult,
    this.sharedNeedles,
    this.unprotectedSex,
    this.treatedSTI,
    this.knowPartnerStatus,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'eventId': eventId,
      'firstHctTest': firstHctTest,
      'lastTestMonth': lastTestMonth,
      'lastTestYear': lastTestYear,
      'lastTestResult': lastTestResult,
      'sharedNeedles': sharedNeedles,
      'unprotectedSex': unprotectedSex,
      'treatedSTI': treatedSTI,
      'knowPartnerStatus': knowPartnerStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory HctScreening.fromMap(Map<String, dynamic> map) {
    return HctScreening(
      id: map['id'] as String,
      memberId: map['memberId'] as String?,
      eventId: map['eventId'] as String?,
      firstHctTest: map['firstHctTest'] as String?,
      lastTestMonth: map['lastTestMonth'] as String?,
      lastTestYear: map['lastTestYear'] as String?,
      lastTestResult: map['lastTestResult'] as String?,
      sharedNeedles: map['sharedNeedles'] as String?,
      unprotectedSex: map['unprotectedSex'] as String?,
      treatedSTI: map['treatedSTI'] as String?,
      knowPartnerStatus: map['knowPartnerStatus'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  HctScreening copyWith({
    String? id,
    String? memberId,
    String? eventId,
    String? firstHctTest,
    String? lastTestMonth,
    String? lastTestYear,
    String? lastTestResult,
    String? sharedNeedles,
    String? unprotectedSex,
    String? treatedSTI,
    String? knowPartnerStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HctScreening(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      eventId: eventId ?? this.eventId,
      firstHctTest: firstHctTest ?? this.firstHctTest,
      lastTestMonth: lastTestMonth ?? this.lastTestMonth,
      lastTestYear: lastTestYear ?? this.lastTestYear,
      lastTestResult: lastTestResult ?? this.lastTestResult,
      sharedNeedles: sharedNeedles ?? this.sharedNeedles,
      unprotectedSex: unprotectedSex ?? this.unprotectedSex,
      treatedSTI: treatedSTI ?? this.treatedSTI,
      knowPartnerStatus: knowPartnerStatus ?? this.knowPartnerStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
