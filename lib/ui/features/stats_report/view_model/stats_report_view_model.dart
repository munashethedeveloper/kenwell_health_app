import 'package:flutter/material.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import '../../../../data/repositories_dcl/firestore_member_event_repository.dart';
import '../../../../domain/models/wellness_event.dart';

/// Immutable snapshot of aggregated event statistics.
///
/// Computed by [StatsReportViewModel.computeStats] from a filtered event list.
/// Passing this value object to widgets avoids re-computing stats on every
/// build call.
class EventStats {
  const EventStats({
    required this.totalExpected,
    required this.totalScreened,
    required this.completedCount,
    required this.scheduledCount,
    required this.inProgressCount,
    required this.participationRate,
    required this.eventsByProvince,
  });

  /// Zero-value instance returned when there are no events.
  static const EventStats empty = EventStats(
    totalExpected: 0,
    totalScreened: 0,
    completedCount: 0,
    scheduledCount: 0,
    inProgressCount: 0,
    participationRate: 0,
    eventsByProvince: {},
  );

  final int totalExpected;
  final int totalScreened;
  final int completedCount;
  final int scheduledCount;
  final int inProgressCount;

  /// Participation rate as a value in [0, 100].
  final double participationRate;

  /// Event count per province.
  final Map<String, int> eventsByProvince;

  String get participationRateLabel =>
      '${participationRate.toStringAsFixed(1)}%';
}

class StatsReportViewModel extends ChangeNotifier {
  StatsReportViewModel({
    FirestoreMemberRepository? memberRepository,
    FirestoreMemberEventRepository? memberEventRepository,
  })  : _memberRepository = memberRepository ?? FirestoreMemberRepository(),
        _memberEventRepository =
            memberEventRepository ?? FirestoreMemberEventRepository() {
    for (final controller in _allControllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  final FirestoreMemberRepository _memberRepository;
  final FirestoreMemberEventRepository _memberEventRepository;

  final formKey = GlobalKey<FormState>();

  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController expectedParticipationController =
      TextEditingController();
  final TextEditingController registeredController = TextEditingController();
  final TextEditingController screenedController = TextEditingController();

  DateTime? eventDate;
  bool isLoading = false;

  // ── Member count ──────────────────────────────────────────────────────────

  int _memberCount = 0;
  bool _isLoadingMemberCount = false;

  int get memberCount => _memberCount;
  bool get isLoadingMemberCount => _isLoadingMemberCount;

  int _registeredCount = 0;
  bool _isLoadingRegisteredCount = false;

  int get registeredCount => _registeredCount;
  bool get isLoadingRegisteredCount => _isLoadingRegisteredCount;

  /// Fetches the number of members registered (via member_events) for the
  /// given [eventIds]. Use this on the live stats screen instead of the
  /// global member count.
  Future<void> loadRegisteredCountForEvents(List<String> eventIds) async {
    if (eventIds.isEmpty) {
      _registeredCount = 0;
      notifyListeners();
      return;
    }
    _isLoadingRegisteredCount = true;
    notifyListeners();
    try {
      _registeredCount =
          await _memberEventRepository.countRegisteredMembersForEvents(eventIds);
    } catch (_) {
      // Non-fatal — keep previous count.
    } finally {
      _isLoadingRegisteredCount = false;
      notifyListeners();
    }
  }

  /// Fetches the total number of registered members and notifies listeners.
  Future<void> loadMemberCount() async {
    _isLoadingMemberCount = true;
    notifyListeners();
    try {
      final members = await _memberRepository.fetchAllMembers();
      _memberCount = members.length;
    } catch (_) {
      // Non-fatal — keep previous count.
    } finally {
      _isLoadingMemberCount = false;
      notifyListeners();
    }
  }

  List<TextEditingController> get _allControllers => [
        eventTitleController,
        eventDateController,
        startTimeController,
        endTimeController,
        expectedParticipationController,
        registeredController,
        screenedController,
      ];

  bool get canSubmit =>
      eventTitleController.text.trim().isNotEmpty && eventDate != null;

  void _onFieldChanged() {
    notifyListeners();
  }

  void setEventDate(DateTime date) {
    eventDate = date;
    notifyListeners();
  }

  /// Stores a time string (HH:mm) in [controller] and notifies listeners.
  /// Call this from the UI after showing a [showTimePicker] dialog.
  void setTimeFromPicked(TimeOfDay picked, TextEditingController controller) {
    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    controller.text = '$hh:$mm';
    notifyListeners();
  }

  // ── Filter helpers ────────────────────────────────────────────────────────

  /// Filters [allEvents] by live/past tab selection and optional user filters.
  ///
  /// This is a **pure** helper — it does not mutate any ViewModel state, so it
  /// can be called freely from `build()` methods without side effects.
  List<WellnessEvent> applyFilters(
    List<WellnessEvent> allEvents, {
    required bool isLiveTab,
    String? searchQuery,
    String? statusFilter,
    String? provinceFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Tab-level filter: live vs past.
    var events = isLiveTab
        ? allEvents.where((e) {
            final s = e.status.toLowerCase();
            final isActive = s == 'in_progress' || s == 'in progress' || s == 'ongoing';
            if (!isActive) return false;
            final d = DateTime(e.date.year, e.date.month, e.date.day);
            return d == today;
          }).toList()
        : allEvents.where((e) {
            final s = e.status.toLowerCase();
            return s == 'completed' || s == 'finished';
          }).toList();

    // Search filter.
    final query = (searchQuery ?? '').toLowerCase();
    if (query.isNotEmpty) {
      events = events
          .where((e) => e.title.toLowerCase().contains(query))
          .toList();
    }

    // Status filter.
    if (statusFilter != null && statusFilter != 'All') {
      events = events.where((e) {
        final s = e.status.toLowerCase();
        if (statusFilter == 'Scheduled') return s == 'scheduled';
        if (statusFilter == 'In Progress') {
          return s == 'in progress' || s == 'in_progress' || s == 'ongoing';
        }
        if (statusFilter == 'Completed') {
          return s == 'completed' || s == 'finished';
        }
        return true;
      }).toList();
    }

    // Province filter.
    if (provinceFilter != null && provinceFilter != 'All') {
      events = events.where((e) => e.province == provinceFilter).toList();
    }

    // Date-range filter.
    if (startDate != null) {
      events = events
          .where((e) => !e.date.isBefore(
                DateTime(startDate.year, startDate.month, startDate.day),
              ))
          .toList();
    }
    if (endDate != null) {
      events = events
          .where((e) => !e.date.isAfter(
                DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
              ))
          .toList();
    }

    return events;
  }

  /// Computes aggregated [EventStats] from a (pre-filtered) event list.
  ///
  /// This is a **pure** helper — it does not mutate any ViewModel state.
  EventStats computeStats(List<WellnessEvent> events) {
    if (events.isEmpty) return EventStats.empty;

    final totalExpected =
        events.fold<int>(0, (s, e) => s + e.expectedParticipation);
    final totalScreened =
        events.fold<int>(0, (s, e) => s + e.screenedCount);

    final completedCount = events
        .where((e) =>
            e.status.toLowerCase() == 'completed' ||
            e.status.toLowerCase() == 'finished')
        .length;
    final scheduledCount = events
        .where((e) => e.status.toLowerCase() == 'scheduled')
        .length;
    final inProgressCount = events
        .where((e) =>
            e.status.toLowerCase() == 'in_progress' ||
            e.status.toLowerCase() == 'in progress' ||
            e.status.toLowerCase() == 'ongoing')
        .length;

    final participationRate =
        totalExpected > 0 ? totalScreened / totalExpected * 100 : 0.0;

    final Map<String, int> eventsByProvince = {};
    for (final event in events) {
      final p = event.province.isNotEmpty ? event.province : 'Unknown';
      eventsByProvince[p] = (eventsByProvince[p] ?? 0) + 1;
    }

    return EventStats(
      totalExpected: totalExpected,
      totalScreened: totalScreened,
      completedCount: completedCount,
      scheduledCount: scheduledCount,
      inProgressCount: inProgressCount,
      participationRate: participationRate,
      eventsByProvince: eventsByProvince,
    );
  }

  Future<bool> generateReport() async {
    if (!canSubmit) return false;

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint(
        'Stats report generated for ${eventTitleController.text} on $eventDate',
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error generating report: $e\n$stackTrace');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller
        ..removeListener(_onFieldChanged)
        ..dispose();
    }
    super.dispose();
  }
}
