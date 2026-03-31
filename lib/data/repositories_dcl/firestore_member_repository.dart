import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/audit_log_service.dart';
import '../services/firestore_service.dart';
import '../services/pending_write_service.dart';
import '../local/app_database.dart';
import '../../domain/models/member.dart';
import '../../utils/field_encryption.dart';
import 'firestore_member_event_repository.dart';
import 'member_repository.dart';

/// Repository for managing members in Firestore.
///
/// ## Offline strategy
///
/// | Operation              | Online                                  | Offline                          |
/// |------------------------|-----------------------------------------|----------------------------------|
/// | `fetchAllMembers`      | Fetches Firestore, caches to local DB   | Returns cached local rows        |
/// | `fetchMemberByIdNumber`| In-memory search over fetchAllMembers   | Returns cached row               |
/// | `fetchMemberByPassport`| In-memory search over fetchAllMembers   | Returns cached row               |
/// | `fetchMemberById`      | Firestore first, falls back to local    | Returns cached row               |
/// | `addMember`            | Writes local first, then Firestore      | Saves locally + queues Firestore |
/// | `updateMember`         | Writes local first, then Firestore      | Saves locally + queues Firestore |
class FirestoreMemberRepository {
  final FirestoreService _firestore;
  final MemberRepository _localRepo;
  final AuditLogService _audit;
  static const String membersCollection = 'members';
  final _memberEventRepository = FirestoreMemberEventRepository();

  FirestoreMemberRepository({
    FirestoreService? firestoreService,
    MemberRepository? localRepo,
    AuditLogService? auditLogService,
  })  : _firestore = firestoreService ?? FirestoreService(),
        _localRepo = localRepo ?? MemberRepository(AppDatabase.instance),
        _audit = auditLogService ?? AuditLogService();

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
  /// Uses a two-step strategy:
  /// 1. **Local cache first** — the SQLite `members` table stores plain-text
  ///    idNumbers, so `WHERE id_number = ?` is fast and index-backed.  If the
  ///    member is found locally the result is returned immediately without a
  ///    network round-trip.
  /// 2. **Firestore full-scan fallback** — if the member is not yet cached
  ///    locally (e.g. first run or cache miss), all members are fetched from
  ///    Firestore, decrypted, and searched in memory.  Firestore equality
  ///    queries on the encrypted field are not usable because [FieldEncryption]
  ///    uses a random IV so the same plaintext produces a different ciphertext
  ///    on every call.
  Future<Member?> fetchMemberByIdNumber(String idNumber) async {
    // 1. Fast path: check the local SQLite cache first.
    try {
      final cached = await _localRepo.getMemberByIdNumber(idNumber);
      if (cached != null) return cached;
    } catch (localErr) {
      debugPrint(
          'FirestoreMemberRepository: local ID-number lookup failed ($localErr)');
    }

    // 2. Slow path: fetch all from Firestore (decrypts in _mapToMember) and
    //    search in memory.  This also refreshes the local cache as a side-effect.
    try {
      final allMembers = await fetchAllMembers();
      for (final m in allMembers) {
        if (m.idNumber == idNumber) return m;
      }
      return null;
    } catch (e) {
      debugPrint(
          'FirestoreMemberRepository: Firestore ID-number search failed ($e)');
      return null;
    }
  }

  /// Fetch member by passport number.
  ///
  /// Uses the same two-step strategy as [fetchMemberByIdNumber]:
  /// 1. Local SQLite indexed query (fast, no network).
  /// 2. Firestore full-scan with in-memory comparison on decrypted values.
  Future<Member?> fetchMemberByPassportNumber(String passportNumber) async {
    // 1. Fast path: check the local SQLite cache first.
    try {
      final cached = await _localRepo.getMemberByPassportNumber(passportNumber);
      if (cached != null) return cached;
    } catch (localErr) {
      debugPrint(
          'FirestoreMemberRepository: local passport lookup failed ($localErr)');
    }

    // 2. Slow path: fetch all from Firestore and search in memory.
    try {
      final allMembers = await fetchAllMembers();
      for (final m in allMembers) {
        if (m.passportNumber == passportNumber) return m;
      }
      return null;
    } catch (e) {
      debugPrint(
          'FirestoreMemberRepository: Firestore passport search failed ($e)');
      return null;
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

  /// Add new member — local-first, then Firestore with offline queue fallback.
  ///
  /// 1. Persists to local SQLite immediately so the member is available offline.
  /// 2. Attempts the Firestore write.  On failure the write is enqueued in
  ///    [PendingWriteService] for automatic retry when connectivity is restored.
  Future<void> addMember(Member member) async {
    // 1. Local write is always attempted first.
    try {
      await _localRepo.createMember(member);
    } catch (localErr) {
      debugPrint(
          'FirestoreMemberRepository: local cache write failed for addMember: $localErr');
    }

    // 2. Attempt Firestore; fall back to the pending queue on failure.
    final data = _mapToFirestore(member);
    try {
      await _firestore.createDocument(
        collection: membersCollection,
        documentId: member.id,
        data: data,
      );
      unawaited(_audit.logCreate(
        collection: membersCollection,
        documentId: member.id,
        data: data,
        summary: 'Registered member: ${member.name} ${member.surname}',
      ));
    } catch (e) {
      debugPrint(
          'FirestoreMemberRepository: Firestore addMember failed ($e) — queuing for retry');
      unawaited(PendingWriteService.instance.enqueue(
        collection: membersCollection,
        docId: member.id,
        data: data,
      ));
    }
  }

  /// Update existing member — local-first, then Firestore with offline queue fallback.
  ///
  /// 1. Persists to local SQLite immediately.
  /// 2. Attempts the Firestore write.  On failure the write is enqueued in
  ///    [PendingWriteService] for automatic retry when connectivity is restored.
  Future<void> updateMember(Member member) async {
    // 1. Local write is always attempted first.
    try {
      await _localRepo.updateMember(member);
    } catch (localErr) {
      debugPrint(
          'FirestoreMemberRepository: local cache write failed for updateMember: $localErr');
    }

    // 2. Attempt Firestore; fall back to the pending queue on failure.
    final data = _mapToFirestore(member);
    try {
      await _firestore.updateDocument(
        collection: membersCollection,
        documentId: member.id,
        data: data,
      );
      unawaited(_audit.logUpdate(
        collection: membersCollection,
        documentId: member.id,
        newData: data,
        summary: 'Updated member: ${member.name} ${member.surname}',
      ));
    } catch (e) {
      debugPrint(
          'FirestoreMemberRepository: Firestore updateMember failed ($e) — queuing for retry');
      unawaited(PendingWriteService.instance.enqueue(
        collection: membersCollection,
        docId: member.id,
        data: data,
      ));
    }
  }

  /// Delete member from Firestore
  Future<void> deleteMember(String id) async {
    await _firestore.deleteDocument(
      collection: membersCollection,
      documentId: id,
    );
    unawaited(_audit.logDelete(
      collection: membersCollection,
      documentId: id,
      summary: 'Deleted member: $id',
    ));
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
      idNumber: FieldEncryption.decrypt(data['idNumber'] as String?),
      passportNumber:
          FieldEncryption.decrypt(data['passportNumber'] as String?),
      idDocumentType: data['idDocumentType'] as String,
      dateOfBirth: FieldEncryption.decrypt(data['dateOfBirth'] as String?),
      gender: data['gender'] as String?,
      maritalStatus: data['maritalStatus'] as String?,
      nationality: data['nationality'] as String?,
      citizenshipStatus: data['citizenshipStatus'] as String?,
      email: data['email'] as String?,
      cellNumber: data['cellNumber'] as String?,
      medicalAidStatus: data['medicalAidStatus'] as String?,
      medicalAidName: data['medicalAidName'] as String?,
      medicalAidNumber:
          FieldEncryption.decrypt(data['medicalAidNumber'] as String?),
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
      'idNumber': FieldEncryption.encrypt(member.idNumber),
      'passportNumber': FieldEncryption.encrypt(member.passportNumber),
      'idDocumentType': member.idDocumentType,
      'dateOfBirth': FieldEncryption.encrypt(member.dateOfBirth),
      'gender': member.gender,
      'maritalStatus': member.maritalStatus,
      'nationality': member.nationality,
      'citizenshipStatus': member.citizenshipStatus,
      'email': member.email,
      'cellNumber': member.cellNumber,
      'medicalAidStatus': member.medicalAidStatus,
      'medicalAidName': member.medicalAidName,
      'medicalAidNumber': FieldEncryption.encrypt(member.medicalAidNumber),
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
