import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';

/// ViewModel for the All Events screen.
///
/// Wraps the shared [EventViewModel] events list and provides:
///   - Text search filtering by title or address.
///   - Month-based grouping/filtering with prev/next navigation.
class AllEventsViewModel extends ChangeNotifier {
  AllEventsViewModel({required List<WellnessEvent> allEvents})
      : _allEvents = List.unmodifiable(allEvents) {
    searchController.addListener(_onSearchChanged);
  }

  final List<WellnessEvent> _allEvents;
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

  // ── Filtered list ─────────────────────────────────────────────────────────

  /// All events that match the current search query AND selected month.
  ///
  /// When a search query is active the month filter is ignored so that
  /// the user can search across all months.
  List<WellnessEvent> get filteredEvents {
    final query = searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      // Search mode: ignore month, search all events
      return _allEvents.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.address.toLowerCase().contains(query);
      }).toList();
    }

    // Month mode: show only events in the focused month, sorted by date
    return _allEvents.where((e) {
      return e.date.year == _focusedMonth.year &&
          e.date.month == _focusedMonth.month;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _onSearchChanged() => notifyListeners();

  void clearSearch() {
    searchController.clear();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
