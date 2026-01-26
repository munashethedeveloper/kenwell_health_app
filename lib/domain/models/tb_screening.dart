class TbScreening {
  final String id;
  final String memberId;
  final String eventId;

  // TB Screening Questions
  final String? coughTwoWeeks;
  final String? bloodInSputum;
  final String? weightLoss;
  final String? nightSweats;

  // TB History
  final String? treatedBefore;
  final String? treatedDate;
  final String? completedTreatment;
  final String? contactWithTB;

  // Nurse Intervention Fields
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
  final String nurseFirstName;
  final String nurseLastName;
  final String rank;
  final String sancNumber;
  final String nurseDate;
  final String? signatureData; // Base64 encoded signature

  final DateTime createdAt;
  final DateTime updatedAt;

  TbScreening({
    required this.id,
    required this.memberId,
    required this.eventId,
    this.coughTwoWeeks,
    this.bloodInSputum,
    this.weightLoss,
    this.nightSweats,
    this.treatedBefore,
    this.treatedDate,
    this.completedTreatment,
    this.contactWithTB,
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
    required this.nurseFirstName,
    required this.nurseLastName,
    required this.rank,
    required this.sancNumber,
    required this.nurseDate,
    this.signatureData,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'eventId': eventId,
      'coughTwoWeeks': coughTwoWeeks,
      'bloodInSputum': bloodInSputum,
      'weightLoss': weightLoss,
      'nightSweats': nightSweats,
      'treatedBefore': treatedBefore,
      'treatedDate': treatedDate,
      'completedTreatment': completedTreatment,
      'contactWithTB': contactWithTB,
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
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TbScreening.fromMap(Map<String, dynamic> map) {
    return TbScreening(
      id: map['id'] as String,
      memberId: map['memberId'] as String,
      eventId: map['eventId'] as String,
      coughTwoWeeks: map['coughTwoWeeks'] as String?,
      bloodInSputum: map['bloodInSputum'] as String?,
      weightLoss: map['weightLoss'] as String?,
      nightSweats: map['nightSweats'] as String?,
      treatedBefore: map['treatedBefore'] as String?,
      treatedDate: map['treatedDate'] as String?,
      completedTreatment: map['completedTreatment'] as String?,
      contactWithTB: map['contactWithTB'] as String?,
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
      nurseFirstName: map['nurseFirstName'] as String,
      nurseLastName: map['nurseLastName'] as String,
      rank: map['rank'] as String,
      sancNumber: map['sancNumber'] as String,
      nurseDate: map['nurseDate'] as String,
      signatureData: map['signatureData'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  TbScreening copyWith({
    String? id,
    String? memberId,
    String? eventId,
    String? coughTwoWeeks,
    String? bloodInSputum,
    String? weightLoss,
    String? nightSweats,
    String? treatedBefore,
    String? treatedDate,
    String? completedTreatment,
    String? contactWithTB,
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
    return TbScreening(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      eventId: eventId ?? this.eventId,
      coughTwoWeeks: coughTwoWeeks ?? this.coughTwoWeeks,
      bloodInSputum: bloodInSputum ?? this.bloodInSputum,
      weightLoss: weightLoss ?? this.weightLoss,
      nightSweats: nightSweats ?? this.nightSweats,
      treatedBefore: treatedBefore ?? this.treatedBefore,
      treatedDate: treatedDate ?? this.treatedDate,
      completedTreatment: completedTreatment ?? this.completedTreatment,
      contactWithTB: contactWithTB ?? this.contactWithTB,
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
