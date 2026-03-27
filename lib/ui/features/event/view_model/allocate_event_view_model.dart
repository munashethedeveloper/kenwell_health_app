import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/data/repositories_dcl/user_event_repository.dart';
import 'package:kenwell_health_app/data/services/user_event_service.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

/// ViewModel for the [AllocateEventScreen].
///
/// Manages which users are assigned to a given event and exposes async
/// assign/unassign operations so the UI stays free of repository calls.
class AllocateEventViewModel extends ChangeNotifier {
  AllocateEventViewModel({
    required this.event,
    UserEventRepository? repository,
  }) : _repository = repository ?? UserEventRepository();

  final WellnessEvent event;
  final UserEventRepository _repository;

  // ── State ────────────────────────────────────────────────────────────────

  final Set<String> _assignedUserIds = {};
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  Set<String> get assignedUserIds => Set.unmodifiable(_assignedUserIds);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isAssigned(String userId) => _assignedUserIds.contains(userId);

  /// Number of users currently assigned to the event.
  int get assignedCount => _assignedUserIds.length;

  // ── Load ──────────────────────────────────────────────────────────────────

  /// Loads the set of user IDs already assigned to [event].
  Future<void> loadAssignedUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ids = await _repository.fetchAssignedUserIds(event.id);
      _assignedUserIds
        ..clear()
        ..addAll(ids);
      debugPrint('AllocateEventViewModel: Loaded ${ids.length} assigned users');
    } catch (e) {
      _error = 'Failed to load assigned users: $e';
      debugPrint('AllocateEventViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Assign ────────────────────────────────────────────────────────────────

  /// Assigns [user] to the event and refreshes the assignment list.
  Future<void> assignUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserEventService.addUserEvent(event: event, user: user);
      await loadAssignedUsers();
    } catch (e) {
      _error = 'Failed to assign user: $e';
      debugPrint('AllocateEventViewModel.assignUser: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Unassign ──────────────────────────────────────────────────────────────

  /// Removes [user] from the event and refreshes the assignment list.
  Future<void> unassignUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.removeUserEvent(event.id, user.id);
      await loadAssignedUsers();
    } catch (e) {
      _error = 'Failed to unassign user: $e';
      debugPrint('AllocateEventViewModel.unassignUser: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
