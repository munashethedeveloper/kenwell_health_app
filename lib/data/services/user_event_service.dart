import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'audit_log_service.dart';
import 'pending_write_service.dart';

class UserEventService {
  static final AuditLogService _audit = AuditLogService();

  /// Assigns [user] to [event], persisting the relationship in Firestore.
  ///
  /// Uses a deterministic document ID (`{eventId}_{userId}`) so that:
  /// - duplicate assignments are idempotent (set with merge),
  /// - retries via [PendingWriteService] target the correct document.
  ///
  /// **Offline**: When Firestore is unreachable the write is queued in
  /// [PendingWriteService] for automatic retry on reconnect.
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

    // Deterministic composite ID prevents duplicate allocations and enables
    // reliable offline queuing/retry without needing to know the Firestore
    // auto-generated ID.
    final docId = '${event.id}_${user.id}';

    // Store a plain integer timestamp so the map can be JSON-encoded by
    // PendingWriteService (FieldValue.serverTimestamp() is not serialisable).
    // Using an integer timestamp consistently for both online and offline paths
    // keeps the data format uniform across all write paths.
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final data = <String, dynamic>{
      'eventId': event.id,
      'eventTitle': event.title,
      'eventDate': nowMs, // stored as int ms — consistent for online + queued
      'eventVenue': event.venue,
      'eventLocation': event.address,
      'eventStartTime': event.startTime,
      'eventEndTime': event.endTime,
      'servicesRequested': event.servicesRequested,
      'userId': user.id,
      'userFirstName': user.firstName,
      'userLastName': user.lastName,
      'userEmail': user.email,
      'createdAt': nowMs,
    };

    debugPrint('UserEventService: Data to save: ${data.toString()}');

    try {
      // Use set (with merge) so repeated allocations are idempotent.
      await FirebaseFirestore.instance
          .collection('user_events')
          .doc(docId)
          .set(data, SetOptions(merge: true));
      debugPrint(
          'UserEventService: ✅ Successfully saved to Firestore with document ID: $docId');

      unawaited(_audit.logCreate(
        collection: 'user_events',
        documentId: docId,
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
      debugPrint(
          'UserEventService: ❌ Firestore write failed ($e) — queuing for retry');
      // Queue for retry when connectivity is restored.
      unawaited(PendingWriteService.instance.enqueue(
        collection: 'user_events',
        docId: docId,
        data: data,
      ));
    }
  }
}
