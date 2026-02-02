import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

class UserEventService {
  static Future<void> addUserEvent({
    required WellnessEvent event,
    required UserModel user,
  }) async {
    final data = {
      'eventId': event.id,
      'eventTitle': event.title,
      'eventDate': event.date,
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
    await FirebaseFirestore.instance.collection('user_events').add(data);
  }
}
