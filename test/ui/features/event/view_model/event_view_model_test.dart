import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/event_repository.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/domain/usecases/add_event_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/delete_event_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/get_events_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/update_event_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/upsert_event_usecase.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_view_model.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────────

class MockEventRepository extends Mock implements EventRepository {}

class MockGetEventsUseCase extends Mock implements GetEventsUseCase {}

class MockAddEventUseCase extends Mock implements AddEventUseCase {}

class MockUpdateEventUseCase extends Mock implements UpdateEventUseCase {}

class MockDeleteEventUseCase extends Mock implements DeleteEventUseCase {}

class MockUpsertEventUseCase extends Mock implements UpsertEventUseCase {}

// ── Helpers ────────────────────────────────────────────────────────────────────

WellnessEvent _buildEvent(
        {String id = 'event-1', String title = 'Health Day'}) =>
    WellnessEvent(
      id: id,
      title: title,
      date: DateTime(2025, 6, 1),
      venue: 'Main Hall',
      address: '1 Main Road',
      townCity: 'Cape Town',
      province: 'Western Cape',
      onsiteContactFirstName: 'Alice',
      onsiteContactLastName: 'Smith',
      onsiteContactNumber: '0210000001',
      onsiteContactEmail: 'alice@example.com',
      aeContactFirstName: 'Bob',
      aeContactLastName: 'Jones',
      aeContactNumber: '0210000002',
      aeContactEmail: 'bob@example.com',
      servicesRequested: 'HRA',
      expectedParticipation: 100,
      nurses: 3,
      setUpTime: '07:00',
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'Yes',
      medicalAid: 'Discovery',
    );

// ── Builder ────────────────────────────────────────────────────────────────────

/// Creates an [EventViewModel] with all dependencies mocked.
///
/// [initialEvents] is returned by [GetEventsUseCase] (initial load) which is
/// called by `_loadPersistedEvents` in the constructor.  The repository's
/// [watchAllEvents] stream is a no-op broadcast that never emits so that tests
/// can control state manually.
EventViewModel _buildViewModel({
  required MockEventRepository mockRepo,
  required MockGetEventsUseCase getUseCase,
  required MockAddEventUseCase addUseCase,
  required MockUpdateEventUseCase updateUseCase,
  required MockDeleteEventUseCase deleteUseCase,
  required MockUpsertEventUseCase upsertUseCase,
  List<WellnessEvent> initialEvents = const [],
}) {
  // Stub the stream subscription used in the constructor.
  when(() => mockRepo.watchAllEvents()).thenAnswer((_) => const Stream.empty());
  // Stub the GetEventsUseCase used by _loadPersistedEvents.
  when(() => getUseCase()).thenAnswer((_) async => initialEvents);

  return EventViewModel(
    repository: mockRepo,
    getEventsUseCase: getUseCase,
    addEventUseCase: addUseCase,
    updateEventUseCase: updateUseCase,
    deleteEventUseCase: deleteUseCase,
    upsertEventUseCase: upsertUseCase,
  );
}

void main() {
  late MockEventRepository mockRepo;
  late MockGetEventsUseCase mockGetUseCase;
  late MockAddEventUseCase mockAddUseCase;
  late MockUpdateEventUseCase mockUpdateUseCase;
  late MockDeleteEventUseCase mockDeleteUseCase;
  late MockUpsertEventUseCase mockUpsertUseCase;

  setUp(() {
    mockRepo = MockEventRepository();
    mockGetUseCase = MockGetEventsUseCase();
    mockAddUseCase = MockAddEventUseCase();
    mockUpdateUseCase = MockUpdateEventUseCase();
    mockDeleteUseCase = MockDeleteEventUseCase();
    mockUpsertUseCase = MockUpsertEventUseCase();

    registerFallbackValue(_buildEvent());
  });

  group('EventViewModel – addEvent', () {
    test('calls AddEventUseCase and clears error state on success', () async {
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
      );
      when(() => mockAddUseCase(any())).thenAnswer((_) async {});

      await vm.initialized;
      await vm.addEvent(_buildEvent());

      verify(() => mockAddUseCase(any())).called(1);
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
    });

    test('sets errorMessage and rethrows when AddEventUseCase throws',
        () async {
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
      );
      when(() => mockAddUseCase(any())).thenThrow(Exception('network error'));

      await vm.initialized;
      await expectLater(
        vm.addEvent(_buildEvent()),
        throwsException,
      );

      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });

  group('EventViewModel – deleteEvent', () {
    test('removes event from in-memory list and calls DeleteEventUseCase',
        () async {
      final event = _buildEvent(id: 'del-1');
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
        initialEvents: [event],
      );
      when(() => mockDeleteUseCase(any())).thenAnswer((_) async {});

      await vm.initialized;
      final deleted = await vm.deleteEvent(event.id);

      expect(deleted, isNotNull);
      expect(deleted!.id, event.id);
      verify(() => mockDeleteUseCase(event.id)).called(1);
      expect(vm.isLoading, isFalse);
    });

    test('returns null when event id is not found', () async {
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
      );

      await vm.initialized;
      final result = await vm.deleteEvent('non-existent');

      expect(result, isNull);
      verifyNever(() => mockDeleteUseCase(any()));
    });

    test('sets errorMessage when DeleteEventUseCase throws', () async {
      final event = _buildEvent(id: 'del-err');
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
        initialEvents: [event],
      );
      when(() => mockDeleteUseCase(any()))
          .thenThrow(Exception('permission denied'));

      await vm.initialized;
      await expectLater(vm.deleteEvent(event.id), throwsException);

      expect(vm.errorMessage, isNotNull);
    });
  });

  group('EventViewModel – updateEvent', () {
    test('applies update and returns previous version', () async {
      final event = _buildEvent(id: 'upd-1', title: 'Original');
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
        initialEvents: [event],
      );
      when(() => mockUpdateUseCase(any())).thenAnswer((_) async {});

      await vm.initialized;
      final updated = event.copyWith(title: 'Updated');
      final previous = await vm.updateEvent(updated);

      expect(previous, isNotNull);
      expect(previous!.title, 'Original');
      verify(() => mockUpdateUseCase(any())).called(1);
    });

    test('sets errorMessage when UpdateEventUseCase throws', () async {
      final event = _buildEvent(id: 'upd-err');
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
        initialEvents: [event],
      );
      when(() => mockUpdateUseCase(any())).thenThrow(Exception('offline'));

      await vm.initialized;
      await expectLater(
        vm.updateEvent(event.copyWith(title: 'X')),
        throwsException,
      );

      expect(vm.errorMessage, isNotNull);
    });
  });

  group('EventViewModel – restoreEvent', () {
    test('re-adds a previously deleted event via UpsertEventUseCase', () async {
      final event = _buildEvent(id: 'restore-1');
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
      );
      when(() => mockUpsertUseCase(any())).thenAnswer((_) async {});

      await vm.initialized;
      await vm.restoreEvent(event);

      verify(() => mockUpsertUseCase(any())).called(1);
    });
  });

  group('EventViewModel – loading state', () {
    test('isLoading transitions false → true → false across addEvent',
        () async {
      final vm = _buildViewModel(
        mockRepo: mockRepo,
        getUseCase: mockGetUseCase,
        addUseCase: mockAddUseCase,
        updateUseCase: mockUpdateUseCase,
        deleteUseCase: mockDeleteUseCase,
        upsertUseCase: mockUpsertUseCase,
      );
      // Slow down the use case so we can observe the loading state.
      when(() => mockAddUseCase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
      });

      await vm.initialized;

      bool seenLoading = false;
      vm.addListener(() {
        if (vm.isLoading) seenLoading = true;
      });

      await vm.addEvent(_buildEvent());

      expect(seenLoading, isTrue);
      expect(vm.isLoading, isFalse);
    });
  });
}
