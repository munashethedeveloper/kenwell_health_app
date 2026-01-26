class HraScreening {
  final String id;
  final String? memberId;
  final String? eventId;
  final Map<String, bool> chronicConditions;
  final String? otherCondition;
  final String? exerciseFrequency;
  final String? dailySmoke;
  final String? smokeType;
  final String? alcoholFrequency;
  final String? papSmear;
  final String? breastExam;
  final String? mammogram;
  final String? prostateCheck;
  final String? prostateTested;
  final String? height;
  final String? weight;
  final String? bmi;
  final String? bloodPressureSystolic;
  final String? bloodPressureDiastolic;
  final String? cholesterol;
  final String? bloodSugar;
  final String? waist;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HraScreening({
    required this.id,
    this.memberId,
    this.eventId,
    required this.chronicConditions,
    this.otherCondition,
    this.exerciseFrequency,
    this.dailySmoke,
    this.smokeType,
    this.alcoholFrequency,
    this.papSmear,
    this.breastExam,
    this.mammogram,
    this.prostateCheck,
    this.prostateTested,
    this.height,
    this.weight,
    this.bmi,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.cholesterol,
    this.bloodSugar,
    this.waist,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'eventId': eventId,
      'chronicConditions': chronicConditions,
      'otherCondition': otherCondition,
      'exerciseFrequency': exerciseFrequency,
      'dailySmoke': dailySmoke,
      'smokeType': smokeType,
      'alcoholFrequency': alcoholFrequency,
      'papSmear': papSmear,
      'breastExam': breastExam,
      'mammogram': mammogram,
      'prostateCheck': prostateCheck,
      'prostateTested': prostateTested,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'cholesterol': cholesterol,
      'bloodSugar': bloodSugar,
      'waist': waist,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory HraScreening.fromMap(Map<String, dynamic> map) {
    return HraScreening(
      id: map['id'] as String,
      memberId: map['memberId'] as String?,
      eventId: map['eventId'] as String?,
      chronicConditions:
          Map<String, bool>.from(map['chronicConditions'] as Map),
      otherCondition: map['otherCondition'] as String?,
      exerciseFrequency: map['exerciseFrequency'] as String?,
      dailySmoke: map['dailySmoke'] as String?,
      smokeType: map['smokeType'] as String?,
      alcoholFrequency: map['alcoholFrequency'] as String?,
      papSmear: map['papSmear'] as String?,
      breastExam: map['breastExam'] as String?,
      mammogram: map['mammogram'] as String?,
      prostateCheck: map['prostateCheck'] as String?,
      prostateTested: map['prostateTested'] as String?,
      height: map['height'] as String?,
      weight: map['weight'] as String?,
      bmi: map['bmi'] as String?,
      bloodPressureSystolic: map['bloodPressureSystolic'] as String?,
      bloodPressureDiastolic: map['bloodPressureDiastolic'] as String?,
      cholesterol: map['cholesterol'] as String?,
      bloodSugar: map['bloodSugar'] as String?,
      waist: map['waist'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  HraScreening copyWith({
    String? id,
    String? memberId,
    String? eventId,
    Map<String, bool>? chronicConditions,
    String? otherCondition,
    String? exerciseFrequency,
    String? dailySmoke,
    String? smokeType,
    String? alcoholFrequency,
    String? papSmear,
    String? breastExam,
    String? mammogram,
    String? prostateCheck,
    String? prostateTested,
    String? height,
    String? weight,
    String? bmi,
    String? bloodPressureSystolic,
    String? bloodPressureDiastolic,
    String? cholesterol,
    String? bloodSugar,
    String? waist,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HraScreening(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      eventId: eventId ?? this.eventId,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      otherCondition: otherCondition ?? this.otherCondition,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      dailySmoke: dailySmoke ?? this.dailySmoke,
      smokeType: smokeType ?? this.smokeType,
      alcoholFrequency: alcoholFrequency ?? this.alcoholFrequency,
      papSmear: papSmear ?? this.papSmear,
      breastExam: breastExam ?? this.breastExam,
      mammogram: mammogram ?? this.mammogram,
      prostateCheck: prostateCheck ?? this.prostateCheck,
      prostateTested: prostateTested ?? this.prostateTested,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      cholesterol: cholesterol ?? this.cholesterol,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      waist: waist ?? this.waist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
