/* import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/data/repositories_dcl/event_repository.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_view_model.dart';

WellnessEvent _buildEvent({
  String id = 'event-1',
  String title = 'Test Event',
}) {
  return WellnessEvent(
    id: id,
    title: title,
    date: DateTime(2024, 1, 1),
    venue: 'Main Venue',
    address: '123 Main Road',
    onsiteContactFirstName: 'John',
    onsiteContactLastName: 'Doe',
    onsiteContactNumber: '0123456789',
    onsiteContactEmail: 'john@example.com',
    aeContactFirstName: 'Jane',
    aeContactLastName: 'Doe',
    aeContactNumber: '0987654321',
    aeContactEmail: 'jane@example.com',
    servicesRequested: 'HRA',
    expectedParticipation: 50,
    nonMembers: 5,
    passports: 2,
    nurses: 3,
    coordinators: 1,
    multiplyPromoters: 1,
    setUpTime: '08:00 AM',
    startTime: '09:00 AM',
    endTime: '05:00 PM',
    strikeDownTime: '06:00 PM',
    mobileBooths: 'Yes',
    medicalAid: 'Yes',
  );
}

void main() {
  late AppDatabase database;
  late EventRepository repository;
  late EventViewModel viewModel;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = EventRepository(database: database);
    viewModel = EventViewModel(repository: repository);
    await viewModel.initialized;
  });

  tearDown(() async {
    viewModel.dispose();
    await database.close();
  });

  test('addEvent stores event in memory and database', () async {
    final event = _buildEvent();

    await viewModel.addEvent(event);

    expect(viewModel.events.length, 1);
    final stored = await repository.fetchEventById(event.id);
    expect(stored, isNotNull);
    expect(stored?.title, event.title);
  });

  test('deleteEvent removes event and returns previous copy', () async {
    final event = _buildEvent(id: 'event-delete');
    await viewModel.addEvent(event);

    final deleted = await viewModel.deleteEvent(event.id);

    expect(deleted, isNotNull);
    expect(viewModel.events, isEmpty);
    final stored = await repository.fetchEventById(event.id);
    expect(stored, isNull);
  });

  test('restoreEvent re-adds an event after deletion', () async {
    final event = _buildEvent(id: 'event-restore');
    await viewModel.addEvent(event);
    final deleted = await viewModel.deleteEvent(event.id);
    expect(viewModel.events, isEmpty);

    await viewModel.restoreEvent(deleted!);

    expect(viewModel.events.length, 1);
    expect(viewModel.events.first.id, event.id);
  });

  test('updateEvent returns previous value and applies changes', () async {
    final event = _buildEvent(id: 'event-update');
    await viewModel.addEvent(event);

    final updatedEvent = event.copyWith(title: 'Updated Title', nurses: 5);
    final previous = await viewModel.updateEvent(updatedEvent);

    expect(previous, isNotNull);
    expect(previous?.title, event.title);
    expect(viewModel.events.first.title, 'Updated Title');
    expect(viewModel.events.first.nurses, 5);
  });

  test('markEventInProgress and markEventCompleted update status', () async {
    final event = _buildEvent(id: 'event-progress');
    await viewModel.addEvent(event);

    final inProgress = await viewModel.markEventInProgress(event.id);
    expect(inProgress?.status, WellnessEventStatus.inProgress);
    expect(inProgress?.actualStartTime, isNotNull);

    final completed = await viewModel.markEventCompleted(event.id);
    expect(completed?.status, WellnessEventStatus.completed);
    expect(completed?.actualEndTime, isNotNull);
  });
} */
