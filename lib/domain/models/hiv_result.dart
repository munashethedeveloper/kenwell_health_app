class HivResult {
  final String id;
  final String? memberId;
  final String? eventId;
  final String? screeningTestName;
  final String? screeningBatchNo;
  final String? screeningExpiryDate;
  final String? screeningResult;
  final String? windowPeriod;
  final String? expectedResult;
  final String? difficultyDealingResult;
  final String? urgentPsychosocial;
  final String? committedToChange;
  final String? followUpLocation;
  final String? followUpOther;
  final String? followUpDate;
  final String? nursingReferral;
  final String? notReferredReason;
  final String? nurseFirstName;
  final String? nurseLastName;
  final String? rank;
  final String? sancNumber;
  final String? nurseDate;
  final String? signatureData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HivResult({
    required this.id,
    this.memberId,
    this.eventId,
    this.screeningTestName,
    this.screeningBatchNo,
    this.screeningExpiryDate,
    this.screeningResult,
    this.windowPeriod,
    this.expectedResult,
    this.difficultyDealingResult,
    this.urgentPsychosocial,
    this.committedToChange,
    this.followUpLocation,
    this.followUpOther,
    this.followUpDate,
    this.nursingReferral,
    this.notReferredReason,
    this.nurseFirstName,
    this.nurseLastName,
    this.rank,
    this.sancNumber,
    this.nurseDate,
    this.signatureData,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'eventId': eventId,
      'screeningTestName': screeningTestName,
      'screeningBatchNo': screeningBatchNo,
      'screeningExpiryDate': screeningExpiryDate,
      'screeningResult': screeningResult,
      'windowPeriod': windowPeriod,
      'expectedResult': expectedResult,
      'difficultyDealingResult': difficultyDealingResult,
      'urgentPsychosocial': urgentPsychosocial,
      'committedToChange': committedToChange,
      'followUpLocation': followUpLocation,
      'followUpOther': followUpOther,
      'followUpDate': followUpDate,
      'nursingReferral': nursingReferral,
      'notReferredReason': notReferredReason,
      'nurseFirstName': nurseFirstName,
      'nurseLastName': nurseLastName,
      'rank': rank,
      'sancNumber': sancNumber,
      'nurseDate': nurseDate,
      'signatureData': signatureData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory HivResult.fromMap(Map<String, dynamic> map) {
    return HivResult(
      id: map['id'] as String,
      memberId: map['memberId'] as String?,
      eventId: map['eventId'] as String?,
      screeningTestName: map['screeningTestName'] as String?,
      screeningBatchNo: map['screeningBatchNo'] as String?,
      screeningExpiryDate: map['screeningExpiryDate'] as String?,
      screeningResult: map['screeningResult'] as String?,
      windowPeriod: map['windowPeriod'] as String?,
      expectedResult: map['expectedResult'] as String?,
      difficultyDealingResult: map['difficultyDealingResult'] as String?,
      urgentPsychosocial: map['urgentPsychosocial'] as String?,
      committedToChange: map['committedToChange'] as String?,
      followUpLocation: map['followUpLocation'] as String?,
      followUpOther: map['followUpOther'] as String?,
      followUpDate: map['followUpDate'] as String?,
      nursingReferral: map['nursingReferral'] as String?,
      notReferredReason: map['notReferredReason'] as String?,
      nurseFirstName: map['nurseFirstName'] as String?,
      nurseLastName: map['nurseLastName'] as String?,
      rank: map['rank'] as String?,
      sancNumber: map['sancNumber'] as String?,
      nurseDate: map['nurseDate'] as String?,
      signatureData: map['signatureData'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  HivResult copyWith({
    String? id,
    String? memberId,
    String? eventId,
    String? screeningTestName,
    String? screeningBatchNo,
    String? screeningExpiryDate,
    String? screeningResult,
    String? windowPeriod,
    String? expectedResult,
    String? difficultyDealingResult,
    String? urgentPsychosocial,
    String? committedToChange,
    String? followUpLocation,
    String? followUpOther,
    String? followUpDate,
    String? nursingReferral,
    String? notReferredReason,
    String? nurseFirstName,
    String? nurseLastName,
    String? rank,
    String? sancNumber,
    String? nurseDate,
    String? signatureData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HivResult(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      eventId: eventId ?? this.eventId,
      screeningTestName: screeningTestName ?? this.screeningTestName,
      screeningBatchNo: screeningBatchNo ?? this.screeningBatchNo,
      screeningExpiryDate: screeningExpiryDate ?? this.screeningExpiryDate,
      screeningResult: screeningResult ?? this.screeningResult,
      windowPeriod: windowPeriod ?? this.windowPeriod,
      expectedResult: expectedResult ?? this.expectedResult,
      difficultyDealingResult:
          difficultyDealingResult ?? this.difficultyDealingResult,
      urgentPsychosocial: urgentPsychosocial ?? this.urgentPsychosocial,
      committedToChange: committedToChange ?? this.committedToChange,
      followUpLocation: followUpLocation ?? this.followUpLocation,
      followUpOther: followUpOther ?? this.followUpOther,
      followUpDate: followUpDate ?? this.followUpDate,
      nursingReferral: nursingReferral ?? this.nursingReferral,
      notReferredReason: notReferredReason ?? this.notReferredReason,
      nurseFirstName: nurseFirstName ?? this.nurseFirstName,
      nurseLastName: nurseLastName ?? this.nurseLastName,
      rank: rank ?? this.rank,
      sancNumber: sancNumber ?? this.sancNumber,
      nurseDate: nurseDate ?? this.nurseDate,
      signatureData: signatureData ?? this.signatureData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
