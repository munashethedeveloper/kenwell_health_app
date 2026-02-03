import 'package:cloud_firestore/cloud_firestore.dart';

class UserEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    // Calculate date range for upcoming week and following week
    final now = DateTime.now();
    final startOfThisWeek = _startOfWeek(now);
    final endOfFollowingWeek = _endOfWeek(startOfThisWeek.add(const Duration(days: 7)));
    
    final snapshot = await _firestore
        .collection('user_events')
        .where('userId', isEqualTo: userId)
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfThisWeek))
        .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfFollowingWeek))
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Calculate the start of the week (Sunday) for a given date
  DateTime _startOfWeek(DateTime date) {
    final int daysToSubtract = date.weekday % 7;
    final dt = DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
    return DateTime(dt.year, dt.month, dt.day);
  }

  // Calculate the end of the week (Saturday) for a given week start date
  DateTime _endOfWeek(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 6));
    return DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
  }
}
