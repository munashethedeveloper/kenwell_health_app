import '../../domain/models/member.dart';
import '../local/app_database.dart';

class MemberRepository {
  final AppDatabase _db;

  MemberRepository(this._db);

  Future<Member?> getMemberByIdNumber(String idNumber) async {
    final entity = await _db.getMemberByIdNumber(idNumber);
    return entity != null ? _entityToModel(entity) : null;
  }

  Future<Member?> getMemberByPassportNumber(String passportNumber) async {
    final entity = await _db.getMemberByPassportNumber(passportNumber);
    return entity != null ? _entityToModel(entity) : null;
  }

  Future<Member?> getMemberById(String id) async {
    final entity = await _db.getMemberById(id);
    return entity != null ? _entityToModel(entity) : null;
  }

  Future<List<Member>> searchMembers(String query) async {
    final entities = await _db.searchMembers(query);
    return entities.map(_entityToModel).toList();
  }

  Future<Member> createMember(Member member) async {
    final entity = await _db.createMember(
      id: member.id,
      name: member.name,
      surname: member.surname,
      idNumber: member.idNumber,
      passportNumber: member.passportNumber,
      idDocumentType: member.idDocumentType,
      dateOfBirth: member.dateOfBirth,
      gender: member.gender,
      maritalStatus: member.maritalStatus,
      nationality: member.nationality,
      citizenshipStatus: member.citizenshipStatus,
      email: member.email,
      cellNumber: member.cellNumber,
      medicalAidStatus: member.medicalAidStatus,
      medicalAidName: member.medicalAidName,
      medicalAidNumber: member.medicalAidNumber,
    );
    return _entityToModel(entity);
  }

  Future<void> updateMember(Member member) async {
    final companion = MembersCompanion(
      id: Value(member.id),
      name: Value(member.name),
      surname: Value(member.surname),
      idNumber: Value(member.idNumber),
      passportNumber: Value(member.passportNumber),
      idDocumentType: Value(member.idDocumentType),
      dateOfBirth: Value(member.dateOfBirth),
      gender: Value(member.gender),
      maritalStatus: Value(member.maritalStatus),
      nationality: Value(member.nationality),
      citizenshipStatus: Value(member.citizenshipStatus),
      email: Value(member.email),
      cellNumber: Value(member.cellNumber),
      medicalAidStatus: Value(member.medicalAidStatus),
      medicalAidName: Value(member.medicalAidName),
      medicalAidNumber: Value(member.medicalAidNumber),
      updatedAt: Value(DateTime.now()),
    );
    await _db.upsertMember(companion);
  }

  Future<void> deleteMember(String id) async {
    await _db.deleteMemberById(id);
  }

  Member _entityToModel(MemberEntity entity) {
    return Member(
      id: entity.id,
      name: entity.name,
      surname: entity.surname,
      idNumber: entity.idNumber,
      passportNumber: entity.passportNumber,
      idDocumentType: entity.idDocumentType,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      maritalStatus: entity.maritalStatus,
      nationality: entity.nationality,
      citizenshipStatus: entity.citizenshipStatus,
      email: entity.email,
      cellNumber: entity.cellNumber,
      medicalAidStatus: entity.medicalAidStatus,
      medicalAidName: entity.medicalAidName,
      medicalAidNumber: entity.medicalAidNumber,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
