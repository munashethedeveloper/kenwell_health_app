import '../../../../domain/models/wellness_event.dart';

class EventRepository {
  final List<WellnessEvent> _mockEvents = [];

  Future<WellnessEvent?> fetchEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockEvents.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockEvents.removeWhere((e) => e.id == id);
  }

  void addEvent(WellnessEvent e) => _mockEvents.add(e);
}
