import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/data/repositories_dcl/event_repository.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

void main() {
  group('EventRepository', () {
    late EventRepository repository;
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = EventRepository(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('deleteEvent removes event from repository', () async {
      // Arrange: Add an event to the repository
      final event = WellnessEvent(
        id: 'test-id-1',
        title: 'Test Event',
        date: DateTime(2024, 1, 15),
        venue: 'Test Venue',
        address: 'Test Address',
        onsiteContactFirstName: 'John',
        onsiteContactLastName: 'Doe',
        onsiteContactNumber: '1234567890',
        onsiteContactEmail: 'john@example.com',
        aeContactFirstName: 'Jane',
        aeContactLastName: 'Doe',
        aeContactNumber: '0987654321',
        aeContactEmail: 'jane@example.com',
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
      await repository.addEvent(event);

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
        onsiteContactFirstName: 'Alice',
        onsiteContactLastName: '',
        onsiteContactNumber: '1111111111',
        onsiteContactEmail: 'alice@example.com',
        aeContactFirstName: 'Bob',
        aeContactLastName: '',
        aeContactNumber: '2222222222',
        aeContactEmail: 'bob@example.com',
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
      await repository.addEvent(event);

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

    test('updateEvent updates event in repository', () async {
      // Arrange: Add an event to the repository
      final event = WellnessEvent(
        id: 'test-id-3',
        title: 'Original Title',
        date: DateTime(2024, 3, 15),
        venue: 'Original Venue',
        address: 'Original Address',
        onsiteContactFirstName: 'John',
        onsiteContactLastName: 'Doe',
        onsiteContactNumber: '1234567890',
        onsiteContactEmail: 'john@example.com',
        aeContactFirstName: 'Jane',
        aeContactLastName: 'Doe',
        aeContactNumber: '0987654321',
        aeContactEmail: 'jane@example.com',
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
      await repository.addEvent(event);

      // Act: Update the event with new title and venue
      final updatedEvent = event.copyWith(
        title: 'Updated Title',
        venue: 'Updated Venue',
      );
      await repository.updateEvent(updatedEvent);

      // Assert: Fetched event should have updated values
      final fetchedEvent = await repository.fetchEventById('test-id-3');
      expect(fetchedEvent, isNotNull);
      expect(fetchedEvent?.title, 'Updated Title');
      expect(fetchedEvent?.venue, 'Updated Venue');
      expect(fetchedEvent?.address, 'Original Address'); // unchanged
    });

    test('updateEvent with non-existent id completes without error', () async {
      // Arrange: Create an event that doesn't exist in repository
      final event = WellnessEvent(
        id: 'non-existent-id',
        title: 'Test Event',
        date: DateTime(2024, 4, 20),
        venue: 'Test Venue',
        address: 'Test Address',
        onsiteContactFirstName: 'John',
        onsiteContactLastName: 'Doe',
        onsiteContactNumber: '1234567890',
        onsiteContactEmail: 'john@example.com',
        aeContactFirstName: 'Jane',
        aeContactLastName: 'Doe',
        aeContactNumber: '0987654321',
        aeContactEmail: 'jane@example.com',
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

      // Act: Update a non-existent event
      await repository.updateEvent(event);

      // Assert: No exception should be thrown
      expect(true, isTrue);
    });

    test('updateEvent persists all field changes', () async {
      // Arrange: Add an event
      final event = WellnessEvent(
        id: 'test-id-4',
        title: 'Original',
        date: DateTime(2024, 5, 10),
        venue: 'Venue A',
        address: 'Address A',
        onsiteContactFirstName: 'Contact',
        onsiteContactLastName: 'A',
        onsiteContactNumber: '1111111111',
        onsiteContactEmail: 'a@example.com',
        aeContactFirstName: 'AE',
        aeContactLastName: 'A',
        aeContactNumber: '2222222222',
        aeContactEmail: 'aea@example.com',
        servicesRequested: 'HRA',
        expectedParticipation: 30,
        nonMembers: 5,
        passports: 3,
        nurses: 2,
        coordinators: 1,
        multiplyPromoters: 2,
        setUpTime: '08:00 AM',
        startTime: '09:00 AM',
        endTime: '05:00 PM',
        strikeDownTime: '06:00 PM',
        mobileBooths: 'Yes',
        medicalAid: 'Yes',
      );
      await repository.addEvent(event);

      // Act: Update multiple fields
      final updatedEvent = event.copyWith(
        title: 'Updated',
        venue: 'Venue B',
        expectedParticipation: 100,
        nurses: 5,
      );
      await repository.updateEvent(updatedEvent);

      // Assert: All updated fields should persist
      final fetchedEvent = await repository.fetchEventById('test-id-4');
      expect(fetchedEvent, isNotNull);
      expect(fetchedEvent?.title, 'Updated');
      expect(fetchedEvent?.venue, 'Venue B');
      expect(fetchedEvent?.expectedParticipation, 100);
      expect(fetchedEvent?.nurses, 5);
      // Verify unchanged fields
      expect(fetchedEvent?.address, 'Address A');
      expect(fetchedEvent?.onsiteContactPerson, 'Contact A');
    });
  });
}
