import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../data/repositories_dcl/event_repository.dart';
import '../../../../data/repositories_dcl/user_event_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../domain/models/wellness_event.dart';
import 'event_view_model.dart';

/// ViewModel for [MyEventScreen].
///
/// Owns all business logic for the "my events" view:
/// - Loading the current user's assigned events (two-step: user_events → events)
/// - Auto-transitioning scheduled events to "In Progress" once their start
///   time has elapsed
/// - Button-state predicates (`canStartEvent`, `isTimeLocked`)
/// - Delegating start / finish actions to [EventViewModel]
///
/// The [EventViewModel] reference is passed in at construction time so this
/// class can call `markEventInProgress` / `markEventCompleted` without needing
/// access to a `BuildContext`.
class MyEventViewModel extends ChangeNotifier {
  MyEventViewModel({
    required EventViewModel eventViewModel,
    AuthService? authService,
    UserEventRepository? userEventRepository,
    EventRepository? eventRepository,
  })  : _eventViewModel = eventViewModel,
        _authService = authService ?? AuthService(),
        _userEventRepo = userEventRepository ?? UserEventRepository(),
        _eventRepo = eventRepository ?? EventRepository();

  final EventViewModel _eventViewModel;
  final AuthService _authService;
  final UserEventRepository _userEventRepo;
  final EventRepository _eventRepo;

  // ── State ────────────────────────────────────────────────────────────────

  List<WellnessEvent> _userEvents = [];
  String? _startingEventId;
  bool _isTransitioning = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<WellnessEvent> get userEvents => List.unmodifiable(_userEvents);
  String? get startingEventId => _startingEventId;

  // ── Data loading ──────────────────────────────────────────────────────────

  /// Fetches the events assigned to the current user.
  ///
  /// Two-step:
  ///   1. Load `user_events` mapping documents to obtain event IDs.
  ///   2. Fetch each [WellnessEvent] in parallel (failed individual fetches
  ///      are silently dropped).
  Future<void> loadUserEvents() async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      _userEvents = [];
      notifyListeners();
      return;
    }

    final userEventMaps = await _userEventRepo.fetchUserEvents(user.id);

    final eventIds = userEventMaps
        .map((m) => m['eventId'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    final results = await Future.wait(
      eventIds.map((id) async {
        try {
          return await _eventRepo.fetchEventById(id);
        } catch (err) {
          debugPrint('MyEventViewModel: Failed to fetch event "$id": $err');
          return null;
        }
      }),
    );

    _userEvents = results.whereType<WellnessEvent>().toList();
    notifyListeners();
  }

  // ── Auto-transition ───────────────────────────────────────────────────────

  /// Checks whether any scheduled events have reached their start time and
  /// transitions them to "In Progress".
  ///
  /// Safe to call from a periodic timer — a guard flag prevents concurrent
  /// executions if a previous Firestore call is still in flight.
  Future<void> autoTransitionEvents() async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    try {
      final now = DateTime.now();
      final snapshot = List<WellnessEvent>.from(_userEvents);

      final toTransition = snapshot.where((e) {
        if (e.status != WellnessEventStatus.scheduled) return false;
        final startDt = e.startDateTime;
        return startDt != null && !now.isBefore(startDt);
      }).toList();

      if (toTransition.isEmpty) {
        // Still notify so the button states rebuild as the clock advances.
        final today = DateTime(now.year, now.month, now.day);
        if (snapshot.any((e) =>
            e.status == WellnessEventStatus.scheduled &&
            eventDay(e).isAtSameMomentAs(today))) {
          notifyListeners();
        }
        return;
      }

      await Future.wait(
        toTransition.map((event) => _eventViewModel
                .updateEvent(event.copyWith(
              status: WellnessEventStatus.inProgress,
              actualStartTime: event.startDateTime,
            ))
                .catchError((Object err) {
              debugPrint(
                  'MyEventViewModel.autoTransitionEvents: failed to update ${event.id}: $err');
              return null as WellnessEvent?;
            })),
      );

      await loadUserEvents();
    } finally {
      _isTransitioning = false;
    }
  }

  // ── Event-state helpers ───────────────────────────────────────────────────

  /// Returns `true` when the "Start" / "Resume" button should be enabled.
  bool canStartEvent(WellnessEvent event) {
    if (event.status == WellnessEventStatus.inProgress) return true;
    if (event.status == WellnessEventStatus.completed) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = eventDay(event);

    if (today.isBefore(day)) return false;
    if (today.isAtSameMomentAs(day) && isTimeLocked(event, now)) return false;
    return true;
  }

  /// Returns a tooltip explaining why the start button is locked, or `null`.
  String? startEventTooltip(WellnessEvent event) {
    if (event.status != WellnessEventStatus.scheduled) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!today.isAtSameMomentAs(eventDay(event))) return null;
    if (!isTimeLocked(event, now)) return null;

    final startDt = event.startDateTime;
    return startDt != null
        ? 'Available from ${DateFormat.Hm().format(startDt)}'
        : 'Not yet available';
  }

  /// Returns `true` when the event has a start time that has not yet arrived.
  bool isTimeLocked(WellnessEvent event, DateTime now) {
    final startTime = event.startTime.trim();
    if (startTime.isEmpty) return false;
    final startDt = event.startDateTime;
    return startDt == null || now.isBefore(startDt);
  }

  /// Returns midnight (local time) for the event's date.
  DateTime eventDay(WellnessEvent event) {
    final local = event.date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Marks the event as in-progress and returns the updated event.
  ///
  /// Sets [startingEventId] while the operation is running so the caller can
  /// show a per-card loading indicator.
  Future<WellnessEvent?> startEvent(WellnessEvent event) async {
    _startingEventId = event.id;
    notifyListeners();
    try {
      return await _eventViewModel.markEventInProgress(event.id) ?? event;
    } finally {
      _startingEventId = null;
      notifyListeners();
    }
  }

  /// Marks the event as completed and refreshes the event list.
  Future<void> finishEvent(WellnessEvent event) async {
    await _eventViewModel.markEventCompleted(event.id);
    await loadUserEvents();
  }
}
