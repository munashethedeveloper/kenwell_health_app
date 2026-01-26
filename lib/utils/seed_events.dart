import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/wellness_event.dart';

/// Utility to seed sample events into Firestore
/// Call this from your app to populate initial data
class EventSeeder {
  final FirebaseFirestore _firestore;

  EventSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create sample wellness events
  List<WellnessEvent> _createSampleEvents() {
    final now = DateTime.now();

    return [
      WellnessEvent(
        title: 'Community Health Screening',
        date: now.add(const Duration(days: 7)),
        venue: 'Johannesburg Community Center',
        address: '123 Main Street',
        townCity: 'Johannesburg',
        province: 'Gauteng',
        onsiteContactFirstName: 'Sarah',
        onsiteContactLastName: 'Johnson',
        onsiteContactNumber: '0821234567',
        onsiteContactEmail: 'sarah.j@example.com',
        aeContactFirstName: 'Michael',
        aeContactLastName: 'Smith',
        aeContactNumber: '0827654321',
        aeContactEmail: 'michael.s@example.com',
        servicesRequested: 'Blood Pressure, Glucose Testing, BMI',
        additionalServicesRequested: 'Cholesterol Screening',
        expectedParticipation: 150,
        nurses: 3,
        coordinators: 2,
        setUpTime: '07:00',
        startTime: '08:00',
        endTime: '16:00',
        strikeDownTime: '17:00',
        mobileBooths: '2',
        medicalAid: 'Discovery Health',
        description: 'Annual community wellness screening event for residents',
        status: WellnessEventStatus.scheduled,
        screenedCount: 0,
      ),
      WellnessEvent(
        title: 'Corporate Wellness Day - ABC Company',
        date: now.add(const Duration(days: 14)),
        venue: 'ABC Corporation Office',
        address: '456 Business Park Drive',
        townCity: 'Pretoria',
        province: 'Gauteng',
        onsiteContactFirstName: 'Linda',
        onsiteContactLastName: 'Williams',
        onsiteContactNumber: '0823456789',
        onsiteContactEmail: 'linda.w@abccorp.com',
        aeContactFirstName: 'David',
        aeContactLastName: 'Brown',
        aeContactNumber: '0829876543',
        aeContactEmail: 'david.b@example.com',
        servicesRequested: 'Blood Pressure, Vision Screening, Hearing Test',
        additionalServicesRequested: 'Flu Shots',
        expectedParticipation: 200,
        nurses: 4,
        coordinators: 2,
        setUpTime: '06:30',
        startTime: '07:30',
        endTime: '15:30',
        strikeDownTime: '16:30',
        mobileBooths: '3',
        medicalAid: 'Bonitas',
        description: 'Corporate wellness screening for ABC Company employees',
        status: WellnessEventStatus.scheduled,
        screenedCount: 0,
      ),
      WellnessEvent(
        title: 'Senior Citizens Health Fair',
        date: now.add(const Duration(days: 21)),
        venue: 'Durban Retirement Village',
        address: '789 Coastal Road',
        townCity: 'Durban',
        province: 'KwaZulu-Natal',
        onsiteContactFirstName: 'Patricia',
        onsiteContactLastName: 'Davis',
        onsiteContactNumber: '0834567890',
        onsiteContactEmail: 'patricia.d@example.com',
        aeContactFirstName: 'Robert',
        aeContactLastName: 'Miller',
        aeContactNumber: '0830987654',
        aeContactEmail: 'robert.m@example.com',
        servicesRequested: 'Blood Pressure, Diabetes Screening, Bone Density',
        additionalServicesRequested: 'Memory Screening',
        expectedParticipation: 80,
        nurses: 2,
        coordinators: 1,
        setUpTime: '08:00',
        startTime: '09:00',
        endTime: '14:00',
        strikeDownTime: '15:00',
        mobileBooths: '1',
        medicalAid: 'Medihelp',
        description: 'Health screening event focused on senior citizens',
        status: WellnessEventStatus.scheduled,
        screenedCount: 0,
      ),
      WellnessEvent(
        title: 'School Health Screening',
        date: now.add(const Duration(days: 3)),
        venue: 'Cape Town Primary School',
        address: '321 Education Avenue',
        townCity: 'Cape Town',
        province: 'Western Cape',
        onsiteContactFirstName: 'Jennifer',
        onsiteContactLastName: 'Wilson',
        onsiteContactNumber: '0845678901',
        onsiteContactEmail: 'jennifer.w@ctschool.co.za',
        aeContactFirstName: 'James',
        aeContactLastName: 'Moore',
        aeContactNumber: '0841098765',
        aeContactEmail: 'james.m@example.com',
        servicesRequested: 'Vision Screening, Hearing Test, Dental Check',
        additionalServicesRequested: 'Growth Monitoring',
        expectedParticipation: 300,
        nurses: 5,
        coordinators: 3,
        setUpTime: '07:00',
        startTime: '08:00',
        endTime: '14:00',
        strikeDownTime: '15:00',
        mobileBooths: '2',
        medicalAid: 'Gems',
        description: 'Annual health screening for primary school students',
        status: WellnessEventStatus.scheduled,
        screenedCount: 0,
      ),
      WellnessEvent(
        title: 'Mobile Clinic - Township Outreach',
        date: now.subtract(const Duration(days: 5)),
        venue: 'Soweto Community Hall',
        address: '654 Freedom Square',
        townCity: 'Soweto',
        province: 'Gauteng',
        onsiteContactFirstName: 'Mary',
        onsiteContactLastName: 'Taylor',
        onsiteContactNumber: '0856789012',
        onsiteContactEmail: 'mary.t@example.com',
        aeContactFirstName: 'Christopher',
        aeContactLastName: 'Anderson',
        aeContactNumber: '0852109876',
        aeContactEmail: 'chris.a@example.com',
        servicesRequested: 'HIV Testing, TB Screening, Blood Pressure',
        additionalServicesRequested: 'Family Planning',
        expectedParticipation: 250,
        nurses: 6,
        coordinators: 3,
        setUpTime: '06:00',
        startTime: '07:00',
        endTime: '17:00',
        strikeDownTime: '18:00',
        mobileBooths: '4',
        medicalAid: 'N/A',
        description: 'Mobile health clinic providing essential screenings',
        status: WellnessEventStatus.completed,
        actualStartTime: now.subtract(const Duration(days: 5, hours: 17)),
        actualEndTime: now.subtract(const Duration(days: 5, hours: 7)),
        screenedCount: 187,
      ),
    ];
  }

  /// Seed events into Firestore
  Future<void> seedEvents() async {
    try {
      debugPrint('EventSeeder: Starting to seed events...');
      final events = _createSampleEvents();

      int count = 0;
      for (final event in events) {
        final eventData = {
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

        await _firestore.collection('events').doc(event.id).set(eventData);
        count++;
        debugPrint('EventSeeder: Created event: ${event.title}');
      }

      debugPrint('EventSeeder: Successfully seeded $count events');
    } catch (e, stackTrace) {
      debugPrint('EventSeeder: Error seeding events: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Clear all events from Firestore (use with caution!)
  Future<void> clearAllEvents() async {
    try {
      debugPrint('EventSeeder: Clearing all events...');
      final snapshot = await _firestore.collection('events').get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('EventSeeder: Cleared ${snapshot.docs.length} events');
    } catch (e) {
      debugPrint('EventSeeder: Error clearing events: $e');
      rethrow;
    }
  }
}
