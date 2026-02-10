import 'package:cloud_firestore/cloud_firestore.dart';

class UserEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    print('UserEventRepository: Fetching events for userId: $userId');

    try {
      final snapshot = await _firestore
          .collection('user_events')
          .where('userId', isEqualTo: userId)
          .get();

      print('UserEventRepository: Query completed');
      print('UserEventRepository: - Found ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        print('UserEventRepository: ⚠️ No documents found for userId: $userId');
        print('UserEventRepository: - This could mean:');
        print(
            'UserEventRepository:   1. No events have been assigned to this user');
        print(
            'UserEventRepository:   2. userId mismatch between allocation and query');
        print('UserEventRepository:   3. Firestore permission issue');
      } else {
        print('UserEventRepository: ✅ Found documents:');
        for (var doc in snapshot.docs) {
          print('UserEventRepository: - Doc ID: ${doc.id}');
          print('UserEventRepository:   Data: ${doc.data()}');
        }
      }

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('UserEventRepository: ❌ ERROR fetching events: $e');
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
}
