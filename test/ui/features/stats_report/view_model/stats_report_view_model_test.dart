import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_event_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/stats_report/view_model/stats_report_view_model.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────────

class MockMemberRepo extends Mock implements FirestoreMemberRepository {}
class MockMemberEventRepo extends Mock implements FirestoreMemberEventRepository {}

// ── Helpers ────────────────────────────────────────────────────────────────────

WellnessEvent _buildEvent({
  String id = 'e-1',
  String title = 'Health Day',
  String status = WellnessEventStatus.scheduled,
  String province = 'Gauteng',
  int expectedParticipation = 100,
  int screenedCount = 0,
  DateTime? date,
}) =>
    WellnessEvent(
      id: id,
      title: title,
      date: date ?? DateTime(2025, 6, 1),
      venue: 'Hall',
      address: '1 Main Rd',
      townCity: 'Johannesburg',
      province: province,
      onsiteContactFirstName: 'Alice',
      onsiteContactLastName: 'Smith',
      onsiteContactNumber: '011000001',
      onsiteContactEmail: 'alice@ex.com',
      aeContactFirstName: 'Bob',
      aeContactLastName: 'Jones',
      aeContactNumber: '011000002',
      aeContactEmail: 'bob@ex.com',
      servicesRequested: 'HRA',
      expectedParticipation: expectedParticipation,
      nurses: 2,
      setUpTime: '07:00',
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'Discovery',
      status: status,
      screenedCount: screenedCount,
    );

/// Creates a VM with lightweight mocks so that the purely functional
/// [computeStats] / [applyFilters] methods can be exercised without any
/// network calls.
StatsReportViewModel _buildViewModel() => StatsReportViewModel(
      memberRepository: MockMemberRepo(),
      memberEventRepository: MockMemberEventRepo(),
    );

void main() {
  group('StatsReportViewModel.computeStats – empty input', () {
    test('returns EventStats.empty when list is empty', () {
      final vm = _buildViewModel();
      final stats = vm.computeStats([]);

      expect(stats.totalExpected, 0);
      expect(stats.totalScreened, 0);
      expect(stats.completedCount, 0);
      expect(stats.participationRate, 0);
      expect(stats.eventsByProvince, isEmpty);
    });
  });

  group('StatsReportViewModel.computeStats – aggregation', () {
    test('sums expected and screened counts across events', () {
      final events = [
        _buildEvent(id: 'e-1', expectedParticipation: 100, screenedCount: 80),
        _buildEvent(id: 'e-2', expectedParticipation: 50, screenedCount: 30),
      ];
      final vm = _buildViewModel();
      final stats = vm.computeStats(events);

      expect(stats.totalExpected, 150);
      expect(stats.totalScreened, 110);
    });

    test('computes participationRate correctly', () {
      final events = [
        _buildEvent(id: 'e-rate', expectedParticipation: 200, screenedCount: 100),
      ];
      final vm = _buildViewModel();
      final stats = vm.computeStats(events);

      expect(stats.participationRate, closeTo(50.0, 0.01));
    });

    test('participationRate is 0 when expectedParticipation is 0', () {
      final events = [
        _buildEvent(id: 'e-zero', expectedParticipation: 0, screenedCount: 0),
      ];
      final vm = _buildViewModel();
      final stats = vm.computeStats(events);

      expect(stats.participationRate, 0);
    });

    test('counts events by status correctly', () {
      final events = [
        _buildEvent(id: 'e-s1', status: WellnessEventStatus.scheduled),
        _buildEvent(id: 'e-s2', status: WellnessEventStatus.scheduled),
        _buildEvent(id: 'e-ip', status: WellnessEventStatus.inProgress),
        _buildEvent(id: 'e-c1', status: WellnessEventStatus.completed),
        _buildEvent(id: 'e-c2', status: WellnessEventStatus.completed),
        _buildEvent(id: 'e-c3', status: WellnessEventStatus.completed),
      ];
      final vm = _buildViewModel();
      final stats = vm.computeStats(events);

      expect(stats.scheduledCount, 2);
      expect(stats.inProgressCount, 1);
      expect(stats.completedCount, 3);
    });

    test('groups events by province', () {
      final events = [
        _buildEvent(id: 'p1', province: 'Gauteng'),
        _buildEvent(id: 'p2', province: 'Gauteng'),
        _buildEvent(id: 'p3', province: 'Western Cape'),
      ];
      final vm = _buildViewModel();
      final stats = vm.computeStats(events);

      expect(stats.eventsByProvince['Gauteng'], 2);
      expect(stats.eventsByProvince['Western Cape'], 1);
    });

    test('uses "Unknown" province for events with empty province', () {
      final event = WellnessEvent(
        id: 'no-province',
        title: 'X',
        date: DateTime(2025, 6, 1),
        venue: 'V',
        address: 'A',
        townCity: 'T',
        province: '', // empty
        onsiteContactFirstName: 'A',
        onsiteContactLastName: 'B',
        onsiteContactNumber: '0',
        onsiteContactEmail: 'a@b.com',
        aeContactFirstName: 'C',
        aeContactLastName: 'D',
        aeContactNumber: '0',
        aeContactEmail: 'c@d.com',
        servicesRequested: 'HRA',
        expectedParticipation: 10,
        nurses: 1,
        setUpTime: '07:00',
        startTime: '08:00',
        endTime: '16:00',
        strikeDownTime: '17:00',
        mobileBooths: 'No',
        medicalAid: 'None',
      );
      final vm = _buildViewModel();
      final stats = vm.computeStats([event]);

      expect(stats.eventsByProvince.containsKey('Unknown'), isTrue);
    });
  });

  group('StatsReportViewModel.applyFilters – live tab', () {
    test('live tab returns only in-progress events on today', () {
      final today = DateTime.now();
      final inProgress = _buildEvent(
        id: 'live-1',
        status: WellnessEventStatus.inProgress,
        date: today,
      );
      final scheduled = _buildEvent(
        id: 'sched-1',
        status: WellnessEventStatus.scheduled,
        date: today,
      );
      final vm = _buildViewModel();

      final result = vm.applyFilters([inProgress, scheduled], isLiveTab: true);

      expect(result.length, 1);
      expect(result.first.id, 'live-1');
    });

    test('live tab excludes in-progress events from other days', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final inProgressYesterday = _buildEvent(
        id: 'old-live',
        status: WellnessEventStatus.inProgress,
        date: yesterday,
      );
      final vm = _buildViewModel();

      final result = vm.applyFilters([inProgressYesterday], isLiveTab: true);

      expect(result, isEmpty);
    });
  });

  group('StatsReportViewModel.applyFilters – past tab', () {
    test('past tab returns only completed events', () {
      final completed = _buildEvent(
          id: 'past-c', status: WellnessEventStatus.completed);
      final scheduled = _buildEvent(
          id: 'past-s', status: WellnessEventStatus.scheduled);
      final inProgress = _buildEvent(
          id: 'past-ip', status: WellnessEventStatus.inProgress);
      final vm = _buildViewModel();

      final result = vm.applyFilters(
        [completed, scheduled, inProgress],
        isLiveTab: false,
      );

      expect(result.length, 1);
      expect(result.first.id, 'past-c');
    });
  });

  group('StatsReportViewModel.applyFilters – search', () {
    test('search filter narrows by title (case-insensitive)', () {
      final a = _buildEvent(
          id: 'a', title: 'Cape Town Health Day',
          status: WellnessEventStatus.completed);
      final b = _buildEvent(
          id: 'b', title: 'Johannesburg Wellness',
          status: WellnessEventStatus.completed);
      final vm = _buildViewModel();

      final result = vm.applyFilters(
        [a, b],
        isLiveTab: false,
        searchQuery: 'cape town',
      );

      expect(result.length, 1);
      expect(result.first.id, 'a');
    });
  });

  group('StatsReportViewModel.applyFilters – province filter', () {
    test('province filter narrows events to matching province', () {
      final gp = _buildEvent(
          id: 'gp', province: 'Gauteng',
          status: WellnessEventStatus.completed);
      final wc = _buildEvent(
          id: 'wc', province: 'Western Cape',
          status: WellnessEventStatus.completed);
      final vm = _buildViewModel();

      final result = vm.applyFilters(
        [gp, wc],
        isLiveTab: false,
        provinceFilter: 'Gauteng',
      );

      expect(result.length, 1);
      expect(result.first.id, 'gp');
    });

    test('"All" province filter returns all events', () {
      final events = [
        _buildEvent(id: 'g', province: 'Gauteng', status: WellnessEventStatus.completed),
        _buildEvent(id: 'w', province: 'Western Cape', status: WellnessEventStatus.completed),
      ];
      final vm = _buildViewModel();

      final result = vm.applyFilters(events, isLiveTab: false, provinceFilter: 'All');

      expect(result.length, 2);
    });
  });

  group('StatsReportViewModel.applyFilters – date range', () {
    test('startDate excludes events before the range', () {
      final old = _buildEvent(
          id: 'old',
          date: DateTime(2024, 1, 1),
          status: WellnessEventStatus.completed);
      final recent = _buildEvent(
          id: 'recent',
          date: DateTime(2025, 6, 1),
          status: WellnessEventStatus.completed);
      final vm = _buildViewModel();

      final result = vm.applyFilters(
        [old, recent],
        isLiveTab: false,
        startDate: DateTime(2025, 1, 1),
      );

      expect(result.length, 1);
      expect(result.first.id, 'recent');
    });

    test('endDate excludes events after the range', () {
      final future = _buildEvent(
          id: 'future',
          date: DateTime(2026, 12, 31),
          status: WellnessEventStatus.completed);
      final past = _buildEvent(
          id: 'past',
          date: DateTime(2024, 6, 1),
          status: WellnessEventStatus.completed);
      final vm = _buildViewModel();

      final result = vm.applyFilters(
        [future, past],
        isLiveTab: false,
        endDate: DateTime(2025, 1, 1),
      );

      expect(result.length, 1);
      expect(result.first.id, 'past');
    });
  });

  group('EventStats.participationRateLabel', () {
    test('formats to one decimal place with percent sign', () {
      const stats = EventStats(
        totalExpected: 200,
        totalScreened: 153,
        completedCount: 1,
        scheduledCount: 0,
        inProgressCount: 0,
        participationRate: 76.5,
        eventsByProvince: {},
      );

      expect(stats.participationRateLabel, '76.5%');
    });
  });
}
