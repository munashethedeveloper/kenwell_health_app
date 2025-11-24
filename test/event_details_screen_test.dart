import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/ui/features/event/widgets/event_details_screen.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_view_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

void main() {
  group('EventDetailsScreen Delete Functionality', () {
    late EventViewModel viewModel;
    late WellnessEvent testEvent;

    setUp(() {
      viewModel = EventViewModel();
      testEvent = WellnessEvent(
        id: 'test-event-1',
        title: 'Test Wellness Event',
        date: DateTime(2024, 8, 15),
        venue: 'Community Center',
        address: '123 Main St',
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
        description: 'A test wellness event',
      );
      viewModel.addEvent(testEvent);
    });

    tearDown(() {
      viewModel.dispose();
    });

    testWidgets('Delete button is visible when viewModel is provided',
        (WidgetTester tester) async {
      // Arrange: Build the widget with viewModel
      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailsScreen(
            event: testEvent,
            viewModel: viewModel,
          ),
        ),
      );

      // Assert: Delete button should be visible
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byTooltip('Delete Event'), findsOneWidget);
    });

    testWidgets('Delete button is not visible when viewModel is null',
        (WidgetTester tester) async {
      // Arrange: Build the widget without viewModel
      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailsScreen(
            event: testEvent,
            viewModel: null,
          ),
        ),
      );

      // Assert: Delete button should not be visible
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('Tapping delete button shows confirmation dialog',
        (WidgetTester tester) async {
      // Arrange: Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailsScreen(
            event: testEvent,
            viewModel: viewModel,
          ),
        ),
      );

      // Act: Tap the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert: Confirmation dialog should be shown
      expect(find.text('Delete Event'), findsOneWidget);
      expect(
        find.text(
            'Are you sure you want to delete this event? You can undo this action.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Tapping Cancel in dialog dismisses it without deleting',
        (WidgetTester tester) async {
      // Arrange: Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailsScreen(
            event: testEvent,
            viewModel: viewModel,
          ),
        ),
      );

      // Act: Open dialog and tap Cancel
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert: Dialog should be dismissed and event still exists
      expect(find.text('Delete Event'), findsNothing);
      expect(viewModel.events.length, 1);
      expect(viewModel.events.first.id, 'test-event-1');
    });

    testWidgets('Tapping Delete in dialog deletes event and shows Snackbar',
        (WidgetTester tester) async {
      // Arrange: Build the widget with a scaffold to show Snackbar
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

      // Act: Open dialog and tap Delete
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert: Event should be deleted and Snackbar should appear
      expect(viewModel.events.length, 0);
      expect(find.text('Event deleted'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
    });

    testWidgets('Tapping UNDO restores the deleted event',
        (WidgetTester tester) async {
      // Arrange: Build the widget
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

      // Act: Delete the event
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(viewModel.events.length, 0);

      // Act: Tap UNDO
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      // Assert: Event should be restored
      expect(viewModel.events.length, 1);
      expect(viewModel.events.first.id, 'test-event-1');
      expect(viewModel.events.first.title, 'Test Wellness Event');
    });
  });

  group('EventDetailsScreen Edit Functionality', () {
    late EventViewModel viewModel;
    late WellnessEvent testEvent;

    setUp(() {
      viewModel = EventViewModel();
      testEvent = WellnessEvent(
        id: 'test-event-2',
        title: 'Test Wellness Event for Edit',
        date: DateTime(2024, 9, 20),
        venue: 'Community Center',
        address: '123 Main St',
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
        description: 'A test wellness event for editing',
      );
      viewModel.addEvent(testEvent);
    });

    tearDown(() {
      viewModel.dispose();
    });

    testWidgets('Edit button is visible when viewModel is provided',
        (WidgetTester tester) async {
      // Arrange: Build the widget with viewModel
      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailsScreen(
            event: testEvent,
            viewModel: viewModel,
          ),
        ),
      );

      // Assert: Edit button should be visible
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byTooltip('Edit Event'), findsOneWidget);
    });

    testWidgets('Edit button is not visible when viewModel is null',
        (WidgetTester tester) async {
      // Arrange: Build the widget without viewModel
      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailsScreen(
            event: testEvent,
            viewModel: null,
          ),
        ),
      );

      // Assert: Edit button should not be visible
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('Tapping edit button navigates to event form',
        (WidgetTester tester) async {
      bool navigationCalled = false;

      // Arrange: Build the widget with custom MaterialApp to track navigation
      await tester.pumpWidget(
        MaterialApp(
          home: EventDetailsScreen(
            event: testEvent,
            viewModel: viewModel,
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/event') {
              navigationCalled = true;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Event Form')),
                ),
              );
            }
            return null;
          },
        ),
      );

      // Act: Tap the edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Assert: Navigation should have been called
      expect(navigationCalled, isTrue);
    });
  });
}
