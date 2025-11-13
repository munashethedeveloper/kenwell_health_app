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

  /// Updates an existing event in the repository
  /// Returns the previous version of the event for undo functionality
  Future<WellnessEvent?> updateEvent(WellnessEvent updatedEvent) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockEvents.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      final previousEvent = _mockEvents[index];
      _mockEvents[index] = updatedEvent;
      return previousEvent;
    }
    return null;
  }

  void addEvent(WellnessEvent e) => _mockEvents.add(e);
}
