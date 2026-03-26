import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/all_events_view_model.dart';

WellnessEvent _buildEvent({
  String id = 'e-1',
  String title = 'Health Day',
  String status = 'scheduled',
  String province = 'Gauteng',
  DateTime? date,
}) =>
    WellnessEvent(
      id: id,
      title: title,
      date: date ?? DateTime(2025, 6, 15),
      venue: 'Hall',
      address: '1 Road',
      townCity: 'City',
      province: province,
      onsiteContactFirstName: 'A',
      onsiteContactLastName: 'B',
      onsiteContactNumber: '000',
      onsiteContactEmail: 'a@b.com',
      aeContactFirstName: 'C',
      aeContactLastName: 'D',
      aeContactNumber: '000',
      aeContactEmail: 'c@d.com',
      servicesRequested: 'HRA',
      expectedParticipation: 50,
      nurses: 2,
      setUpTime: '07:00',
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'None',
      status: status,
    );

void main() {
  late AllEventsViewModel viewModel;

  setUp(() {
    viewModel = AllEventsViewModel(allEvents: []);
  });

  tearDown(() => viewModel.dispose());

  group('AllEventsViewModel – initial state', () {
    test('filteredEvents is empty when no events provided', () {
      expect(viewModel.filteredEvents, isEmpty);
    });

    test('statusFilter is null', () {
      expect(viewModel.statusFilter, isNull);
    });

    test('hasActiveFilter is false', () {
      expect(viewModel.hasActiveFilter, isFalse);
    });
  });

  group('AllEventsViewModel – updateEvents', () {
    test('replaces events list', () {
      viewModel.updateEvents([_buildEvent(id: 'a'), _buildEvent(id: 'b')]);
      expect(viewModel.filteredEvents.length, 2);
    });
  });

  group('AllEventsViewModel – month navigation', () {
    test('goToNextMonth advances month', () {
      final before = viewModel.focusedMonth;
      viewModel.goToNextMonth();
      expect(viewModel.focusedMonth.month,
          before.month == 12 ? 1 : before.month + 1);
    });

    test('goToPreviousMonth decrements month', () {
      final before = viewModel.focusedMonth;
      viewModel.goToPreviousMonth();
      expect(viewModel.focusedMonth.month,
          before.month == 1 ? 12 : before.month - 1);
    });

    test('getMonthYearTitle returns non-empty string', () {
      expect(viewModel.getMonthYearTitle(), isNotEmpty);
    });
  });

  group('AllEventsViewModel – status filter', () {
    setUp(() {
      viewModel.updateEvents([
        _buildEvent(id: 'sched', status: 'scheduled'),
        _buildEvent(id: 'done', status: 'completed'),
        _buildEvent(id: 'ip', status: 'in_progress'),
      ]);
    });

    test('setStatusFilter to completed shows only completed events', () {
      viewModel.setStatusFilter('completed');
      final ids = viewModel.filteredEvents.map((e) => e.id).toList();
      expect(ids, contains('done'));
      expect(ids, isNot(contains('sched')));
    });

    test('null status filter shows all events', () {
      viewModel.setStatusFilter(null);
      expect(viewModel.filteredEvents.length, 3);
    });

    test('hasActiveFilter is true when status filter is set', () {
      viewModel.setStatusFilter('completed');
      expect(viewModel.hasActiveFilter, isTrue);
    });

    test('clearFilters resets statusFilter', () {
      viewModel.setStatusFilter('completed');
      viewModel.clearFilters();
      expect(viewModel.statusFilter, isNull);
      expect(viewModel.hasActiveFilter, isFalse);
    });
  });

  group('AllEventsViewModel – sort', () {
    test('setSortField to title sets hasActiveFilter true', () {
      viewModel.setSortField(EventSortField.title);
      expect(viewModel.hasActiveFilter, isTrue);
    });
  });

  group('AllEventsViewModel – search', () {
    test('search query filters by title (case-insensitive)', () {
      viewModel.updateEvents([
        _buildEvent(id: 'cape', title: 'Cape Town Day', status: 'scheduled'),
        _buildEvent(id: 'jhb', title: 'Johannesburg Event', status: 'scheduled'),
      ]);

      viewModel.searchController.text = 'cape';

      final ids = viewModel.filteredEvents.map((e) => e.id).toList();
      expect(ids, contains('cape'));
      expect(ids, isNot(contains('jhb')));
    });
  });

  group('AllEventsViewModel – groupedByDay', () {
    test('groups events by calendar day', () {
      final d1 = DateTime(2025, 6, 15);
      final d2 = DateTime(2025, 6, 20);
      viewModel.updateEvents([
        _buildEvent(id: 'a', date: d1),
        _buildEvent(id: 'b', date: d1),
        _buildEvent(id: 'c', date: d2),
      ]);

      final grouped = viewModel.groupedByDay;
      final key1 = DateTime(d1.year, d1.month, d1.day);
      final key2 = DateTime(d2.year, d2.month, d2.day);

      expect(grouped[key1]?.length, 2);
      expect(grouped[key2]?.length, 1);
    });
  });
}
