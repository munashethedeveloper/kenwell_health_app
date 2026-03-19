import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';

/// ViewModel for the All Events screen.
///
/// Wraps the shared [EventViewModel] events list and adds a live search
/// filter by event title or address.
class AllEventsViewModel extends ChangeNotifier {
  AllEventsViewModel({required List<WellnessEvent> allEvents})
      : _allEvents = List.unmodifiable(allEvents) {
    searchController.addListener(_onSearchChanged);
  }

  final List<WellnessEvent> _allEvents;
  final TextEditingController searchController = TextEditingController();

  /// All events that match the current search query.
  List<WellnessEvent> get filteredEvents {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _allEvents;
    return _allEvents.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.address.toLowerCase().contains(query);
    }).toList();
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
