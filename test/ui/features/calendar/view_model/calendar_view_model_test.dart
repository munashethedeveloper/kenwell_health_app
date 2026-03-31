import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/domain/usecases/get_events_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/add_event_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/update_event_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/delete_event_usecase.dart';
import 'package:kenwell_health_app/ui/features/calendar/view_model/calendar_view_model.dart';

class MockGetEventsUseCase extends Mock implements GetEventsUseCase {}

class MockAddEventUseCase extends Mock implements AddEventUseCase {}

class MockUpdateEventUseCase extends Mock implements UpdateEventUseCase {}

class MockDeleteEventUseCase extends Mock implements DeleteEventUseCase {}

WellnessEvent _buildEvent({
  String id = 'e-1',
  String title = 'Health Day',
  DateTime? date,
  String startTime = '08:00',
  String endTime = '16:00',
}) =>
    WellnessEvent(
      id: id,
      title: title,
      date: date ?? DateTime(2025, 6, 15),
      venue: 'Hall A',
      address: '1 Main Rd',
      townCity: 'Johannesburg',
      province: 'Gauteng',
      onsiteContactFirstName: 'Alice',
      onsiteContactLastName: 'Smith',
      onsiteContactNumber: '0110000001',
      onsiteContactEmail: 'alice@ex.com',
      aeContactFirstName: 'Bob',
      aeContactLastName: 'Jones',
      aeContactNumber: '0110000002',
      aeContactEmail: 'bob@ex.com',
      servicesRequested: 'HRA',
      expectedParticipation: 100,
      nurses: 2,
      setUpTime: '07:00',
      startTime: startTime,
      endTime: endTime,
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'Discovery',
    );

CalendarViewModel _buildVM({
  MockGetEventsUseCase? get,
  MockAddEventUseCase? add,
  MockUpdateEventUseCase? update,
  MockDeleteEventUseCase? delete,
  List<WellnessEvent> preload = const [],
}) {
  final getUC = get ?? MockGetEventsUseCase();
  final addUC = add ?? MockAddEventUseCase();
  final updateUC = update ?? MockUpdateEventUseCase();
  final deleteUC = delete ?? MockDeleteEventUseCase();

  when(() => getUC()).thenAnswer((_) async => preload);

  return CalendarViewModel(
    getEventsUseCase: getUC,
    addEventUseCase: addUC,
    updateEventUseCase: updateUC,
    deleteEventUseCase: deleteUC,
  );
}

void main() {
  registerFallbackValue(_buildEvent());

  group('CalendarViewModel – initial state', () {
    test('isLoading starts true then becomes false', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      expect(vm.isLoading, isFalse);
      vm.dispose();
    });

    test('events list starts empty', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      expect(vm.events, isEmpty);
      vm.dispose();
    });

    test('selectedDay is null initially', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      expect(vm.selectedDay, isNull);
      vm.dispose();
    });

    test('error is null when events load successfully', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      expect(vm.error, isNull);
      vm.dispose();
    });
  });

  group('CalendarViewModel – loadEvents', () {
    test('populates events list on success', () async {
      final getUC = MockGetEventsUseCase();
      final events = [_buildEvent(id: 'e-1'), _buildEvent(id: 'e-2')];
      when(() => getUC()).thenAnswer((_) async => events);

      final vm = _buildVM(get: getUC, preload: events);
      await vm.loadEvents();

      expect(vm.events.length, 2);
      vm.dispose();
    });

    test('sets error and isOffline=true when use case throws', () async {
      final getUC = MockGetEventsUseCase();
      when(() => getUC()).thenThrow(Exception('network error'));

      final vm = CalendarViewModel(
        getEventsUseCase: getUC,
        addEventUseCase: MockAddEventUseCase(),
        updateEventUseCase: MockUpdateEventUseCase(),
        deleteEventUseCase: MockDeleteEventUseCase(),
      );
      await vm.loadEvents();

      expect(vm.error, isNotNull);
      expect(vm.isOffline, isTrue);
      expect(vm.events, isEmpty);
      vm.dispose();
    });
  });

  group('CalendarViewModel – day navigation', () {
    test('setFocusedDay updates focusedDay', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      final day = DateTime(2025, 9, 1);

      vm.setFocusedDay(day);
      expect(vm.focusedDay, day);
      vm.dispose();
    });

    test('setSelectedDay updates selectedDay', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      final day = DateTime(2025, 6, 15);

      vm.setSelectedDay(day);
      expect(vm.selectedDay, day);
      vm.dispose();
    });

    test('clearSelectedDay sets selectedDay to null', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      vm.setSelectedDay(DateTime(2025, 6, 15));

      vm.clearSelectedDay();
      expect(vm.selectedDay, isNull);
      vm.dispose();
    });

    test('goToNextMonth advances month by one', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      final before = vm.focusedDay;

      vm.goToNextMonth();
      expect(vm.focusedDay.month, before.month == 12 ? 1 : before.month + 1);
      vm.dispose();
    });

    test('goToPreviousMonth decrements month by one', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      final before = vm.focusedDay;

      vm.goToPreviousMonth();
      expect(vm.focusedDay.month, before.month == 1 ? 12 : before.month - 1);
      vm.dispose();
    });
  });

  group('CalendarViewModel – getEventsForDay', () {
    test('returns events on matching day', () async {
      final day = DateTime(2025, 6, 15);
      final event = _buildEvent(date: day);
      final vm = _buildVM(preload: [event]);
      await vm.loadEvents();

      final result = vm.getEventsForDay(day);
      expect(result.length, 1);
      expect(result.first.id, event.id);
      vm.dispose();
    });

    test('excludes events on different days', () async {
      final event = _buildEvent(date: DateTime(2025, 6, 15));
      final vm = _buildVM(preload: [event]);
      await vm.loadEvents();

      final result = vm.getEventsForDay(DateTime(2025, 6, 16));
      expect(result, isEmpty);
      vm.dispose();
    });
  });

  group('CalendarViewModel – getEventsForMonth', () {
    test('returns events in matching month', () async {
      final e1 = _buildEvent(id: 'a', date: DateTime(2025, 6, 1));
      final e2 = _buildEvent(id: 'b', date: DateTime(2025, 6, 30));
      final e3 = _buildEvent(id: 'c', date: DateTime(2025, 7, 1));
      final vm = _buildVM(preload: [e1, e2, e3]);
      await vm.loadEvents();

      final result = vm.getEventsForMonth(DateTime(2025, 6));
      expect(result.length, 2);
      vm.dispose();
    });
  });

  group('CalendarViewModel – addEvent', () {
    test('appends event to list', () async {
      final addUC = MockAddEventUseCase();
      when(() => addUC(any())).thenAnswer((_) async {});

      final vm = _buildVM(add: addUC);
      await vm.loadEvents();
      final event = _buildEvent();

      await vm.addEvent(event);

      expect(vm.events.any((e) => e.id == event.id), isTrue);
      vm.dispose();
    });

    test('sets error when addEvent throws', () async {
      final addUC = MockAddEventUseCase();
      when(() => addUC(any())).thenThrow(Exception('add error'));

      final vm = _buildVM(add: addUC);
      await vm.loadEvents();

      await expectLater(vm.addEvent(_buildEvent()), throwsException);
      expect(vm.error, isNotNull);
      vm.dispose();
    });
  });

  group('CalendarViewModel – updateEvent', () {
    test('replaces event in list', () async {
      final updateUC = MockUpdateEventUseCase();
      when(() => updateUC(any())).thenAnswer((_) async {});

      final original = _buildEvent(id: 'e-1', title: 'Original');
      final vm = _buildVM(update: updateUC, preload: [original]);
      await vm.loadEvents();

      final updated = _buildEvent(id: 'e-1', title: 'Updated');
      await vm.updateEvent(updated);

      expect(vm.events.first.title, 'Updated');
      vm.dispose();
    });
  });

  group('CalendarViewModel – deleteEvent', () {
    test('removes event from list and returns it', () async {
      final deleteUC = MockDeleteEventUseCase();
      when(() => deleteUC(any())).thenAnswer((_) async {});

      final event = _buildEvent(id: 'e-del');
      final vm = _buildVM(delete: deleteUC, preload: [event]);
      await vm.loadEvents();

      final returned = await vm.deleteEvent('e-del');

      expect(returned?.id, 'e-del');
      expect(vm.events.any((e) => e.id == 'e-del'), isFalse);
      vm.dispose();
    });
  });

  group('CalendarViewModel – compareEvents', () {
    test('orders earlier date before later date', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      final a = _buildEvent(id: 'a', date: DateTime(2025, 1, 1));
      final b = _buildEvent(id: 'b', date: DateTime(2025, 6, 1));

      expect(vm.compareEvents(a, b), isNegative);
      vm.dispose();
    });

    test('orders by start time when dates are equal', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      final a =
          _buildEvent(id: 'a', date: DateTime(2025, 6, 15), startTime: '08:00');
      final b =
          _buildEvent(id: 'b', date: DateTime(2025, 6, 15), startTime: '10:00');

      expect(vm.compareEvents(a, b), isNegative);
      vm.dispose();
    });
  });

  group('CalendarViewModel – formatting helpers', () {
    test('formatDateShort returns a non-empty string', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      expect(vm.formatDateShort(DateTime(2025, 6, 15)), isNotEmpty);
      vm.dispose();
    });

    test('getNoEventsMessage contains the date', () async {
      final vm = _buildVM();
      await vm.loadEvents();
      final msg = vm.getNoEventsMessage(DateTime(2025, 6, 15));
      expect(msg, contains('Jun'));
      vm.dispose();
    });
  });
}
