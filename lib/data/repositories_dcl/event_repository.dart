import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/models/wellness_event.dart';

class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collectionName = 'events';

  Future<List<WellnessEvent>> fetchAllEvents() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      debugPrint(
          'EventRepository: Fetched ${snapshot.docs.length} events from Firestore');
      return snapshot.docs
          .map((doc) => _mapFirestoreToDomain(doc.id, doc.data()))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('EventRepository: Error fetching events: $e');
      debugPrint('EventRepository: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<WellnessEvent?> fetchEventById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return _mapFirestoreToDomain(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('EventRepository: Error fetching event by id: $e');
      rethrow;
    }
  }

  Future<void> addEvent(WellnessEvent event) => upsertEvent(event);

  Future<void> deleteEvent(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  Future<void> updateEvent(WellnessEvent updatedEvent) =>
      upsertEvent(updatedEvent);

  Future<void> upsertEvent(WellnessEvent event) async {
    try {
      debugPrint(
          'EventRepository: Saving event "${event.title}" with id: ${event.id}');
      final eventData = _mapDomainToFirestore(event);
      debugPrint('EventRepository: Event data: $eventData');

      await _firestore.collection(_collectionName).doc(event.id).set(eventData);

      debugPrint('EventRepository: Event saved successfully');
    } catch (e, stackTrace) {
      debugPrint('EventRepository: ERROR saving event: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  WellnessEvent _mapFirestoreToDomain(String id, Map<String, dynamic> data) {
    return WellnessEvent(
      id: id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      venue: data['venue'] ?? '',
      address: data['address'] ?? '',
      townCity: data['townCity'] ?? '',
      province: data['province'] ?? '',
      onsiteContactFirstName: data['onsiteContactFirstName'] ?? '',
      onsiteContactLastName: data['onsiteContactLastName'] ?? '',
      onsiteContactNumber: data['onsiteContactNumber'] ?? '',
      onsiteContactEmail: data['onsiteContactEmail'] ?? '',
      aeContactFirstName: data['aeContactFirstName'] ?? '',
      aeContactLastName: data['aeContactLastName'] ?? '',
      aeContactNumber: data['aeContactNumber'] ?? '',
      aeContactEmail: data['aeContactEmail'] ?? '',
      servicesRequested: data['servicesRequested'] ?? '',
      additionalServicesRequested: data['additionalServicesRequested'] ?? '',
      expectedParticipation: data['expectedParticipation'] ?? 0,
      nurses: data['nurses'] ?? 0,
      coordinators: data['coordinators'] ?? 0,
      setUpTime: data['setUpTime'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      strikeDownTime: data['strikeDownTime'] ?? '',
      mobileBooths: data['mobileBooths'] ?? 0,
      description: data['description'] ?? '',
      medicalAid: data['medicalAid'] ?? '',
      status: data['status'] ?? '',
      actualStartTime: (data['actualStartTime'] as Timestamp?)?.toDate(),
      actualEndTime: (data['actualEndTime'] as Timestamp?)?.toDate(),
      screenedCount: data['screenedCount'] ?? 0,
    );
  }

  Map<String, dynamic> _mapDomainToFirestore(WellnessEvent event) {
    return {
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
      'screenedCount': event.screenedCount,
    };
  }
}
