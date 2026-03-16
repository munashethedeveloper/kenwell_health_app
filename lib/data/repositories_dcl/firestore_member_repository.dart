import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../local/app_database.dart';
import '../../domain/models/member.dart';
import 'firestore_member_event_repository.dart';
import 'member_repository.dart';

/// Repository for managing members in Firestore.
///
/// ## Offline strategy
///
/// | Operation              | Online                                  | Offline                          |
/// |------------------------|-----------------------------------------|----------------------------------|
/// | `fetchAllMembers`      | Fetches Firestore, caches to local DB   | Returns cached local rows        |
/// | `fetchMemberByIdNumber`| Firestore first, falls back to local    | Returns cached row               |
/// | `fetchMemberByPassport`| Firestore first, falls back to local    | Returns cached row               |
/// | `fetchMemberById`      | Firestore first, falls back to local    | Returns cached row               |
/// | `addMember`            | Writes to Firestore, mirrors to local   | Throws                           |
/// | `updateMember`         | Writes to Firestore, mirrors to local   | Throws                           |
class FirestoreMemberRepository {
  final FirestoreService _firestore;
  final MemberRepository _localRepo;
  static const String membersCollection = 'members';
  final _memberEventRepository = FirestoreMemberEventRepository();

  FirestoreMemberRepository({
    FirestoreService? firestoreService,
    MemberRepository? localRepo,
  })  : _firestore = firestoreService ?? FirestoreService(),
        _localRepo = localRepo ?? MemberRepository(AppDatabase.instance);

  /// Fetch all members from Firestore and cache them locally.
  ///
  /// Falls back to the local Drift DB when Firestore is unreachable.
  Future<List<Member>> fetchAllMembers() async {
    try {
      final docs = await _firestore.getCollection(
        collection: membersCollection,
      );
      final members = docs.map(_mapToMember).toList();
      // Cache each member locally for offline access.
      for (final m in members) {
        try {
          await _localRepo.updateMember(m);
        } catch (_) {
          // If the member doesn't exist locally yet, create it.
          try {
            await _localRepo.createMember(m);
          } catch (cacheErr) {
            debugPrint(
                'FirestoreMemberRepository: cache write failed: $cacheErr');
          }
        }
      }
      return members;
    } catch (e, stackTrace) {
      debugPrint('Error fetching members from Firestore: $e');
      debugPrintStack(stackTrace: stackTrace);
      // Offline fallback — serve cached rows.
      try {
        final cached = await AppDatabase.instance.getAllMembers();
        if (cached.isNotEmpty) {
          debugPrint(
              'FirestoreMemberRepository: serving ${cached.length} cached members');
          return cached.map(_localRepo.entityToModelPublic).toList();
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// Fetch member by Firestore document ID, with local fallback.
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
      // Offline fallback.
      return _localRepo.getMemberById(id);
    }
  }

  /// Fetch member by SA ID number.
  ///
  /// Tries Firestore first; falls back to the local Drift cache if offline.
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
      debugPrint(
          'FirestoreMemberRepository: Firestore ID-number search failed ($e) — using local cache');
      return _localRepo.getMemberByIdNumber(idNumber);
    }
  }

  /// Fetch member by passport number.
  ///
  /// Tries Firestore first; falls back to the local Drift cache if offline.
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
      debugPrint(
          'FirestoreMemberRepository: Firestore passport search failed ($e) — using local cache');
      return _localRepo.getMemberByPassportNumber(passportNumber);
    }
  }

  /// Search members by name or surname (Firestore, with local fallback).
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
      // Fallback to local search.
      return _localRepo.searchMembers(query);
    }
  }

  /// Add new member to Firestore and mirror to local cache.
  Future<void> addMember(Member member) async {
    await _firestore.createDocument(
      collection: membersCollection,
      documentId: member.id,
      data: _mapToFirestore(member),
    );
    try {
      await _localRepo.createMember(member);
    } catch (_) {
      // Non-fatal — Firestore write succeeded.
    }
  }

  /// Update existing member in Firestore and mirror to local cache.
  Future<void> updateMember(Member member) async {
    await _firestore.updateDocument(
      collection: membersCollection,
      documentId: member.id,
      data: _mapToFirestore(member),
    );
    try {
      await _localRepo.updateMember(member);
    } catch (_) {
      // Non-fatal — Firestore write succeeded.
    }
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

  /// Fetch events attended by a member.
  /// Accepts the [Member] object directly to avoid a redundant Firestore read.
  /// Checks the `member_events` collection first, then falls back to
  /// `member.eventId` and `wellness_sessions` for backward compatibility.
  Future<List<Map<String, dynamic>>> fetchMemberEvents(Member member) async {
    final memberId = member.id;
    try {
      final events = <Map<String, dynamic>>[];

      // --- Primary source: member_events collection ---
      try {
        final memberEventRecords =
            await _memberEventRepository.getMemberEventsByMemberId(memberId);

        for (final record in memberEventRecords) {
          try {
            final eventDoc = await FirebaseFirestore.instance
                .collection(FirestoreService.eventsCollection)
                .doc(record.eventId)
                .get();

            final eventData = eventDoc.exists ? eventDoc.data() : null;
            events.add({
              'eventId': record.eventId,
              'eventTitle': eventData?['title'] ?? record.eventTitle,
              'eventDate': eventData?['date'] ?? record.eventDate,
              'eventVenue': eventData?['venue'] ?? record.eventVenue ?? '',
              'eventLocation':
                  eventData?['address'] ?? record.eventLocation ?? '',
              'source': 'member_events',
              'isScreened': record.isScreened,
              'hraCompleted': record.hraCompleted,
              'hctCompleted': record.hctCompleted,
              'tbCompleted': record.tbCompleted,
              'cancerCompleted': record.cancerCompleted,
              'registeredAt': record.registeredAt,
              'screenedAt': record.screenedAt,
            });
          } catch (e) {
            debugPrint('Error fetching event ${record.eventId}: $e');
            // Include record even if event doc fetch fails
            events.add({
              'eventId': record.eventId,
              'eventTitle': record.eventTitle,
              'eventDate': record.eventDate,
              'eventVenue': record.eventVenue ?? '',
              'eventLocation': record.eventLocation ?? '',
              'source': 'member_events',
              'isScreened': record.isScreened,
              'hraCompleted': record.hraCompleted,
              'hctCompleted': record.hctCompleted,
              'tbCompleted': record.tbCompleted,
              'cancerCompleted': record.cancerCompleted,
              'registeredAt': record.registeredAt,
              'screenedAt': record.screenedAt,
            });
          }
        }
      } catch (e) {
        debugPrint('Error querying member_events collection: $e');
      }

      // --- Fallback: member.eventId (backward compatibility) ---
      if (member.eventId != null && member.eventId!.isNotEmpty) {
        if (!events.any((e) => e['eventId'] == member.eventId)) {
          try {
            final eventDoc = await FirebaseFirestore.instance
                .collection(FirestoreService.eventsCollection)
                .doc(member.eventId)
                .get();

            if (eventDoc.exists) {
              final eventData = eventDoc.data();
              if (eventData != null) {
                events.add({
                  'eventId': eventDoc.id,
                  'eventTitle': eventData['title'] ?? 'Unknown Event',
                  'eventDate': eventData['date'],
                  'eventVenue': eventData['venue'] ?? '',
                  'eventLocation': eventData['address'] ?? '',
                  'source': 'registration',
                  'isScreened': false,
                });
              }
            }
          } catch (e) {
            debugPrint('Error fetching member registration event: $e');
          }
        }
      }

      // --- Fallback: wellness_sessions (backward compatibility) ---
      try {
        final sessionsQuery = await FirebaseFirestore.instance
            .collection('wellness_sessions')
            .where('memberDetails.id', isEqualTo: memberId)
            .get();

        for (var sessionDoc in sessionsQuery.docs) {
          final sessionData = sessionDoc.data();
          final eventId = sessionData['eventId'] as String?;

          if (eventId != null) {
            // Avoid duplicates
            if (!events.any((e) => e['eventId'] == eventId)) {
              try {
                final eventDoc = await FirebaseFirestore.instance
                    .collection(FirestoreService.eventsCollection)
                    .doc(eventId)
                    .get();

                if (eventDoc.exists) {
                  final eventData = eventDoc.data();
                  if (eventData != null) {
                    events.add({
                      'eventId': eventDoc.id,
                      'eventTitle': eventData['title'] ?? 'Unknown Event',
                      'eventDate': eventData['date'],
                      'eventVenue': eventData['venue'] ?? '',
                      'eventLocation': eventData['address'] ?? '',
                      'source': 'wellness_session',
                      'sessionId': sessionDoc.id,
                      'isScreened': true,
                    });
                  }
                }
              } catch (e) {
                debugPrint('Error fetching event for session: $e');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error querying wellness sessions: $e');
      }

      // Sort events by date (most recent first)
      events.sort((a, b) {
        final aDate = a['eventDate'];
        final bDate = b['eventDate'];
        if (aDate == null || bDate == null) return 0;

        try {
          final aTimestamp = aDate is Timestamp
              ? aDate.toDate()
              : DateTime.parse(aDate.toString());
          final bTimestamp = bDate is Timestamp
              ? bDate.toDate()
              : DateTime.parse(bDate.toString());
          return bTimestamp.compareTo(aTimestamp); // Most recent first
        } catch (e) {
          return 0;
        }
      });

      return events;
    } catch (e, stackTrace) {
      debugPrint('Error fetching member events: $e');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }
}
