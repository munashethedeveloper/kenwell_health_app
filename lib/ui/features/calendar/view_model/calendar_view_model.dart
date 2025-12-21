import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../data/repositories_dcl/event_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel({EventRepository? repository})
      : _repository = repository ?? EventRepository() {
    _initializationFuture = loadEvents();
  }

  final EventRepository _repository;
  late final Future<void> _initializationFuture;

  Future<void> get initializationFuture => _initializationFuture;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<WellnessEvent> _events = [];
  bool _isLoading = false;
  String? _error;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<WellnessEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _repository.fetchAllEvents();
    } catch (e) {
      _error = 'Failed to load events: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  void clearSelectedDay() {
    _selectedDay = null;
    notifyListeners();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<WellnessEvent> getEventsForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    return _events
        .where((event) => _normalizeDate(event.date) == normalized)
        .toList();
  }

  List<WellnessEvent> getEventsForMonth(DateTime month) {
    return _events
        .where((event) =>
            event.date.year == month.year && event.date.month == month.month)
        .toList();
  }

  int getTotalEventsThisMonth(DateTime month) =>
      getEventsForMonth(month).length;

  int getUpcomingEvents() {
    final today = DateTime.now();
    return _events.where((e) => e.date.isAfter(today)).length;
  }

  Future<void> addEvent(WellnessEvent event) async {
    try {
      await _repository.addEvent(event);
      // Update local list instead of full reload
      _events = [..._events, event];
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add event: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEvent(WellnessEvent event) async {
    try {
      await _repository.updateEvent(event);
      // Update local list instead of full reload
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
        _events = [..._events]; // Create new list to trigger rebuild
        notifyListeners();
      } else {
        // Event not found locally, reload to sync
        await loadEvents();
      }
    } catch (e) {
      _error = 'Failed to update event: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  Future<WellnessEvent?> deleteEvent(String eventId) async {
    try {
      final event = _events.firstWhere((e) => e.id == eventId);
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

  Future<void> restoreEvent(WellnessEvent event) async {
    await addEvent(event);
  }

  void goToPreviousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
  }

  // Helper methods for UI
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'screening':
        return Colors.orange;
      case 'wellness':
        return Colors.green;
      case 'workshop':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  int compareEvents(WellnessEvent a, WellnessEvent b) {
    final dateComparison = a.date.compareTo(b.date);
    if (dateComparison != 0) return dateComparison;

    final aMinutes = _timeStringToMinutes(a.startTime);
    final bMinutes = _timeStringToMinutes(b.startTime);

    if (aMinutes != null && bMinutes != null) {
      final timeComparison = aMinutes.compareTo(bMinutes);
      if (timeComparison != 0) {
        return timeComparison;
      }
    } else if (aMinutes != null) {
      return -1;
    } else if (bMinutes != null) {
      return 1;
    }

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  int? _timeStringToMinutes(String raw) {
    if (raw.trim().isEmpty) return null;
    final timeText = raw.trim();

    final formatters = <DateFormat>[DateFormat.Hm(), DateFormat.jm()];

    for (final formatter in formatters) {
      try {
        final parsed = formatter.parse(timeText);
        return parsed.hour * 60 + parsed.minute;
      } catch (_) {
        continue;
      }
    }

    final match =
        RegExp(r'^(?<hour>\d{1,2}):(?<minute>\d{2})').firstMatch(timeText);
    if (match != null) {
      final hour = int.tryParse(match.namedGroup('hour') ?? '');
      final minute = int.tryParse(match.namedGroup('minute') ?? '');
      if (hour != null && minute != null && hour < 24 && minute < 60) {
        return hour * 60 + minute;
      }
    }

    return null;
  }

  String getEventSubtitle(WellnessEvent event) {
    final parts = <String>[];
    final times = [
      if (event.startTime.isNotEmpty) event.startTime,
      if (event.endTime.isNotEmpty) event.endTime,
    ];
    if (times.isNotEmpty) parts.add(times.join(' - '));

    final location = event.venue.isNotEmpty
        ? event.venue
        : (event.address.isNotEmpty ? event.address : '');
    if (location.isNotEmpty) parts.add(location);

    return parts.isEmpty ? 'Tap to edit' : parts.join(' · ');
  }
}
