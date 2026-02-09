import 'package:cloud_firestore/cloud_firestore.dart';

class UserEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    final snapshot = await _firestore
        .collection('user_events')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
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
