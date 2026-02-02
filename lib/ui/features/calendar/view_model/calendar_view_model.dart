import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../data/repositories_dcl/event_repository.dart';
import '../../../../utils/event_color_helper.dart';

/// ViewModel for managing calendar state and events
class CalendarViewModel extends ChangeNotifier {
  /// Constructor with optional repository for dependency injection
  CalendarViewModel({EventRepository? repository})
      : _repository = repository ?? EventRepository() {
    _initializationFuture = loadEvents();
  }

  // Repository for data operations
  final EventRepository _repository;
  late final Future<void> _initializationFuture;

  // Getter for initialization future
  Future<void> get initializationFuture => _initializationFuture;

  // Internal state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<WellnessEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  String _role = '';

  // Public getters
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<WellnessEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get role => _role;

  /// Load events from the repository
  Future<void> loadEvents() async {
    // Set loading state
    _isLoading = true;
    _error = null;
    // Notify listeners about state changes
    notifyListeners();

    // Fetch events
    try {
      final fetchedEvents = await _repository.fetchAllEvents();
      _events = fetchedEvents;
      // Don't set error if list is empty - that's a valid state
    } catch (e) {
      // Only set error for actual failures (network, database errors, etc.)
      _error = 'Failed to load events: $e';
      _events = []; // Ensure events list is always initialized
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Methods to update state
  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  // Set selected day (can be null to clear selection)
  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  // Clear selected day
  void clearSelectedDay() {
    _selectedDay = null;
    notifyListeners();
  }

  // Normalize date to remove time component
  DateTime normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Get events for a specific day
  List<WellnessEvent> getEventsForDay(DateTime day) {
    // Normalize input date
    final normalized = normalizeDate(day);
    // Filter events matching the normalized date
    return _events
        .where((event) => normalizeDate(event.date) == normalized)
        .toList();
  }

  // Get events for a specific month
  List<WellnessEvent> getEventsForMonth(DateTime month) {
    // Filter events matching the month and year
    return _events
        .where((event) =>
            event.date.year == month.year && event.date.month == month.month)
        .toList();
  }

  // Get total events in a specific month
  int getTotalEventsThisMonth(DateTime month) =>
      getEventsForMonth(month).length;

  // Get count of upcoming events
  int getUpcomingEvents() {
    final today = DateTime.now();
    return _events.where((e) => e.date.isAfter(today)).length;
  }

  // Add a new event
  Future<void> addEvent(WellnessEvent event) async {
    try {
      await _repository.addEvent(event);
      // Update local list instead of full reload
      _events = [..._events, event];
      _error = null; // Clear any previous errors on success
      notifyListeners();
    } catch (e) {
      // Set error state
      _error = 'Failed to add event: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  // Update an existing event
  Future<void> updateEvent(WellnessEvent event) async {
    try {
      await _repository.updateEvent(event);
      // Update local list instead of full reload
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
        _events = [..._events]; // Create new list to trigger rebuild
        _error = null; // Clear any previous errors on success
        notifyListeners();
      } else {
        // Event not found locally, reload to sync
        await loadEvents();
      }
    } catch (e) {
      // Set error state
      _error = 'Failed to update event: $e';
      debugPrint(_error);
      notifyListeners();
      // Rethrow to allow higher-level handling if needed
      rethrow;
    }
  }

  // Delete an event by ID
  Future<WellnessEvent?> deleteEvent(String eventId) async {
    try {
      // Use firstWhere with orElse to avoid StateError
      final event = _events.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );
      await _repository.deleteEvent(eventId);
      // Update local list instead of full reload
      _events = _events.where((e) => e.id != eventId).toList();
      notifyListeners();
      return event; // Return for undo functionality
    } catch (e) {
      _error = 'Failed to delete event: $e';
      debugPrint(_error);
      notifyListeners();
      // Reload to ensure consistency if delete failed
      await loadEvents();
      return null;
    }
  }

  // Restore a deleted event
  Future<void> restoreEvent(WellnessEvent event) async {
    await addEvent(event);
  }

  // Navigate to previous month
  void goToPreviousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    notifyListeners();
  }

  // Navigate to next month
  void goToNextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
  }

  // HELPER METHODS for UI
  // Get color for a specific event category
  Color getCategoryColor(String servicesRequested) {
    return EventColorHelper.getCategoryColor(servicesRequested);
  }

  // Get icon for a specific service
  IconData getServiceIcon(String service) {
    return EventColorHelper.getServiceIcon(service);
  }

  // Compare two events for sorting
  int compareEvents(WellnessEvent a, WellnessEvent b) {
    // First compare by date
    final dateComparison = a.date.compareTo(b.date);
    // If dates differ, return that comparison
    if (dateComparison != 0) return dateComparison;

    // If dates are the same, compare by start time
    final aMinutes = _timeStringToMinutes(a.startTime);
    final bMinutes = _timeStringToMinutes(b.startTime);

    // If both have valid times, compare them
    if (aMinutes != null && bMinutes != null) {
      // Compare start times
      final timeComparison = aMinutes.compareTo(bMinutes);
      // If times differ, return that comparison
      if (timeComparison != 0) {
        return timeComparison;
      }
      // If times are the same, fall through to title comparison
    } else if (aMinutes != null) {
      return -1;
      // a has a time, b does not - a comes first
    } else if (bMinutes != null) {
      return 1;
      // b has a time, a does not - b comes first
    }

    // Finally, compare by title alphabetically
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  // Convert time string to total minutes since midnight
  int? _timeStringToMinutes(String raw) {
    // Return null for empty strings
    if (raw.trim().isEmpty) return null;
    // Trim whitespace for consistent parsing
    final timeText = raw.trim();

    // Try multiple common time formats
    final formatters = <DateFormat>[DateFormat.Hm(), DateFormat.jm()];

    // Attempt parsing with each formatter
    for (final formatter in formatters) {
      // Try parsing with the current formatter
      try {
        final parsed = formatter.parse(timeText);
        // If successful, calculate total minutes
        return parsed.hour * 60 + parsed.minute;
      } catch (_) {
        // Ignore parse errors and try next formatter
        continue;
      }
    }

    // Fallback: Try regex parsing for "HH:MM" format
    final match =
        RegExp(r'^(?<hour>\d{1,2}):(?<minute>\d{2})').firstMatch(timeText);
    // If regex matches, extract hour and minute
    if (match != null) {
      // Parse hour and minute from named groups
      final hour = int.tryParse(match.namedGroup('hour') ?? '');
      final minute = int.tryParse(match.namedGroup('minute') ?? '');
      // Validate and return total minutes
      if (hour != null && minute != null && hour < 24 && minute < 60) {
        return hour * 60 + minute;
      }
    }

    // If all parsing attempts fail, return null
    return null;
  }

  // Get subtitle string for an event
  String getEventSubtitle(WellnessEvent event) {
    // Build parts of the subtitle
    final parts = <String>[];
    // Add date part
    final times = [
      if (event.startTime.isNotEmpty) event.startTime,
      if (event.endTime.isNotEmpty) event.endTime,
    ];
    // Add time part if available
    if (times.isNotEmpty) parts.add(times.join(' - '));

    // Add location part
    final location = event.venue.isNotEmpty
        ? event.venue
        : (event.address.isNotEmpty ? event.address : '');
    // Add location if available
    if (location.isNotEmpty) parts.add(location);

    // Join parts with separator or return default text
    return parts.isEmpty ? 'Tap to edit' : parts.join(' · ');
  }

  // Clear any existing error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ------------------ Date Formatting Helper Methods ------------------
  // These methods encapsulate formatting logic that should be in the ViewModel
  // rather than scattered throughout the UI widgets

  // Format date to short string
  String formatDateShort(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  // Format date to long string
  String formatDateLong(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  // Format date to month and year
  String formatMonthYear(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  // Format date to medium string
  String formatDateMedium(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  // Get message for no events on selected day
  String getNoEventsMessage(DateTime selectedDay) {
    return 'No events on ${formatDateShort(selectedDay)}';
  }

  // Get month-year title for the focused day
  String getMonthYearTitle() {
    return formatMonthYear(_focusedDay);
  }
}
