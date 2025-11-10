import 'package:flutter/foundation.dart';
import '../domain/models/wellness_event.dart';

class EventProvider with ChangeNotifier {
  final Map<DateTime, List<WellnessEvent>> _events = {};

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Map<DateTime, List<WellnessEvent>> get events => _events;

  // ✅ Get events for a specific day
  List<WellnessEvent> getEventsForDay(DateTime day) =>
      _events[_normalizeDate(day)] ?? [];

  // ✅ Get events for a month
  List<WellnessEvent> getEventsForMonth(DateTime month) {
    return _events.entries
        .where(
          (entry) =>
              entry.key.year == month.year && entry.key.month == month.month,
        )
        .expand((entry) => entry.value)
        .toList();
  }

  // ✅ Add or update an event
  void addEvent(WellnessEvent event) {
    final key = _normalizeDate(event.date);
    _events.putIfAbsent(key, () => []);
    _events[key]!.add(event);
    notifyListeners();
  }

  // ✅ Optional: Remove an event
  void removeEvent(WellnessEvent event) {
    final key = _normalizeDate(event.date);
    if (_events[key] != null) {
      _events[key]!.remove(event);
      if (_events[key]!.isEmpty) _events.remove(key);
      notifyListeners();
    }
  }

  // ✅ Optional: Clear all events (e.g. after logout)
  void clearEvents() {
    _events.clear();
    notifyListeners();
  }
}
