import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        debugPrint('UserEventRepository: - This could mean:');
        debugPrint(
            'UserEventRepository:   1. No events have been assigned to this user');
        debugPrint(
            'UserEventRepository:   2. userId mismatch between allocation and query');
        debugPrint('UserEventRepository:   3. Firestore permission issue');
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
      rethrow;
    }
  }

  /// Fetch all user IDs that have been assigned to a specific event
  Future<List<String>> fetchAssignedUserIds(String eventId) async {
    final snapshot = await _firestore
        .collection('user_events')
        .where('eventId', isEqualTo: eventId)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['userId'] as String?)
        .whereType<String>()
        .toList();
  }

  /// Remove a user's assignment from a specific event
  Future<void> removeUserEvent(String eventId, String userId) async {
    final snapshot = await _firestore
        .collection('user_events')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
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
