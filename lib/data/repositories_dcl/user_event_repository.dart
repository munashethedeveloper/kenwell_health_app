import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserEventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches user events for the upcoming week and following week.
  /// 
  /// **IMPORTANT - Firestore Index Required:**
  /// This query requires a composite index on the 'user_events' collection.
  /// 
  /// Index configuration:
  /// - Collection: user_events
  /// - Fields: userId (Ascending), eventDate (Ascending)
  /// 
  /// **How to create the index:**
  /// 1. When you first run this query, Firestore will throw an error with a link
  /// 2. Click the link to open Firebase Console and create the index automatically
  /// 3. Wait 1-2 minutes for the index to finish building
  /// 4. Once built, the index is automatically used - no code changes needed!
  /// 
  /// **Troubleshooting:**
  /// - If you see "failed-precondition" error: Click the link to create the index
  /// - If error persists after creating: Wait a few minutes for the index to build
  /// - Check index status: Firebase Console > Firestore > Indexes tab
  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    try {
      // Calculate date range for upcoming week and following week
      final now = DateTime.now();
      final startOfThisWeek = _startOfWeek(now);
      final endOfFollowingWeek = _endOfWeek(startOfThisWeek.add(const Duration(days: 7)));
      
      if (kDebugMode) {
        debugPrint('UserEventRepository: Fetching events');
        debugPrint('UserEventRepository: Date range: $startOfThisWeek to $endOfFollowingWeek');
      }
      
      final snapshot = await _firestore
          .collection('user_events')
          .where('userId', isEqualTo: userId)
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfThisWeek))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfFollowingWeek))
          .get();
      
      if (kDebugMode) {
        debugPrint('UserEventRepository: Successfully fetched ${snapshot.docs.length} events');
      }
      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('UserEventRepository: Missing index detected!');
        debugPrint('UserEventRepository: Error message: ${e.message}');
        debugPrint('UserEventRepository: Please follow these steps:');
        debugPrint('1. Click the link in the error message to create the index');
        debugPrint('2. Wait 1-2 minutes for the index to build');
        debugPrint('3. Try again - the query will work automatically once index is ready');
      }
      rethrow;
    }
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
