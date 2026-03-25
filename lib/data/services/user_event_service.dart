import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'audit_log_service.dart';

class UserEventService {
  static final AuditLogService _audit = AuditLogService();

  static Future<void> addUserEvent({
    required WellnessEvent event,
    required UserModel user,
  }) async {
    debugPrint('UserEventService: Allocating event to user');
    debugPrint('UserEventService: - Event ID: ${event.id}');
    debugPrint('UserEventService: - Event Title: ${event.title}');
    debugPrint('UserEventService: - User ID: ${user.id}');
    debugPrint(
        'UserEventService: - User Name: ${user.firstName} ${user.lastName}');
    debugPrint('UserEventService: - User Email: ${user.email}');
    debugPrint('UserEventService: - User Role: ${user.role}');

    final data = {
      'eventId': event.id,
      'eventTitle': event.title,
      'eventDate':
          Timestamp.fromDate(event.date), // Convert DateTime to Timestamp
      'eventVenue': event.venue,
      'eventLocation': event.address,
      'eventStartTime': event.startTime,
      'eventEndTime': event.endTime,
      'servicesRequested': event.servicesRequested,
      'userId': user.id,
      'userFirstName': user.firstName,
      'userLastName': user.lastName,
      'userEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    };

    debugPrint('UserEventService: Data to save: ${data.toString()}');

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('user_events').add(data);
      debugPrint(
          'UserEventService: ✅ Successfully saved to Firestore with document ID: ${docRef.id}');

      unawaited(_audit.logCreate(
        collection: 'user_events',
        documentId: docRef.id,
        data: {
          'eventId': event.id,
          'eventTitle': event.title,
          'userId': user.id,
          'userName': '${user.firstName} ${user.lastName}',
        },
        summary:
            'Allocated user ${user.firstName} ${user.lastName} to event "${event.title}"',
      ));
    } catch (e) {
      debugPrint('UserEventService: ❌ ERROR saving to Firestore: $e');
      rethrow;
    }
  }
}
