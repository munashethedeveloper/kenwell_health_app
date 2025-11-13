import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/data/repositories_dcl/event_repository.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

void main() {
  group('EventRepository', () {
    late EventRepository repository;

    setUp(() {
      repository = EventRepository();
    });

    test('deleteEvent removes event from repository', () async {
      // Arrange: Add an event to the repository
      final event = WellnessEvent(
        id: 'test-id-1',
        title: 'Test Event',
        date: DateTime(2024, 1, 15),
        venue: 'Test Venue',
        address: 'Test Address',
        onsiteContactPerson: 'John Doe',
        onsiteContactNumber: '1234567890',
        onsiteContactEmail: 'john@example.com',
        aeContactPerson: 'Jane Doe',
        aeContactNumber: '0987654321',
        servicesRequested: 'HRA',
        expectedParticipation: 50,
        nonMembers: 10,
        passports: 5,
        nurses: 2,
        coordinators: 1,
        multiplyPromoters: 3,
        setUpTime: '08:00 AM',
        startTime: '09:00 AM',
        endTime: '05:00 PM',
        strikeDownTime: '06:00 PM',
        mobileBooths: 'Yes',
        medicalAid: 'Yes',
      );
      repository.addEvent(event);

      // Act: Delete the event
      await repository.deleteEvent('test-id-1');

      // Assert: Event should not be found
      final fetchedEvent = await repository.fetchEventById('test-id-1');
      expect(fetchedEvent, isNull);
    });

    test('deleteEvent with non-existent id completes without error', () async {
      // Act: Delete a non-existent event
      await repository.deleteEvent('non-existent-id');

      // Assert: No exception should be thrown
      expect(true, isTrue);
    });

    test('fetchEventById returns null after deletion', () async {
      // Arrange: Add an event
      final event = WellnessEvent(
        id: 'test-id-2',
        title: 'Event to Delete',
        date: DateTime(2024, 2, 20),
        venue: 'Venue 2',
        address: 'Address 2',
        onsiteContactPerson: 'Alice',
        onsiteContactNumber: '1111111111',
        onsiteContactEmail: 'alice@example.com',
        aeContactPerson: 'Bob',
        aeContactNumber: '2222222222',
        servicesRequested: 'Other',
        expectedParticipation: 30,
        nonMembers: 5,
        passports: 2,
        nurses: 1,
        coordinators: 1,
        multiplyPromoters: 1,
        setUpTime: '10:00 AM',
        startTime: '11:00 AM',
        endTime: '03:00 PM',
        strikeDownTime: '04:00 PM',
        mobileBooths: 'No',
        medicalAid: 'No',
      );
      repository.addEvent(event);

      // Verify event exists
      final fetchedBefore = await repository.fetchEventById('test-id-2');
      expect(fetchedBefore, isNotNull);
      expect(fetchedBefore?.id, 'test-id-2');

      // Act: Delete the event
      await repository.deleteEvent('test-id-2');

      // Assert: Event should no longer exist
      final fetchedAfter = await repository.fetchEventById('test-id-2');
      expect(fetchedAfter, isNull);
    });

    test('updateEvent updates existing event and returns previous version',
        () async {
      // Arrange: Add an event
      final originalEvent = WellnessEvent(
        id: 'test-id-3',
        title: 'Original Title',
        date: DateTime(2024, 3, 15),
        venue: 'Original Venue',
        address: 'Original Address',
        onsiteContactPerson: 'John Doe',
        onsiteContactNumber: '1234567890',
        onsiteContactEmail: 'john@example.com',
        aeContactPerson: 'Jane Doe',
        aeContactNumber: '0987654321',
        servicesRequested: 'HRA',
        expectedParticipation: 50,
        nonMembers: 10,
        passports: 5,
        nurses: 2,
        coordinators: 1,
        multiplyPromoters: 3,
        setUpTime: '08:00 AM',
        startTime: '09:00 AM',
        endTime: '05:00 PM',
        strikeDownTime: '06:00 PM',
        mobileBooths: 'Yes',
        medicalAid: 'Yes',
      );
      repository.addEvent(originalEvent);

      // Create an updated version
      final updatedEvent = originalEvent.copyWith(
        title: 'Updated Title',
        venue: 'Updated Venue',
      );

      // Act: Update the event
      final previousEvent = await repository.updateEvent(updatedEvent);

      // Assert: Previous event should be returned
      expect(previousEvent, isNotNull);
      expect(previousEvent?.id, 'test-id-3');
      expect(previousEvent?.title, 'Original Title');
      expect(previousEvent?.venue, 'Original Venue');

      // Assert: Updated event should be in repository
      final fetchedEvent = await repository.fetchEventById('test-id-3');
      expect(fetchedEvent, isNotNull);
      expect(fetchedEvent?.title, 'Updated Title');
      expect(fetchedEvent?.venue, 'Updated Venue');
    });

    test('updateEvent with non-existent id returns null', () async {
      // Arrange: Create an event with a non-existent ID
      final event = WellnessEvent(
        id: 'non-existent-id',
        title: 'Test Event',
        date: DateTime(2024, 4, 20),
        venue: 'Test Venue',
        address: 'Test Address',
        onsiteContactPerson: 'Alice',
        onsiteContactNumber: '1111111111',
        onsiteContactEmail: 'alice@example.com',
        aeContactPerson: 'Bob',
        aeContactNumber: '2222222222',
        servicesRequested: 'Other',
        expectedParticipation: 30,
        nonMembers: 5,
        passports: 2,
        nurses: 1,
        coordinators: 1,
        multiplyPromoters: 1,
        setUpTime: '10:00 AM',
        startTime: '11:00 AM',
        endTime: '03:00 PM',
        strikeDownTime: '04:00 PM',
        mobileBooths: 'No',
        medicalAid: 'No',
      );

      // Act: Try to update a non-existent event
      final previousEvent = await repository.updateEvent(event);

      // Assert: Should return null
      expect(previousEvent, isNull);
    });
  });
}
