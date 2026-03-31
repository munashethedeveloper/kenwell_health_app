import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/audit_log_service.dart';
import '../services/pending_write_service.dart';

class UserEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _audit;

  UserEventRepository({AuditLogService? auditLogService})
      : _audit = auditLogService ?? AuditLogService();

  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    debugPrint('UserEventRepository: Fetching events for userId: $userId');

    try {
      final snapshot = await _firestore
          .collection('user_events')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('UserEventRepository: Query completed');
      debugPrint(
          'UserEventRepository: - Found ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        debugPrint(
            'UserEventRepository: ⚠️ No documents found for userId: $userId');
      } else {
        debugPrint('UserEventRepository: ✅ Found documents:');
        for (var doc in snapshot.docs) {
          debugPrint('UserEventRepository: - Doc ID: ${doc.id}');
          debugPrint('UserEventRepository:   Data: ${doc.data()}');
        }
      }

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('UserEventRepository: ❌ ERROR fetching events: $e');
      // Offline fallback: serve from Firestore's local on-device cache.
      try {
        final cached = await _firestore
            .collection('user_events')
            .where('userId', isEqualTo: userId)
            .get(const GetOptions(source: Source.cache));
        debugPrint(
            'UserEventRepository: Serving ${cached.docs.length} cached user-events');
        return cached.docs.map((doc) => doc.data()).toList();
      } catch (_) {}
      rethrow;
    }
  }

  /// Fetch all user IDs that have been assigned to a specific event
  Future<List<String>> fetchAssignedUserIds(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('user_events')
          .where('eventId', isEqualTo: eventId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .whereType<String>()
          .toList();
    } catch (e) {
      // Offline fallback: serve from Firestore's local on-device cache.
      try {
        final cached = await _firestore
            .collection('user_events')
            .where('eventId', isEqualTo: eventId)
            .get(const GetOptions(source: Source.cache));
        return cached.docs
            .map((doc) => doc.data()['userId'] as String?)
            .whereType<String>()
            .toList();
      } catch (_) {}
      rethrow;
    }
  }

  /// Remove a user's assignment from a specific event.
  ///
  /// Uses the deterministic composite document ID (`{eventId}_{userId}`) that
  /// [UserEventService.addUserEvent] now creates, avoiding a round-trip query.
  ///
  /// **Offline**: Queues the delete in [PendingWriteService] for retry on
  /// reconnect so the un-assignment is not lost.
  Future<void> removeUserEvent(String eventId, String userId) async {
    final docId = '${eventId}_$userId';
    try {
      await _firestore.collection('user_events').doc(docId).delete();
      unawaited(_audit.logDelete(
        collection: 'user_events',
        documentId: docId,
        summary: 'Removed user $userId from event $eventId',
      ));
    } catch (e) {
      debugPrint(
          'UserEventRepository: Firestore removeUserEvent failed ($e) — queuing delete for retry');
      unawaited(PendingWriteService.instance.enqueueDelete(
        collection: 'user_events',
        docId: docId,
      ));
      // Also attempt to remove legacy auto-ID documents (created before the
      // deterministic-ID change) by falling back to a query-based batch delete.
      try {
        final snapshot = await _firestore
            .collection('user_events')
            .where('eventId', isEqualTo: eventId)
            .where('userId', isEqualTo: userId)
            .get(const GetOptions(source: Source.cache));
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          if (doc.id != docId) batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (_) {
        // Best-effort legacy cleanup; the deterministic doc is already queued.
      }
    }
  }

  /// Returns a real-time stream of user-event mapping documents for [userId].
  ///
  /// Each emission contains the raw document data maps. The stream never
  /// completes until the caller cancels. Errors are logged and the stream
  /// continues (yielding an empty list).
  Stream<List<Map<String, dynamic>>> watchUserEvents(String userId) {
    return _firestore
        .collection('user_events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
        .handleError((Object err) {
      debugPrint('UserEventRepository.watchUserEvents: error – $err');
      return <Map<String, dynamic>>[];
    });
  }
}
