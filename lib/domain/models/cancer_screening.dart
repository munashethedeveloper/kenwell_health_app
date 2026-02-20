class CancerScreening {
  final String id;
  final String memberId;
  final String eventId;

  // Medical History
  final String? previousCancerDiagnosis;
  final String? familyHistoryOfCancer;
  final Map<String, bool> chronicConditions;
  final String? otherCondition;

  // Symptoms
  final String? breastLump;
  final String? abnormalBleeding;
  final String? urinaryDifficulty;
  final String? weightLoss;
  final String? persistentPain;

  // Breast Light Exam
  final String? breastLightExamFindings;

  // Liquid Cytology / Pap Smear
  final String? papSmearSpecimenCollected;
  final String? papSmearResults;

  // PSA
  final String? psaResults;

  // Outcome & Referral
  final String? referredFacility;
  final String? followUpDate;
  final String? consentObtained;
  final String? clinicianName;
  final String? clinicianSignature;
  final String? clinicianNotes;

  final DateTime createdAt;
  final DateTime updatedAt;

  CancerScreening({
    required this.id,
    required this.memberId,
    required this.eventId,
    this.previousCancerDiagnosis,
    this.familyHistoryOfCancer,
    this.chronicConditions = const {},
    this.otherCondition,
    this.breastLump,
    this.abnormalBleeding,
    this.urinaryDifficulty,
    this.weightLoss,
    this.persistentPain,
    this.breastLightExamFindings,
    this.papSmearSpecimenCollected,
    this.papSmearResults,
    this.psaResults,
    this.referredFacility,
    this.followUpDate,
    this.consentObtained,
    this.clinicianName,
    this.clinicianSignature,
    this.clinicianNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'eventId': eventId,
      'previousCancerDiagnosis': previousCancerDiagnosis,
      'familyHistoryOfCancer': familyHistoryOfCancer,
      'chronicConditions': chronicConditions,
      'otherCondition': otherCondition,
      'breastLump': breastLump,
      'abnormalBleeding': abnormalBleeding,
      'urinaryDifficulty': urinaryDifficulty,
      'weightLoss': weightLoss,
      'persistentPain': persistentPain,
      'breastLightExamFindings': breastLightExamFindings,
      'papSmearSpecimenCollected': papSmearSpecimenCollected,
      'papSmearResults': papSmearResults,
      'psaResults': psaResults,
      'referredFacility': referredFacility,
      'followUpDate': followUpDate,
      'consentObtained': consentObtained,
      'clinicianName': clinicianName,
      'clinicianSignature': clinicianSignature,
      'clinicianNotes': clinicianNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CancerScreening.fromMap(Map<String, dynamic> map) {
    return CancerScreening(
      id: map['id'] as String,
      memberId: map['memberId'] as String,
      eventId: map['eventId'] as String,
      previousCancerDiagnosis: map['previousCancerDiagnosis'] as String?,
      familyHistoryOfCancer: map['familyHistoryOfCancer'] as String?,
      chronicConditions: (map['chronicConditions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as bool)) ??
          {},
      otherCondition: map['otherCondition'] as String?,
      breastLump: map['breastLump'] as String?,
      abnormalBleeding: map['abnormalBleeding'] as String?,
      urinaryDifficulty: map['urinaryDifficulty'] as String?,
      weightLoss: map['weightLoss'] as String?,
      persistentPain: map['persistentPain'] as String?,
      breastLightExamFindings: map['breastLightExamFindings'] as String?,
      papSmearSpecimenCollected: map['papSmearSpecimenCollected'] as String?,
      papSmearResults: map['papSmearResults'] as String?,
      psaResults: map['psaResults'] as String?,
      referredFacility: map['referredFacility'] as String?,
      followUpDate: map['followUpDate'] as String?,
      consentObtained: map['consentObtained'] as String?,
      clinicianName: map['clinicianName'] as String?,
      clinicianSignature: map['clinicianSignature'] as String?,
      clinicianNotes: map['clinicianNotes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
