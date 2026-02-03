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
      
      debugPrint('=== UserEventRepository: fetchUserEvents ===');
      debugPrint('UserEventRepository: Current time: $now');
      debugPrint('UserEventRepository: UserId: $userId');
      debugPrint('UserEventRepository: Date range: $startOfThisWeek to $endOfFollowingWeek');
      debugPrint('UserEventRepository: Week calculation:');
      debugPrint('  - Start of this week (Sunday): $startOfThisWeek');
      debugPrint('  - End of next week (Saturday): $endOfFollowingWeek');
      debugPrint('  - Total days in range: ${endOfFollowingWeek.difference(startOfThisWeek).inDays}');
      
      // First, check if ANY events exist for this user (for debugging)
      debugPrint('UserEventRepository: Checking for any events for this user...');
      final allUserEvents = await _firestore
          .collection('user_events')
          .where('userId', isEqualTo: userId)
          .get();
      
      debugPrint('UserEventRepository: Total events for user (no date filter): ${allUserEvents.docs.length}');
      if (allUserEvents.docs.isNotEmpty) {
        debugPrint('UserEventRepository: Sample events (showing all):');
        for (var doc in allUserEvents.docs) {
          final data = doc.data();
          final eventDate = data['eventDate'];
          DateTime? parsedDate;
          if (eventDate is Timestamp) {
            parsedDate = eventDate.toDate();
          }
          debugPrint('  - ${data['eventTitle']} | Date: $parsedDate (raw: $eventDate) | UserId: ${data['userId']}');
        }
      }
      
      // Now query with date range
      final snapshot = await _firestore
          .collection('user_events')
          .where('userId', isEqualTo: userId)
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfThisWeek))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfFollowingWeek))
          .get();
      
      debugPrint('UserEventRepository: Query executed successfully');
      debugPrint('UserEventRepository: Number of documents returned (with date filter): ${snapshot.docs.length}');
      
      if (snapshot.docs.isEmpty) {
        debugPrint('UserEventRepository: ⚠️ No events found for userId: $userId in the date range');
        debugPrint('UserEventRepository: Please check:');
        debugPrint('  1. Do events exist in Firestore user_events collection? ${allUserEvents.docs.isNotEmpty ? "YES (${allUserEvents.docs.length} total)" : "NO"}');
        debugPrint('  2. Is the userId correct? (userId: $userId)');
        debugPrint('  3. Are the event dates within the range? (${startOfThisWeek} to ${endOfFollowingWeek})');
        debugPrint('  4. Is the Firestore composite index created?');
      } else {
        debugPrint('UserEventRepository: ✅ Found ${snapshot.docs.length} events in date range');
        for (var doc in snapshot.docs) {
          final data = doc.data();
          debugPrint('  - Event: ${data['eventTitle']} | Date: ${data['eventDate']} | UserId: ${data['userId']}');
        }
      }
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      debugPrint('UserEventRepository: ❌ FirebaseException occurred');
      debugPrint('UserEventRepository: Error code: ${e.code}');
      debugPrint('UserEventRepository: Error message: ${e.message}');
      
      if (e.code == 'failed-precondition') {
        debugPrint('UserEventRepository: Missing index detected!');
        debugPrint('UserEventRepository: Please follow these steps:');
        debugPrint('1. Click the link in the error message to create the index');
        debugPrint('2. Wait 1-2 minutes for the index to build');
        debugPrint('3. Try again - the query will work automatically once index is ready');
      }
      rethrow;
    } catch (e) {
      debugPrint('UserEventRepository: ❌ Unexpected error: ${e.toString()}');
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
