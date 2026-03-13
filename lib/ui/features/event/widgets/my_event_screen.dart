import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories_dcl/event_repository.dart';
import '../../../../data/repositories_dcl/user_event_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../domain/models/wellness_event.dart';
import '../view_model/event_view_model.dart';
import '../../wellness/widgets/wellness_flow_page.dart';
import 'sections/my_event_tab_bar.dart';
import 'sections/my_event_empty_state.dart';
import 'sections/premium_event_card.dart';

/// Screen that lists the wellness events assigned to the currently logged-in
/// user.  Events are split into two tabs:
///   - **Today** – events whose date matches the current calendar day.
///   - **Upcoming** – events whose date is strictly after today.
///
/// A periodic [Timer] fires every minute to auto-transition any scheduled
/// events whose start time has elapsed to "In Progress" status.
class MyEventScreen extends StatefulWidget {
  const MyEventScreen({super.key});

  /// Returns the nearest [MyEventScreenState] ancestor, allowing parent
  /// screens to call [MyEventScreenState.refreshUserEvents] after navigation.
  static MyEventScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyEventScreenState>();

  @override
  State<MyEventScreen> createState() => MyEventScreenState();
}

class MyEventScreenState extends State<MyEventScreen> {
  /// Holds the ID of the event currently being started to show a loading
  /// spinner on only that card's button.
  String? _startingEventId;

  /// 0 = Today tab, 1 = Upcoming tab.
  int _selectedWeek = 0;

  List<WellnessEvent> _userEvents = [];

  /// Fires every minute to keep button states up-to-date and auto-transition
  /// scheduled events to in-progress when their start time has passed.
  Timer? _clockTimer;

  /// Guard flag to prevent concurrent calls to [_autoTransitionEvents].
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
    // Tick every minute so button states update as the clock passes the start
    // time, and scheduled events are automatically moved to "In Progress".
    _clockTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _autoTransitionEvents(),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  /// Public hook so parent screens can trigger a refresh after navigation.
  void refreshUserEvents() => _fetchUserEvents();

  // ── Data loading ────────────────────────────────────────────────────────

  /// Fetches the list of events assigned to the current user.
  ///
  /// Two-step process:
  ///   1. Load the `user_events` mapping documents to obtain event IDs.
  ///   2. Fetch the full [WellnessEvent] record for each ID in parallel.
  ///
  /// On error, individual event fetches are silently dropped rather than
  /// failing the entire list.
  Future<void> _fetchUserEvents() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();

    if (user == null) {
      if (!mounted) return;
      setState(() => _userEvents = []);
      return;
    }

    final userEventRepo = UserEventRepository();
    final eventRepo = EventRepository();

    final userEventMaps = await userEventRepo.fetchUserEvents(user.id);

    // Extract non-null, non-empty event IDs.
    final eventIds = userEventMaps
        .map((m) => m['eventId'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    // Fetch all events in parallel; failed individual fetches return null.
    final results = await Future.wait(
      eventIds.map((id) async {
        try {
          return await eventRepo.fetchEventById(id);
        } catch (err) {
          debugPrint('MyEventScreen: Failed to fetch event "\$id": \$err');
          return null;
        }
      }),
    );

    final events = results.whereType<WellnessEvent>().toList();
    if (!mounted) return;
    setState(() => _userEvents = events);
  }

  // ── Auto-transition ─────────────────────────────────────────────────────

  /// Checks every minute whether any scheduled events have reached their start
  /// time and transitions them to "In Progress".
  ///
  /// Uses [_isTransitioning] to guard against concurrent executions if a
  /// previous tick's Firestore calls are still outstanding.  Partial failures
  /// (one event failing to update) do not block the remaining events.
  Future<void> _autoTransitionEvents() async {
    if (_isTransitioning || !mounted) return;
    _isTransitioning = true;

    try {
      final now = DateTime.now();

      // Snapshot the list to avoid mutation issues if _fetchUserEvents runs
      // concurrently (e.g., from the refresh button at the same moment).
      final snapshot = List<WellnessEvent>.from(_userEvents);
      final eventVM = context.read<EventViewModel>();

      final toTransition = snapshot.where((e) {
        if (e.status != WellnessEventStatus.scheduled) return false;
        final startDt = e.startDateTime;
        return startDt != null && !now.isBefore(startDt);
      }).toList();

      if (toTransition.isEmpty) {
        // Still rebuild if any today-scheduled event's button state could
        // have changed as the minute clock advanced.
        final today = DateTime(now.year, now.month, now.day);
        if (mounted &&
            snapshot.any((e) =>
                e.status == WellnessEventStatus.scheduled &&
                _eventDay(e).isAtSameMomentAs(today))) {
          setState(() {});
        }
        return;
      }

      // Transition all elapsed events concurrently; tolerate partial failures.
      await Future.wait(
        toTransition.map((event) => eventVM
            .updateEvent(event.copyWith(
              status: WellnessEventStatus.inProgress,
              actualStartTime: event.startDateTime,
            ))
            .catchError((Object err) {
          debugPrint('_autoTransitionEvents: failed to update \${event.id}: \$err');
        })),
      );

      if (!mounted) return;
      await _fetchUserEvents();
    } finally {
      _isTransitioning = false;
    }
  }

  // ── Event state helpers ─────────────────────────────────────────────────

  /// Returns true when the "Start Event" / "Resume Event" button should be
  /// enabled for [event].
  ///
  /// Rules:
  ///   - In-progress events can always be resumed.
  ///   - Completed events cannot be restarted.
  ///   - Scheduled events must be on today's date and past their start time.
  bool _canStartEvent(WellnessEvent event) {
    if (event.status == WellnessEventStatus.inProgress) return true;
    if (event.status == WellnessEventStatus.completed) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = _eventDay(event);

    if (today.isBefore(eventDay)) return false;
    if (today.isAtSameMomentAs(eventDay) && _isTimeLocked(event, now)) {
      return false;
    }
    return true;
  }

  /// Returns a user-facing tooltip message explaining why the Start button is
  /// locked, or null when the button is available.
  String? _startEventTooltip(WellnessEvent event) {
    if (event.status != WellnessEventStatus.scheduled) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!today.isAtSameMomentAs(_eventDay(event))) return null;
    if (!_isTimeLocked(event, now)) return null;

    final startDateTime = event.startDateTime;
    return startDateTime != null
        ? 'Available from \${DateFormat.Hm().format(startDateTime)}'
        : 'Not yet available';
  }

  /// Returns true when a scheduled event has a non-empty [startTime] that
  /// either could not be parsed or has not yet been reached by [now].
  ///
  /// An empty [startTime] means there is no time restriction; the button is
  /// available all day.
  bool _isTimeLocked(WellnessEvent event, DateTime now) {
    final startTime = event.startTime.trim();
    if (startTime.isEmpty) return false;
    final startDateTime = event.startDateTime;
    return startDateTime == null || now.isBefore(startDateTime);
  }

  /// Returns midnight (local time) for the event's date.
  ///
  /// [toLocal()] handles the case where Firestore's [Timestamp.toDate()]
  /// returns a UTC [DateTime].
  DateTime _eventDay(WellnessEvent event) {
    final local = event.date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  /// Marks the event as in-progress, navigates to the [WellnessFlowPage],
  /// then refreshes the event list on return.
  Future<void> _startEvent(BuildContext context, WellnessEvent event) async {
    setState(() => _startingEventId = event.id);
    try {
      final eventVM = context.read<EventViewModel>();
      final navigator = Navigator.of(context);
      final updated = await eventVM.markEventInProgress(event.id) ?? event;
      if (!mounted) return;

      await navigator.push(
        MaterialPageRoute(
          builder: (_) => WellnessFlowPage(
            event: updated,
            onExitEarly: () async {
              // Roll back the event status when the nurse exits early.
              await eventVM.updateEvent(
                updated.copyWith(
                  status: WellnessEventStatus.scheduled,
                  actualStartTime: null,
                  actualEndTime: null,
                ),
              );
            },
          ),
        ),
      );

      if (!mounted) return;
      await _fetchUserEvents();
    } finally {
      if (mounted) setState(() => _startingEventId = null);
    }
  }

  /// Marks the event as completed and refreshes the list.
  Future<void> _finishEvent(BuildContext context, WellnessEvent event) async {
    final eventVM = context.read<EventViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    await eventVM.markEventCompleted(event.id);

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Event finished successfully')),
    );

    if (!mounted) return;
    await _fetchUserEvents();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final allEvents = _userEvents;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter events for the selected tab.
    final filteredEvents = _selectedWeek == 0
        ? allEvents.where((e) {
            final d = e.date.toLocal();
            return DateTime(d.year, d.month, d.day).isAtSameMomentAs(today);
          }).toList()
        : allEvents.where((e) {
            final d = e.date.toLocal();
            return DateTime(d.year, d.month, d.day).isAfter(today);
          }).toList();

    // Pre-calculate counts for both tabs.
    final todayCount = allEvents.where((e) {
      final d = e.date.toLocal();
      return DateTime(d.year, d.month, d.day).isAtSameMomentAs(today);
    }).length;
    final upcomingCount = allEvents.where((e) {
      final d = e.date.toLocal();
      return DateTime(d.year, d.month, d.day).isAfter(today);
    }).length;

    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: KenwellAppBar(
        title: 'KenWell365',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _fetchUserEvents();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Events refreshed'),
                    ],
                  ),
                  backgroundColor: KenwellColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              if (mounted) context.pushNamed('help');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserEvents,
        color: KenwellColors.primaryGreen,
        child: CustomScrollView(
          slivers: [
            // Gradient section header
            SliverToBoxAdapter(
              child: KenwellGradientHeader(
                label: 'MY EVENTS',
                title: _selectedWeek == 0
                    ? "Today's\nEvents"
                    : 'Upcoming\nEvents',
                subtitle: _selectedWeek == 0
                    ? 'Manage your wellness events for today.'
                    : 'Your scheduled events for the coming days.',
              ),
            ),

            // Tab bar (Today / Upcoming)
            SliverToBoxAdapter(
              child: MyEventTabBar(
                selectedIndex: _selectedWeek,
                onChanged: (i) {
                  if (mounted) setState(() => _selectedWeek = i);
                },
                todayCount: todayCount,
                upcomingCount: upcomingCount,
              ),
            ),

            // Event list or empty state
            if (filteredEvents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: MyEventEmptyState(isToday: _selectedWeek == 0),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = filteredEvents[index];
                      return PremiumEventCard(
                        event: event,
                        isStarting: _startingEventId == event.id,
                        canStart: _canStartEvent(event),
                        startTooltip: _startEventTooltip(event),
                        onStart: () => _startEvent(context, event),
                        onFinish: () => _finishEvent(context, event),
                      )
                          .animate()
                          .fadeIn(
                              duration: 300.ms,
                              delay: (index * 60).ms,
                              curve: Curves.easeOut)
                          .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: 300.ms,
                              delay: (index * 60).ms,
                              curve: Curves.easeOut);
                    },
                    childCount: filteredEvents.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
