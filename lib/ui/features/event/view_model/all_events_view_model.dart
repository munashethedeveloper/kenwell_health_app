import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../utils/logger.dart';

enum EventSortField { date, title }

/// ViewModel for the All Events screen.
///
/// Wraps the shared [EventViewModel] events list and provides:
///   - Text search filtering by title or address.
///   - Month-based grouping/filtering with prev/next navigation.
///   - Status filtering (all, in_progress, completed, scheduled).
///   - Sort-by (date, title).
class AllEventsViewModel extends ChangeNotifier {
  AllEventsViewModel({required List<WellnessEvent> allEvents})
      : _allEvents = List.unmodifiable(allEvents) {
    searchController.addListener(_onSearchChanged);
  }

  List<WellnessEvent> _allEvents;

  bool _disposed = false;

  /// Called by [ChangeNotifierProxyProvider] when [EventViewModel] emits new
  /// events so that the displayed list is always up-to-date.
  ///
  /// [ChangeNotifierProxyProvider.update] is invoked during the widget build
  /// phase.  Calling [notifyListeners] synchronously from there would trigger a
  /// "setState() or markNeedsBuild() called during build" assertion on the
  /// [_InheritedProviderScope] that wraps this ViewModel.  Deferring via
  /// [Future.microtask] ensures the build is complete before dependent widgets
  /// are asked to rebuild.
  void updateEvents(List<WellnessEvent> events) {
    _allEvents = List.unmodifiable(events);
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });
  }

  final TextEditingController searchController = TextEditingController();

  // ── Month navigation ──────────────────────────────────────────────────────
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime get focusedMonth => _focusedMonth;

  String getMonthYearTitle() => DateFormat('MMMM yyyy').format(_focusedMonth);

  void goToPreviousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  // ── Filter / sort ─────────────────────────────────────────────────────────

  /// null = no status filter (show all statuses)
  String? _statusFilter; // 'in_progress' | 'completed' | 'scheduled' | null
  String? get statusFilter => _statusFilter;

  EventSortField _sortField = EventSortField.date;
  EventSortField get sortField => _sortField;

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSortField(EventSortField field) {
    _sortField = field;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _sortField = EventSortField.date;
    notifyListeners();
  }

  bool get hasActiveFilter =>
      _statusFilter != null || _sortField != EventSortField.date;

  // ── Filtered list ─────────────────────────────────────────────────────────

  /// Normalises a raw Firestore status string to one of the three canonical
  /// values used for filtering.
  String _normaliseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'in_progress':
      case 'in progress':
      case 'ongoing':
        return 'in_progress';
      case 'completed':
      case 'finished':
        return 'completed';
      case 'scheduled':
        return 'scheduled';
      default:
        // Log unexpected status values so they can be identified and corrected.
        AppLogger.warning(
            'AllEventsViewModel: unexpected status "$raw" — treating as scheduled');
        return 'scheduled';
    }
  }

  /// All events that match the current search query AND selected month AND
  /// status filter, sorted by the chosen sort field.
  ///
  /// When a search query is active the month filter is ignored so that
  /// the user can search across all months.
  List<WellnessEvent> get filteredEvents {
    final query = searchController.text.trim().toLowerCase();

    Iterable<WellnessEvent> base;

    if (query.isNotEmpty) {
      // Search mode: ignore month, search all events
      base = _allEvents.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.address.toLowerCase().contains(query);
      });
    } else {
      // Month mode
      base = _allEvents.where((e) =>
          e.date.year == _focusedMonth.year &&
          e.date.month == _focusedMonth.month);
    }

    // Status filter
    if (_statusFilter != null) {
      base = base.where((e) => _normaliseStatus(e.status) == _statusFilter);
    }

    // Sort
    final list = base.toList();
    if (_sortField == EventSortField.title) {
      list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else {
      list.sort((a, b) => a.date.compareTo(b.date));
    }

    return list;
  }

  /// Returns [filteredEvents] grouped by calendar day.
  ///
  /// Each entry in the map is keyed by the normalised date (midnight) and
  /// sorted ascending by date.
  Map<DateTime, List<WellnessEvent>> get groupedByDay {
    final events = filteredEvents;
    final Map<DateTime, List<WellnessEvent>> map = {};
    for (final e in events) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  void _onSearchChanged() => notifyListeners();

  void clearSearch() {
    searchController.clear();
  }

  @override
  void dispose() {
    _disposed = true;
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
