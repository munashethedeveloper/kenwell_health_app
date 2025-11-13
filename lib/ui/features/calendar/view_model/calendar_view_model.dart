import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<WellnessEvent>> _events = {};

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  List<WellnessEvent> get allEvents => _events.values.expand((e) => e).toList();

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<WellnessEvent> getEventsForDay(DateTime day) =>
      _events[_normalizeDate(day)] ?? [];

  List<WellnessEvent> getEventsForMonth(DateTime month) {
    return _events.entries
        .where((entry) =>
            entry.key.year == month.year && entry.key.month == month.month)
        .expand((entry) => entry.value)
        .toList();
  }

  void addEvent(WellnessEvent event) {
    final key = _normalizeDate(event.date);
    _events.putIfAbsent(key, () => []);
    _events[key]!.add(event);
    notifyListeners();
  }

  void goToPreviousMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    notifyListeners();
  }
}
