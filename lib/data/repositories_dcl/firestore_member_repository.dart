import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../../domain/models/member.dart';

/// Repository for managing members in Firestore
class FirestoreMemberRepository {
  final FirestoreService _firestore;
  static const String membersCollection = 'members';

  FirestoreMemberRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  /// Fetch all members from Firestore
  Future<List<Member>> fetchAllMembers() async {
    try {
      final docs = await _firestore.getCollection(
        collection: membersCollection,
      );

      return docs.map(_mapToMember).toList();
    } catch (e, stackTrace) {
      debugPrint('Error fetching members from Firestore: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetch member by ID
  Future<Member?> fetchMemberById(String id) async {
    try {
      final data = await _firestore.getDocument(
        collection: membersCollection,
        documentId: id,
      );

      if (data == null) return null;

      return _mapToMember(data);
    } catch (e) {
      debugPrint('Error fetching member $id: $e');
      return null;
    }
  }

  /// Fetch member by ID number
  Future<Member?> fetchMemberByIdNumber(String idNumber) async {
    try {
      final docs = await _firestore.queryDocuments(
        collection: membersCollection,
        field: 'idNumber',
        isEqualTo: idNumber,
      );

      if (docs.isEmpty) return null;

      return _mapToMember(docs.first);
    } catch (e) {
      debugPrint('Error fetching member by ID number: $e');
      return null;
    }
  }

  /// Fetch member by passport number
  Future<Member?> fetchMemberByPassportNumber(String passportNumber) async {
    try {
      final docs = await _firestore.queryDocuments(
        collection: membersCollection,
        field: 'passportNumber',
        isEqualTo: passportNumber,
      );

      if (docs.isEmpty) return null;

      return _mapToMember(docs.first);
    } catch (e) {
      debugPrint('Error fetching member by passport number: $e');
      return null;
    }
  }

  /// Search members by name or surname
  Future<List<Member>> searchMembers(String query) async {
    try {
      final allMembers = await fetchAllMembers();
      final lowerQuery = query.toLowerCase();

      return allMembers.where((member) {
        final fullName = '${member.name} ${member.surname}'.toLowerCase();
        return fullName.contains(lowerQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching members: $e');
      return [];
    }
  }

  /// Add new member to Firestore
  Future<void> addMember(Member member) async {
    await _firestore.createDocument(
      collection: membersCollection,
      documentId: member.id,
      data: _mapToFirestore(member),
    );
  }

  /// Update existing member in Firestore
  Future<void> updateMember(Member member) async {
    await _firestore.updateDocument(
      collection: membersCollection,
      documentId: member.id,
      data: _mapToFirestore(member),
    );
  }

  /// Delete member from Firestore
  Future<void> deleteMember(String id) async {
    await _firestore.deleteDocument(
      collection: membersCollection,
      documentId: id,
    );
  }

  /// Stream members in real-time
  Stream<List<Member>> watchAllMembers() {
    return _firestore
        .streamCollection(collection: membersCollection)
        .map((docs) => docs.map(_mapToMember).toList());
  }

  /// Stream single member in real-time
  Stream<Member?> watchMember(String id) {
    return _firestore
        .streamDocument(
          collection: membersCollection,
          documentId: id,
        )
        .map((data) => data != null ? _mapToMember(data) : null);
  }

  /// Map Firestore document to Member
  Member _mapToMember(Map<String, dynamic> data) {
    return Member(
      id: data['id'] as String,
      name: data['name'] as String,
      surname: data['surname'] as String,
      idNumber: data['idNumber'] as String?,
      passportNumber: data['passportNumber'] as String?,
      idDocumentType: data['idDocumentType'] as String,
      dateOfBirth: data['dateOfBirth'] as String?,
      gender: data['gender'] as String?,
      maritalStatus: data['maritalStatus'] as String?,
      nationality: data['nationality'] as String?,
      citizenshipStatus: data['citizenshipStatus'] as String?,
      email: data['email'] as String?,
      cellNumber: data['cellNumber'] as String?,
      medicalAidStatus: data['medicalAidStatus'] as String?,
      medicalAidName: data['medicalAidName'] as String?,
      medicalAidNumber: data['medicalAidNumber'] as String?,
      eventId: data['eventId'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.parse(data['createdAt'] as String))
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(data['updatedAt'] as String))
          : DateTime.now(),
    );
  }

  /// Map Member to Firestore document
  Map<String, dynamic> _mapToFirestore(Member member) {
    return {
      'id': member.id,
      'name': member.name,
      'surname': member.surname,
      'idNumber': member.idNumber,
      'passportNumber': member.passportNumber,
      'idDocumentType': member.idDocumentType,
      'dateOfBirth': member.dateOfBirth,
      'gender': member.gender,
      'maritalStatus': member.maritalStatus,
      'nationality': member.nationality,
      'citizenshipStatus': member.citizenshipStatus,
      'email': member.email,
      'cellNumber': member.cellNumber,
      'medicalAidStatus': member.medicalAidStatus,
      'medicalAidName': member.medicalAidName,
      'medicalAidNumber': member.medicalAidNumber,
      'eventId': member.eventId,
      'createdAt': Timestamp.fromDate(member.createdAt),
      'updatedAt': Timestamp.fromDate(member.updatedAt),
    };
  }
}
