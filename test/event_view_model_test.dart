import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_view_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

void main() {
  group('EventViewModel Delete Functionality', () {
    late EventViewModel viewModel;

    setUp(() {
      viewModel = EventViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('deleteEvent removes event from list and returns it', () {
      // Arrange: Add an event
      final event = WellnessEvent(
        id: 'event-1',
        title: 'Test Event',
        date: DateTime(2024, 3, 10),
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
      viewModel.addEvent(event);
      expect(viewModel.events.length, 1);

      // Act: Delete the event
      final deletedEvent = viewModel.deleteEvent('event-1');

      // Assert: Event should be removed and returned
      expect(deletedEvent, isNotNull);
      expect(deletedEvent?.id, 'event-1');
      expect(viewModel.events.length, 0);
    });

    test('deleteEvent with non-existent id returns null', () {
      // Arrange: Add an event with a different id
      final event = WellnessEvent(
        id: 'event-2',
        title: 'Another Event',
        date: DateTime(2024, 4, 15),
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
      viewModel.addEvent(event);

      // Act: Try to delete a non-existent event
      final deletedEvent = viewModel.deleteEvent('non-existent-id');

      // Assert: Should return null and not affect existing events
      expect(deletedEvent, isNull);
      expect(viewModel.events.length, 1);
      expect(viewModel.events.first.id, 'event-2');
    });

    test('restoreEvent adds deleted event back to list', () {
      // Arrange: Add and delete an event
      final event = WellnessEvent(
        id: 'event-3',
        title: 'Restorable Event',
        date: DateTime(2024, 5, 20),
        venue: 'Venue 3',
        address: 'Address 3',
        onsiteContactFirstName: 'Charlie',
        onsiteContactLastName: '',
        onsiteContactNumber: '3333333333',
        onsiteContactEmail: 'charlie@example.com',
        aeContactFirstName: 'Diana',
        aeContactLastName: '',
        aeContactNumber: '4444444444',
        aeContactEmail: 'diana@example.com',
        servicesRequested: 'HRA',
        expectedParticipation: 40,
        nonMembers: 8,
        passports: 3,
        nurses: 2,
        coordinators: 1,
        multiplyPromoters: 2,
        setUpTime: '09:00 AM',
        startTime: '10:00 AM',
        endTime: '04:00 PM',
        strikeDownTime: '05:00 PM',
        mobileBooths: 'Yes',
        medicalAid: 'No',
      );
      viewModel.addEvent(event);
      final deletedEvent = viewModel.deleteEvent('event-3');
      expect(viewModel.events.length, 0);

      // Act: Restore the event
      viewModel.restoreEvent(deletedEvent!);

      // Assert: Event should be back in the list
      expect(viewModel.events.length, 1);
      expect(viewModel.events.first.id, 'event-3');
      expect(viewModel.events.first.title, 'Restorable Event');
    });

    test('deleteEvent notifies listeners', () {
      // Arrange: Add an event and listen for notifications
      final event = WellnessEvent(
        id: 'event-4',
        title: 'Notify Event',
        date: DateTime(2024, 6, 25),
        venue: 'Venue 4',
        address: 'Address 4',
        onsiteContactFirstName: 'Eve',
        onsiteContactLastName: '',
        onsiteContactNumber: '5555555555',
        onsiteContactEmail: 'eve@example.com',
        aeContactFirstName: 'Frank',
        aeContactLastName: '',
        aeContactNumber: '6666666666',
        aeContactEmail: 'frank@example.com',
        servicesRequested: 'Other',
        expectedParticipation: 25,
        nonMembers: 3,
        passports: 1,
        nurses: 1,
        coordinators: 0,
        multiplyPromoters: 1,
        setUpTime: '08:30 AM',
        startTime: '09:30 AM',
        endTime: '02:00 PM',
        strikeDownTime: '03:00 PM',
        mobileBooths: 'No',
        medicalAid: 'Yes',
      );
      viewModel.addEvent(event);

      bool notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      // Act: Delete the event
      viewModel.deleteEvent('event-4');

      // Assert: Listener should be notified
      expect(notified, isTrue);
    });

    test('restoreEvent notifies listeners', () {
      // Arrange: Create an event
      final event = WellnessEvent(
        id: 'event-5',
        title: 'Restore Notify Event',
        date: DateTime(2024, 7, 30),
        venue: 'Venue 5',
        address: 'Address 5',
        onsiteContactFirstName: 'Grace',
        onsiteContactLastName: '',
        onsiteContactNumber: '7777777777',
        onsiteContactEmail: 'grace@example.com',
        aeContactFirstName: 'Henry',
        aeContactLastName: '',
        aeContactNumber: '8888888888',
        aeContactEmail: 'henry@example.com',
        servicesRequested: 'HRA',
        expectedParticipation: 60,
        nonMembers: 12,
        passports: 6,
        nurses: 3,
        coordinators: 2,
        multiplyPromoters: 4,
        setUpTime: '07:00 AM',
        startTime: '08:00 AM',
        endTime: '06:00 PM',
        strikeDownTime: '07:00 PM',
        mobileBooths: 'Yes',
        medicalAid: 'Yes',
      );

      bool notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      // Act: Restore the event
      viewModel.restoreEvent(event);

      // Assert: Listener should be notified
      expect(notified, isTrue);
      expect(viewModel.events.length, 1);
    });
  });

  group('EventViewModel Update Functionality', () {
    late EventViewModel viewModel;

    setUp(() {
      viewModel = EventViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('updateEvent returns previous event and updates list', () {
      // Arrange: Add an event
      final event = WellnessEvent(
        id: 'event-6',
        title: 'Original Title',
        date: DateTime(2024, 8, 15),
        venue: 'Original Venue',
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
      viewModel.addEvent(event);
      expect(viewModel.events.length, 1);

      // Act: Update the event
      final updatedEvent = event.copyWith(
        title: 'Updated Title',
        venue: 'Updated Venue',
      );
      final previousEvent = viewModel.updateEvent(updatedEvent);

      // Assert: Previous event should be returned
      expect(previousEvent, isNotNull);
      expect(previousEvent?.id, 'event-6');
      expect(previousEvent?.title, 'Original Title');
      expect(previousEvent?.venue, 'Original Venue');

      // Assert: Event list should contain updated event
      expect(viewModel.events.length, 1);
      expect(viewModel.events.first.title, 'Updated Title');
      expect(viewModel.events.first.venue, 'Updated Venue');
    });

    test('updateEvent with non-existent id returns null', () {
      // Arrange: Add an event with different id
      final event = WellnessEvent(
        id: 'event-7',
        title: 'Test Event',
        date: DateTime(2024, 9, 20),
        venue: 'Venue',
        address: 'Address',
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
      viewModel.addEvent(event);

      // Act: Try to update non-existent event
      final nonExistentEvent = WellnessEvent(
        id: 'non-existent-id',
        title: 'Updated',
        date: DateTime(2024, 9, 20),
        venue: 'Updated Venue',
        address: 'Address',
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
      final previousEvent = viewModel.updateEvent(nonExistentEvent);

      // Assert: Should return null and not affect existing events
      expect(previousEvent, isNull);
      expect(viewModel.events.length, 1);
      expect(viewModel.events.first.id, 'event-7');
      expect(viewModel.events.first.title, 'Test Event');
    });

    test('updateEvent notifies listeners', () {
      // Arrange: Add an event and listen for notifications
      final event = WellnessEvent(
        id: 'event-8',
        title: 'Original',
        date: DateTime(2024, 10, 5),
        venue: 'Venue',
        address: 'Address',
        onsiteContactFirstName: 'Eve',
        onsiteContactLastName: '',
        onsiteContactNumber: '5555555555',
        onsiteContactEmail: 'eve@example.com',
        aeContactFirstName: 'Frank',
        aeContactLastName: '',
        aeContactNumber: '6666666666',
        aeContactEmail: 'frank@example.com',
        servicesRequested: 'Other',
        expectedParticipation: 25,
        nonMembers: 3,
        passports: 1,
        nurses: 1,
        coordinators: 0,
        multiplyPromoters: 1,
        setUpTime: '08:30 AM',
        startTime: '09:30 AM',
        endTime: '02:00 PM',
        strikeDownTime: '03:00 PM',
        mobileBooths: 'No',
        medicalAid: 'Yes',
      );
      viewModel.addEvent(event);

      bool notified = false;
      viewModel.addListener(() {
        notified = true;
      });

      // Act: Update the event
      final updatedEvent = event.copyWith(title: 'Updated');
      viewModel.updateEvent(updatedEvent);

      // Assert: Listener should be notified
      expect(notified, isTrue);
    });

    test('restoreEvent after updateEvent restores previous state', () {
      // Arrange: Add an event
      final originalEvent = WellnessEvent(
        id: 'event-9',
        title: 'Original Title',
        date: DateTime(2024, 11, 12),
        venue: 'Original Venue',
        address: 'Address',
        onsiteContactFirstName: 'Grace',
        onsiteContactLastName: '',
        onsiteContactNumber: '7777777777',
        onsiteContactEmail: 'grace@example.com',
        aeContactFirstName: 'Henry',
        aeContactLastName: '',
        aeContactNumber: '8888888888',
        aeContactEmail: 'henry@example.com',
        servicesRequested: 'HRA',
        expectedParticipation: 40,
        nonMembers: 8,
        passports: 4,
        nurses: 2,
        coordinators: 1,
        multiplyPromoters: 2,
        setUpTime: '09:00 AM',
        startTime: '10:00 AM',
        endTime: '04:00 PM',
        strikeDownTime: '05:00 PM',
        mobileBooths: 'Yes',
        medicalAid: 'No',
      );
      viewModel.addEvent(originalEvent);

      // Act: Update the event
      final updatedEvent = originalEvent.copyWith(
        title: 'Updated Title',
        venue: 'Updated Venue',
      );
      final previousEvent = viewModel.updateEvent(updatedEvent);
      expect(viewModel.events.first.title, 'Updated Title');

      // Act: Restore previous event by updating back
      viewModel.updateEvent(previousEvent!);

      // Assert: Event should be restored to original state
      expect(viewModel.events.length, 1);
      expect(viewModel.events.first.id, 'event-9');
      expect(viewModel.events.first.title, 'Original Title');
      expect(viewModel.events.first.venue, 'Original Venue');
    });
  });
}
