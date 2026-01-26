import 'package:uuid/uuid.dart';

class Member {
  final String id;
  final String name;
  final String surname;
  final String? idNumber;
  final String? passportNumber;
  final String idDocumentType; // 'ID' or 'Passport'
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? nationality;
  final String? citizenshipStatus;
  final String? email;
  final String? cellNumber;
  final String? medicalAidStatus;
  final String? medicalAidName;
  final String? medicalAidNumber;
  final String? eventId; // ID of the event this member was registered for
  final DateTime createdAt;
  final DateTime updatedAt;

  Member({
    String? id,
    required this.name,
    required this.surname,
    this.idNumber,
    this.passportNumber,
    required this.idDocumentType,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.nationality,
    this.citizenshipStatus,
    this.email,
    this.cellNumber,
    this.medicalAidStatus,
    this.medicalAidName,
    this.medicalAidNumber,
    this.eventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Member copyWith({
    String? id,
    String? name,
    String? surname,
    String? idNumber,
    String? passportNumber,
    String? idDocumentType,
    String? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? nationality,
    String? citizenshipStatus,
    String? email,
    String? cellNumber,
    String? medicalAidStatus,
    String? medicalAidName,
    String? medicalAidNumber,
    String? eventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      idNumber: idNumber ?? this.idNumber,
      passportNumber: passportNumber ?? this.passportNumber,
      idDocumentType: idDocumentType ?? this.idDocumentType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nationality: nationality ?? this.nationality,
      citizenshipStatus: citizenshipStatus ?? this.citizenshipStatus,
      email: email ?? this.email,
      cellNumber: cellNumber ?? this.cellNumber,
      medicalAidStatus: medicalAidStatus ?? this.medicalAidStatus,
      medicalAidName: medicalAidName ?? this.medicalAidName,
      medicalAidNumber: medicalAidNumber ?? this.medicalAidNumber,
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'idNumber': idNumber,
      'passportNumber': passportNumber,
      'idDocumentType': idDocumentType,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'citizenshipStatus': citizenshipStatus,
      'email': email,
      'cellNumber': cellNumber,
      'medicalAidStatus': medicalAidStatus,
      'medicalAidName': medicalAidName,
      'medicalAidNumber': medicalAidNumber,
      'eventId': eventId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      idNumber: map['idNumber'] as String?,
      passportNumber: map['passportNumber'] as String?,
      idDocumentType: map['idDocumentType'] as String,
      dateOfBirth: map['dateOfBirth'] as String?,
      gender: map['gender'] as String?,
      maritalStatus: map['maritalStatus'] as String?,
      nationality: map['nationality'] as String?,
      citizenshipStatus: map['citizenshipStatus'] as String?,
      email: map['email'] as String?,
      cellNumber: map['cellNumber'] as String?,
      medicalAidStatus: map['medicalAidStatus'] as String?,
      medicalAidName: map['medicalAidName'] as String?,
      medicalAidNumber: map['medicalAidNumber'] as String?,
      eventId: map['eventId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Member &&
        other.id == id &&
        other.name == name &&
        other.surname == surname &&
        other.idNumber == idNumber &&
        other.passportNumber == passportNumber &&
        other.idDocumentType == idDocumentType &&
        other.dateOfBirth == dateOfBirth &&
        other.gender == gender &&
        other.maritalStatus == maritalStatus &&
        other.nationality == nationality &&
        other.citizenshipStatus == citizenshipStatus &&
        other.email == email &&
        other.cellNumber == cellNumber &&
        other.medicalAidStatus == medicalAidStatus &&
        other.medicalAidName == medicalAidName &&
        other.medicalAidNumber == medicalAidNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        surname.hashCode ^
        (idNumber?.hashCode ?? 0) ^
        (passportNumber?.hashCode ?? 0) ^
        idDocumentType.hashCode;
  }
}
