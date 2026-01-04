import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../../domain/models/wellness_event.dart';

/// Repository for managing events in Firestore
class FirestoreEventRepository {
  final FirestoreService _firestore;

  FirestoreEventRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  /// Fetch all events from Firestore
  Future<List<WellnessEvent>> fetchAllEvents() async {
    try {
      final docs = await _firestore.getCollection(
        collection: FirestoreService.eventsCollection,
      );

      return docs.map(_mapToWellnessEvent).toList();
    } catch (e, stackTrace) {
      debugPrint('Error fetching events from Firestore: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetch event by ID
  Future<WellnessEvent?> fetchEventById(String id) async {
    try {
      final data = await _firestore.getDocument(
        collection: FirestoreService.eventsCollection,
        documentId: id,
      );

      if (data == null) return null;

      return _mapToWellnessEvent(data);
    } catch (e) {
      debugPrint('Error fetching event $id: $e');
      return null;
    }
  }

  /// Add new event to Firestore
  Future<void> addEvent(WellnessEvent event) async {
    await _firestore.createDocument(
      collection: FirestoreService.eventsCollection,
      documentId: event.id,
      data: _mapToFirestore(event),
    );
  }

  /// Update existing event in Firestore
  Future<void> updateEvent(WellnessEvent event) async {
    await _firestore.updateDocument(
      collection: FirestoreService.eventsCollection,
      documentId: event.id,
      data: _mapToFirestore(event),
    );
  }

  /// Delete event from Firestore
  Future<void> deleteEvent(String id) async {
    await _firestore.deleteDocument(
      collection: FirestoreService.eventsCollection,
      documentId: id,
    );
  }

  /// Stream events in real-time
  Stream<List<WellnessEvent>> watchAllEvents() {
    return _firestore
        .streamCollection(collection: FirestoreService.eventsCollection)
        .map((docs) => docs.map(_mapToWellnessEvent).toList());
  }

  /// Stream single event in real-time
  Stream<WellnessEvent?> watchEvent(String id) {
    return _firestore
        .streamDocument(
          collection: FirestoreService.eventsCollection,
          documentId: id,
        )
        .map((data) => data != null ? _mapToWellnessEvent(data) : null);
  }

  /// Query events by date range
  Future<List<WellnessEvent>> fetchEventsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final docs = await _firestore.getCollection(
        collection: FirestoreService.eventsCollection,
        queryBuilder: (collection) => collection
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
            .orderBy('date'),
      );

      return docs.map(_mapToWellnessEvent).toList();
    } catch (e) {
      debugPrint('Error fetching events by date range: $e');
      rethrow;
    }
  }

  /// Query events by status
  Future<List<WellnessEvent>> fetchEventsByStatus(String status) async {
    try {
      final docs = await _firestore.queryDocuments(
        collection: FirestoreService.eventsCollection,
        field: 'status',
        isEqualTo: status,
      );

      return docs.map(_mapToWellnessEvent).toList();
    } catch (e) {
      debugPrint('Error fetching events by status: $e');
      rethrow;
    }
  }

  /// Map Firestore document to WellnessEvent
  WellnessEvent _mapToWellnessEvent(Map<String, dynamic> data) {
    return WellnessEvent(
      id: data['id'] as String,
      title: data['title'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      venue: data['venue'] as String? ?? '',
      address: data['address'] as String? ?? '',
      townCity: data['townCity'] as String? ?? '',
      province: data['province'] as String? ?? '',
      onsiteContactFirstName: data['onsiteContactFirstName'] as String? ?? '',
      onsiteContactLastName: data['onsiteContactLastName'] as String? ?? '',
      onsiteContactNumber: data['onsiteContactNumber'] as String? ?? '',
      onsiteContactEmail: data['onsiteContactEmail'] as String? ?? '',
      aeContactFirstName: data['aeContactFirstName'] as String? ?? '',
      aeContactLastName: data['aeContactLastName'] as String? ?? '',
      aeContactNumber: data['aeContactNumber'] as String? ?? '',
      aeContactEmail: data['aeContactEmail'] as String? ?? '',
      servicesRequested: data['servicesRequested'] as String? ?? '',
      additionalServicesRequested:
          data['additionalServicesRequested'] as String? ?? '',
      expectedParticipation: data['expectedParticipation'] as int? ?? 0,
      nurses: data['nurses'] as int? ?? 0,
      coordinators: data['coordinators'] as int? ?? 0,
      setUpTime: data['setUpTime'] as String? ?? '',
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      strikeDownTime: data['strikeDownTime'] as String? ?? '',
      mobileBooths: data['mobileBooths'] as String? ?? '',
      medicalAid: data['medicalAid'] as String? ?? '',
      description: data['description'] as String?,
      status: data['status'] as String? ?? 'scheduled',
      actualStartTime: data['actualStartTime'] != null
          ? (data['actualStartTime'] as Timestamp).toDate()
          : null,
      actualEndTime: data['actualEndTime'] != null
          ? (data['actualEndTime'] as Timestamp).toDate()
          : null,
    );
  }

  /// Map WellnessEvent to Firestore document
  Map<String, dynamic> _mapToFirestore(WellnessEvent event) {
    return {
      'id': event.id,
      'title': event.title,
      'date': Timestamp.fromDate(event.date),
      'venue': event.venue,
      'address': event.address,
      'townCity': event.townCity,
      'province': event.province,
      'onsiteContactFirstName': event.onsiteContactFirstName,
      'onsiteContactLastName': event.onsiteContactLastName,
      'onsiteContactNumber': event.onsiteContactNumber,
      'onsiteContactEmail': event.onsiteContactEmail,
      'aeContactFirstName': event.aeContactFirstName,
      'aeContactLastName': event.aeContactLastName,
      'aeContactNumber': event.aeContactNumber,
      'aeContactEmail': event.aeContactEmail,
      'servicesRequested': event.servicesRequested,
      'additionalServicesRequested': event.additionalServicesRequested,
      'expectedParticipation': event.expectedParticipation,
      'nurses': event.nurses,
      'coordinators': event.coordinators,
      'setUpTime': event.setUpTime,
      'startTime': event.startTime,
      'endTime': event.endTime,
      'strikeDownTime': event.strikeDownTime,
      'mobileBooths': event.mobileBooths,
      'medicalAid': event.medicalAid,
      'description': event.description,
      'status': event.status,
      'actualStartTime': event.actualStartTime != null
          ? Timestamp.fromDate(event.actualStartTime!)
          : null,
      'actualEndTime': event.actualEndTime != null
          ? Timestamp.fromDate(event.actualEndTime!)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
