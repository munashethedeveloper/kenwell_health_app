import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

class UserEventService {
  static Future<void> addUserEvent({
    required WellnessEvent event,
    required UserModel user,
  }) async {
    print('UserEventService: Allocating event to user');
    print('UserEventService: - Event ID: ${event.id}');
    print('UserEventService: - Event Title: ${event.title}');
    print('UserEventService: - User ID: ${user.id}');
    print('UserEventService: - User Name: ${user.firstName} ${user.lastName}');
    print('UserEventService: - User Email: ${user.email}');
    print('UserEventService: - User Role: ${user.role}');
    
    final data = {
      'eventId': event.id,
      'eventTitle': event.title,
      'eventDate': Timestamp.fromDate(event.date), // Convert DateTime to Timestamp
      'eventVenue': event.venue,
      'eventLocation': event.address,
      'eventStartTime': event.startTime,
      'eventEndTime': event.endTime,
      'userId': user.id,
      'userFirstName': user.firstName,
      'userLastName': user.lastName,
      'userEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    print('UserEventService: Data to save: ${data.toString()}');
    
    try {
      final docRef = await FirebaseFirestore.instance.collection('user_events').add(data);
      print('UserEventService: ✅ Successfully saved to Firestore with document ID: ${docRef.id}');
    } catch (e) {
      print('UserEventService: ❌ ERROR saving to Firestore: $e');
      rethrow;
    }
  }
}
