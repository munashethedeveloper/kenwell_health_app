import 'package:cloud_firestore/cloud_firestore.dart';

class UserEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches user events for the upcoming week and following week.
  /// 
  /// Note: This query requires a composite index on the 'user_events' collection
  /// with fields 'userId' (ascending) and 'eventDate' (ascending).
  /// Firestore will automatically suggest creating this index when the query is first run.
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
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.subtract(Duration(days: daysToSubtract));
  }

  // Calculate the end of the week (Saturday) for a given week start date
  DateTime _endOfWeek(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 6));
    return DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
  }
}
