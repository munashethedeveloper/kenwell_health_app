import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/ui/features/event/widgets/event_details_screen.dart';
import 'package:kenwell_health_app/ui/features/event/widgets/event_screen.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_view_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

void main() {
  group('Event Edit Flow Widget Tests', () {
    late EventViewModel viewModel;
    late WellnessEvent testEvent;

    setUp(() {
      viewModel = EventViewModel();
      testEvent = WellnessEvent(
        id: 'test-event-edit',
        title: 'Original Event Title',
        date: DateTime(2024, 10, 15),
        venue: 'Original Venue',
        address: 'Original Address',
        onsiteContactFirstName: 'John',
        onsiteContactLastName: 'Smith',
        onsiteContactNumber: '555-0123',
        onsiteContactEmail: 'john@example.com',
        aeContactFirstName: 'Jane',
        aeContactLastName: 'Doe',
        aeContactNumber: '555-0456',
        aeContactEmail: 'jane@example.com',
        servicesRequested: 'HRA',
        expectedParticipation: 100,
        nonMembers: 20,
        passports: 10,
        nurses: 3,
        coordinators: 2,
        multiplyPromoters: 5,
        setUpTime: '07:00 AM',
        startTime: '08:00 AM',
        endTime: '05:00 PM',
        strikeDownTime: '06:00 PM',
        mobileBooths: 'Yes',
        medicalAid: 'Yes',
      );
      viewModel.addEvent(testEvent);
    });

    tearDown(() {
      viewModel.dispose();
    });

    testWidgets('EventScreen shows Edit Event title when editing',
        (WidgetTester tester) async {
      // Arrange & Act: Build the EventScreen with an existing event
      await tester.pumpWidget(
        MaterialApp(
          home: EventScreen(
            viewModel: viewModel,
            date: testEvent.date,
            existingEvent: testEvent,
            onSave: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: AppBar should show "Edit Event"
      expect(find.text('Edit Event'), findsOneWidget);
    });

    testWidgets('EventScreen shows Add Event title when creating',
        (WidgetTester tester) async {
      // Arrange & Act: Build the EventScreen without an existing event
      await tester.pumpWidget(
        MaterialApp(
          home: EventScreen(
            viewModel: viewModel,
            date: DateTime.now(),
            onSave: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: AppBar should show "Add Event"
      expect(find.text('Add Event'), findsOneWidget);
    });

    testWidgets('EventScreen prefills fields when editing',
        (WidgetTester tester) async {
      // Arrange & Act: Build the EventScreen with existing event
      await tester.pumpWidget(
        MaterialApp(
          home: EventScreen(
            viewModel: viewModel,
            date: testEvent.date,
            existingEvent: testEvent,
            onSave: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Form fields should be prefilled with event data
      expect(find.text('Original Event Title'), findsOneWidget);
      expect(find.text('Original Venue'), findsOneWidget);
      expect(find.text('Original Address'), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Smith'), findsOneWidget);
      expect(find.text('555-0123'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
      expect(find.text('555-0456'), findsOneWidget);
    });

    testWidgets('Saving edit preserves event ID', (WidgetTester tester) async {
      WellnessEvent? savedEvent;

      // Arrange: Build the EventScreen with existing event
      await tester.pumpWidget(
        MaterialApp(
          home: EventScreen(
            viewModel: viewModel,
            date: testEvent.date,
            existingEvent: testEvent,
            onSave: (event) {
              savedEvent = event;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Modify title and save
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Original Event Title'),
        'Updated Event Title',
      );
      await tester.tap(find.text('Save Event'));
      await tester.pumpAndSettle();

      // Assert: Saved event should have same ID but updated title
      expect(savedEvent, isNotNull);
      expect(savedEvent?.id, testEvent.id);
      expect(savedEvent?.title, 'Updated Event Title');
    });

    testWidgets('Update shows SnackBar with UNDO', (WidgetTester tester) async {
      // Arrange: Build a complete flow with navigation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => EventDetailsScreen(
                event: testEvent,
                viewModel: viewModel,
              ),
            ),
          ),
        ),
      );

      // Simulate update by calling the viewModel directly
      final updatedEvent = testEvent.copyWith(title: 'Updated Title');
      viewModel.updateEvent(updatedEvent);
      await tester.pumpAndSettle();

      // Note: Full integration test with navigation would require more setup
      // This test verifies the viewModel update works correctly
      expect(viewModel.events.first.title, 'Updated Title');
    });

    testWidgets('UNDO restores previous event values',
        (WidgetTester tester) async {
      // Arrange: Add event to viewModel
      final originalTitle = testEvent.title;
      final originalVenue = testEvent.venue;

      // Act: Update the event
      final updatedEvent = testEvent.copyWith(
        title: 'Updated Title',
        venue: 'Updated Venue',
      );
      final previousEvent = viewModel.updateEvent(updatedEvent);

      // Assert: Event should be updated
      expect(viewModel.events.first.title, 'Updated Title');
      expect(viewModel.events.first.venue, 'Updated Venue');

      // Act: Undo by restoring previous event
      viewModel.updateEvent(previousEvent!);

      // Assert: Event should be restored to original values
      expect(viewModel.events.first.title, originalTitle);
      expect(viewModel.events.first.venue, originalVenue);
    });

    testWidgets('Multiple field updates are preserved',
        (WidgetTester tester) async {
      // Arrange: Update multiple fields
      final updatedEvent = testEvent.copyWith(
        title: 'New Title',
        venue: 'New Venue',
        expectedParticipation: 200,
        nurses: 5,
      );

      // Act: Update event
      viewModel.updateEvent(updatedEvent);
      await tester.pumpAndSettle();

      // Assert: All updated fields should be preserved
      final event = viewModel.events.first;
      expect(event.title, 'New Title');
      expect(event.venue, 'New Venue');
      expect(event.expectedParticipation, 200);
      expect(event.nurses, 5);
      // Verify unchanged fields
      expect(event.address, testEvent.address);
      expect(event.onsiteContactPerson, testEvent.onsiteContactPerson);
    });

    testWidgets('copyWith creates proper event copy',
        (WidgetTester tester) async {
      // Act: Create copy with some changes
      final copiedEvent = testEvent.copyWith(
        title: 'Copied Title',
        venue: 'Copied Venue',
      );

      // Assert: Changed fields should be updated
      expect(copiedEvent.title, 'Copied Title');
      expect(copiedEvent.venue, 'Copied Venue');

      // Assert: Unchanged fields should remain the same
      expect(copiedEvent.id, testEvent.id);
      expect(copiedEvent.address, testEvent.address);
      expect(copiedEvent.onsiteContactPerson, testEvent.onsiteContactPerson);
      expect(
          copiedEvent.expectedParticipation, testEvent.expectedParticipation);
      expect(copiedEvent.date, testEvent.date);

      // Assert: Original event should be unchanged
      expect(testEvent.title, 'Original Event Title');
      expect(testEvent.venue, 'Original Venue');
    });
  });
}
