import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/member_event.dart';
import '../services/audit_log_service.dart';

/// Repository for managing member-event participation records in Firestore.
/// Uses the `member_events` collection where each document tracks a member's
/// registration and screening participation for a specific wellness event.
class FirestoreMemberEventRepository {
  static const String memberEventsCollection = 'member_events';

  final AuditLogService _audit;

  FirestoreMemberEventRepository({AuditLogService? auditLogService})
      : _audit = auditLogService ?? AuditLogService();

  /// Generates a deterministic document ID for a member-event pair.
  String _docId(String memberId, String eventId) => '${memberId}_$eventId';

  /// Add a new member-event registration record.
  /// If a record already exists for this member-event pair, it is not overwritten.
  Future<void> addMemberEvent(MemberEvent memberEvent) async {
    try {
      // The model id is already deterministic: {memberId}_{eventId}
      final ref = FirebaseFirestore.instance
          .collection(memberEventsCollection)
          .doc(memberEvent.id);

      // Only create if it doesn't already exist to avoid overwriting screening data
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) {
          transaction.set(ref, memberEvent.toMap());
        }
      });

      unawaited(_audit.logCreate(
        collection: memberEventsCollection,
        documentId: memberEvent.id,
        data: memberEvent.toMap(),
        summary:
            'Member ${memberEvent.memberId} registered for event ${memberEvent.eventId}',
      ));

      debugPrint('Added member event record: ${memberEvent.id}');
    } catch (e, stackTrace) {
      debugPrint('Error adding member event: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetch all event participation records for a specific member.
  Future<List<MemberEvent>> getMemberEventsByMemberId(String memberId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(memberEventsCollection)
          .where('memberId', isEqualTo: memberId)
          .get();

      return querySnapshot.docs
          .map((doc) => MemberEvent.fromMap(doc.id, doc.data()))
          .toList()
        ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    } catch (e) {
      debugPrint('Error fetching member events for $memberId: $e');
      return [];
    }
  }

  /// Fetch the member-event record for a specific member and event.
  Future<MemberEvent?> getMemberEvent(String memberId, String eventId) async {
    try {
      final docId = _docId(memberId, eventId);
      final doc = await FirebaseFirestore.instance
          .collection(memberEventsCollection)
          .doc(docId)
          .get();

      if (!doc.exists || doc.data() == null) return null;
      return MemberEvent.fromMap(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('Error fetching member event $memberId/$eventId: $e');
      return null;
    }
  }

  /// Update the screening completion status for a member-event record.
  /// Marks the member as screened if at least one screening is completed.
  ///
  /// When [isScreened] transitions from `false → true` for the first time the
  /// event's `screenedCount` field is atomically incremented by 1 via
  /// [FieldValue.increment], so the stats page stays consistent without
  /// requiring a separate call.
  Future<void> updateScreeningStatus(
    String memberId,
    String eventId, {
    bool? hraCompleted,
    bool? hctCompleted,
    bool? tbCompleted,
    bool? cancerCompleted,
  }) async {
    try {
      final docId = _docId(memberId, eventId);
      final ref = FirebaseFirestore.instance
          .collection(memberEventsCollection)
          .doc(docId);

      final updates = <String, dynamic>{};
      if (hraCompleted != null) updates['hraCompleted'] = hraCompleted;
      if (hctCompleted != null) updates['hctCompleted'] = hctCompleted;
      if (tbCompleted != null) updates['tbCompleted'] = tbCompleted;
      if (cancerCompleted != null) updates['cancerCompleted'] = cancerCompleted;

      if (updates.isNotEmpty) {
        // Determine if the member is now considered screened
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(ref);
          final existing =
              snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};

          final newHra =
              hraCompleted ?? existing['hraCompleted'] as bool? ?? false;
          final newHct =
              hctCompleted ?? existing['hctCompleted'] as bool? ?? false;
          final newTb =
              tbCompleted ?? existing['tbCompleted'] as bool? ?? false;
          final newCancer =
              cancerCompleted ?? existing['cancerCompleted'] as bool? ?? false;

          final nowScreened = newHra || newHct || newTb || newCancer;
          final wasScreened = existing['isScreened'] as bool? ?? false;
          updates['isScreened'] = nowScreened;

          if (nowScreened && !wasScreened) {
            updates['screenedAt'] = Timestamp.now();
            // Atomically increment the event's screened counter so that the
            // stats page immediately reflects the new member.  This is the
            // single source of truth for that transition – see also
            // [markSurveyCompleted] which applies the same guard.
            final eventRef = FirebaseFirestore.instance
                .collection('events')
                .doc(eventId);
            transaction.update(
                eventRef, {'screenedCount': FieldValue.increment(1)});
          }

          if (snapshot.exists) {
            transaction.update(ref, updates);
          } else {
            // Create minimal record if it doesn't exist yet
            transaction.set(ref, {
              'memberId': memberId,
              'eventId': eventId,
              'eventTitle': 'Unknown Event',
              'registeredAt': Timestamp.now(),
              ...updates,
            });
          }
        });

        debugPrint('Updated screening status for $docId: $updates');
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating screening status: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Mark the survey as completed for a member-event record.
  ///
  /// Sets `surveyCompleted = true` and `isScreened = true`.  Records
  /// `screenedAt` and atomically increments the event's `screenedCount` only
  /// when the member was **not** previously marked as screened (i.e. this is the
  /// first "screened" transition for this member/event pair).  This prevents
  /// double-counting for members who complete individual screenings (which
  /// already increment the counter via [updateScreeningStatus]) before the
  /// survey.
  Future<void> markSurveyCompleted(String memberId, String eventId) async {
    try {
      final docId = _docId(memberId, eventId);
      final ref = FirebaseFirestore.instance
          .collection(memberEventsCollection)
          .doc(docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        final existing =
            snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};
        final alreadyScreened = existing['isScreened'] as bool? ?? false;

        final updates = <String, dynamic>{
          'surveyCompleted': true,
          'isScreened': true,
        };
        if (!alreadyScreened) {
          updates['screenedAt'] = Timestamp.now();
          // First time this member is marked screened — increment the event
          // counter.  Members who completed individual screenings earlier will
          // have already triggered this increment via [updateScreeningStatus].
          final eventRef =
              FirebaseFirestore.instance.collection('events').doc(eventId);
          transaction.update(
              eventRef, {'screenedCount': FieldValue.increment(1)});
        }

        if (snapshot.exists) {
          transaction.update(ref, updates);
        } else {
          transaction.set(ref, {
            'id': docId,
            'memberId': memberId,
            'eventId': eventId,
            'eventTitle': 'Unknown Event',
            'registeredAt': Timestamp.now(),
            ...updates,
          });
        }
      });
      debugPrint('markSurveyCompleted: updated $docId');
    } catch (e, stackTrace) {
      debugPrint('Error marking survey completed for $memberId/$eventId: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Ensure a member-event record exists, creating one with full event details
  /// if it does not already exist. Used when an existing member is found via
  /// search and enters the wellness flow without going through registration.
  Future<void> ensureMemberEventExists({
    required String memberId,
    required String eventId,
    required String eventTitle,
    Timestamp? eventDate,
    String? eventVenue,
    String? eventLocation,
  }) async {
    try {
      final docId = _docId(memberId, eventId);
      final ref = FirebaseFirestore.instance
          .collection(memberEventsCollection)
          .doc(docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) {
          transaction.set(ref, {
            'id': docId,
            'memberId': memberId,
            'eventId': eventId,
            'eventTitle': eventTitle,
            'eventDate': eventDate,
            'eventVenue': eventVenue,
            'eventLocation': eventLocation,
            'isScreened': false,
            'hraCompleted': false,
            'hctCompleted': false,
            'tbCompleted': false,
            'cancerCompleted': false,
            'registeredAt': Timestamp.now(),
            'screenedAt': null,
          });
          debugPrint(
              'Created member_events record for existing member: $docId');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error ensuring member_events record: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
