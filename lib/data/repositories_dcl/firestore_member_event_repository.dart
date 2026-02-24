import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/member_event.dart';

/// Repository for managing member-event participation records in Firestore.
/// Uses the `member_events` collection where each document tracks a member's
/// registration and screening participation for a specific wellness event.
class FirestoreMemberEventRepository {
  static const String memberEventsCollection = 'member_events';

  /// Generates a deterministic document ID for a member-event pair.
  String _docId(String memberId, String eventId) =>
      '${memberId}_$eventId';

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

      debugPrint('Added member event record: ${memberEvent.id}');
    } catch (e, stackTrace) {
      debugPrint('Error adding member event: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetch all event participation records for a specific member.
  Future<List<MemberEvent>> getMemberEventsByMemberId(
      String memberId) async {
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
  Future<MemberEvent?> getMemberEvent(
      String memberId, String eventId) async {
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
          updates['isScreened'] = nowScreened;

          if (nowScreened &&
              (existing['isScreened'] as bool? ?? false) == false) {
            updates['screenedAt'] = Timestamp.now();
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
}
