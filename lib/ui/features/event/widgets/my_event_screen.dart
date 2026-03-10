import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';
import 'package:kenwell_health_app/utils/event_status_colors.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories_dcl/event_repository.dart';
import '../../../../data/repositories_dcl/user_event_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../view_model/event_view_model.dart';
import '../../wellness/widgets/wellness_flow_page.dart';

// MyEventScreen displays the events assigned to the current user
class MyEventScreen extends StatefulWidget {
  // Constructor
  const MyEventScreen({super.key});

  // Static method to access state from context
  static MyEventScreenState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<MyEventScreenState>();
    return state;
  }

  // Create state
  @override
  State<MyEventScreen> createState() => MyEventScreenState();
}

// State class for MyEventScreen
class MyEventScreenState extends State<MyEventScreen> {
  String? _startingEventId;
  int _selectedWeek = 0; // 0 = this week, 1 = next week
  List<WellnessEvent> _userEvents = [];
  Timer? _clockTimer;
  bool _isTransitioning = false;

  // Initialize state
  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
    // Tick every minute so button states update as the clock passes start time
    // and scheduled events are automatically transitioned to in-progress.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _autoTransitionEvents();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  // Call this method after returning from allocation to refresh events
  void refreshUserEvents() {
    _fetchUserEvents();
  }

  // Fetch user events from Firestore
  Future<void> _fetchUserEvents() async {
    debugPrint('MyEventScreen: Starting _fetchUserEvents...');
    // Get current user
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    debugPrint('MyEventScreen: Current user: ${user?.id}');
    // If no user, clear events and return
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _userEvents = [];
      });
      debugPrint('MyEventScreen: No user logged in.');
      return;
    }
    // Fetch assigned event IDs from user_events collection
    final userEventRepo = UserEventRepository();
    final eventRepo = EventRepository();
    debugPrint(
        'MyEventScreen: Fetching assigned event IDs for user ${user.id}...');
    final userEventMaps = await userEventRepo.fetchUserEvents(user.id);
    debugPrint(
        'MyEventScreen: Received ${userEventMaps.length} user_event records');

    // For each assigned event ID, fetch the full event from the events collection
    final eventIds = userEventMaps
        .map((m) => m['eventId'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    final results = await Future.wait(
      eventIds.map((eventId) async {
        try {
          final event = await eventRepo.fetchEventById(eventId);
          if (event != null) {
            debugPrint(
                'MyEventScreen: Loaded full event "$eventId" | townCity: ${event.townCity} | province: ${event.province} | expectedParticipation: ${event.expectedParticipation} | status: ${event.status}');
          } else {
            debugPrint(
                'MyEventScreen: Event "$eventId" not found in events collection');
          }
          return event;
        } catch (err) {
          debugPrint(
              'MyEventScreen: Failed to fetch event "$eventId": ${err.toString()}');
          return null;
        }
      }),
    );

    final events = results.whereType<WellnessEvent>().toList();

    debugPrint(
        'MyEventScreen: Successfully loaded ${events.length} full WellnessEvent objects');
    if (!mounted) return;
    setState(() {
      _userEvents = events;
    });
    debugPrint(
        'MyEventScreen: State updated with ${_userEvents.length} events');
  }

  @override
  Widget build(BuildContext context) {
    // Use _userEvents instead of allEvents
    final allEvents = _userEvents;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    debugPrint('MyEventScreen: Total events in database = ${allEvents.length}');
    debugPrint('MyEventScreen: Current date/time = $now');
    debugPrint('MyEventScreen: Today\'s date (midnight) = $today');

    // Debug: Print ALL events with details
    if (allEvents.isNotEmpty) {
      debugPrint('MyEventScreen: All events:');
      for (final event in allEvents) {
        debugPrint(
            '  - "${event.title}" | Date: ${event.date} | StartTime: ${event.startTime} | StrikeDownTime: ${event.strikeDownTime} | Status: ${event.status}');
      }
    }

    // Filter events based on selected tab
    final List<WellnessEvent> filteredEvents;

    if (_selectedWeek == 0) {
      // TODAY TAB: Show all events scheduled for today
      filteredEvents = allEvents.where((event) {
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        return eventDate.isAtSameMomentAs(today);
      }).toList();

      debugPrint(
          'MyEventScreen: TODAY tab - Found ${filteredEvents.length} events for today');
    } else {
      // UPCOMING TAB: Show all events scheduled for a future date (after today)
      filteredEvents = allEvents.where((event) {
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        return eventDate.isAfter(today);
      }).toList();

      debugPrint(
          'MyEventScreen: UPCOMING tab - Found ${filteredEvents.length} upcoming events');
    }

    // Debug filtered events
    if (filteredEvents.isNotEmpty) {
      debugPrint('MyEventScreen: Filtered events for tab $_selectedWeek:');
      for (final event in filteredEvents) {
        debugPrint(
            '  - "${event.title}" | Date: ${event.date} | Start: ${event.startDateTime} | StrikeDown: ${event.strikeDownDateTime}');
      }
    }

    // Build the Scaffold
    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: KenwellAppBar(
        title: 'My Events',
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
            // ── Hero intro banner ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _MyEventsHeroBanner(
                totalEvents: allEvents.length,
                todayCount: filteredEvents.length,
                isToday: _selectedWeek == 0,
              ),
            ),

            // ── Segmented Tab bar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _MyEventsTabBar(
                selectedIndex: _selectedWeek,
                onChanged: (i) {
                  if (mounted) setState(() => _selectedWeek = i);
                },
                todayCount: allEvents.where((e) {
                  final d = e.date.toLocal();
                  return DateTime(d.year, d.month, d.day)
                      .isAtSameMomentAs(today);
                }).length,
                upcomingCount: allEvents.where((e) {
                  final d = e.date.toLocal();
                  return DateTime(d.year, d.month, d.day).isAfter(today);
                }).length,
              ),
            ),

            // ── Event list ─────────────────────────────────────────────
            if (filteredEvents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: _MyEventsEmptyState(isToday: _selectedWeek == 0),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = filteredEvents[index];
                      final isStarting = _startingEventId == event.id;
                      return _PremiumEventCard(
                        event: event,
                        isStarting: isStarting,
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

  // Auto-transition any scheduled events whose start time has elapsed.
  // Called every minute by the clock timer so button states stay current.
  Future<void> _autoTransitionEvents() async {
    // Skip if a previous tick is still in flight to avoid race conditions
    if (_isTransitioning || !mounted) return;
    _isTransitioning = true;
    try {
      final now = DateTime.now();

      // Snapshot the list to avoid mutation issues if _fetchUserEvents runs
      // concurrently (e.g., from the refresh button).
      final snapshot = List<WellnessEvent>.from(_userEvents);

      // Capture ViewModel before any async gap so context is still valid.
      final eventVM = context.read<EventViewModel>();

      final eventsToTransition = snapshot.where((e) {
        if (e.status != WellnessEventStatus.scheduled) return false;
        final startDt = e.startDateTime;
        return startDt != null && !now.isBefore(startDt);
      }).toList();

      if (eventsToTransition.isEmpty) {
        // Only rebuild if there are today-scheduled events whose button state
        // could actually change as the clock advances.
        final today = DateTime(now.year, now.month, now.day);
        if (mounted &&
            snapshot.any((e) =>
                e.status == WellnessEventStatus.scheduled &&
                _eventDay(e).isAtSameMomentAs(today))) {
          setState(() {});
        }
        return;
      }

      // Update all elapsed events concurrently; tolerate partial failures so
      // a single bad update does not block the rest.
      await Future.wait(
        eventsToTransition.map((event) => eventVM
                .updateEvent(event.copyWith(
              status: WellnessEventStatus.inProgress,
              actualStartTime: event.startDateTime,
            ))
                .catchError((Object e) {
              debugPrint(
                  '_autoTransitionEvents: failed to update ${event.id}: $e');
            })),
      );

      if (!mounted) return;
      await _fetchUserEvents();
    } finally {
      _isTransitioning = false;
    }
  }

  // Determine if the event can be started based on the event date and time
  bool _canStartEvent(WellnessEvent event) {
    // Allow resuming events that are already in progress
    if (event.status == WellnessEventStatus.inProgress) {
      return true;
    }

    // Don't allow starting already completed events
    if (event.status == WellnessEventStatus.completed) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = _eventDay(event);

    // Event must be today or in the past
    if (today.isBefore(eventDay)) {
      return false;
    }

    // For today's events, the start time must have been reached
    if (today.isAtSameMomentAs(eventDay) && _isTimeLocked(event, now)) {
      return false;
    }

    return true;
  }

  /// Returns a tooltip message explaining why the Start Event button is
  /// disabled due to the start time not yet being reached, or null otherwise.
  String? _startEventTooltip(WellnessEvent event) {
    // Only show a time-based tooltip for scheduled events on today's date
    if (event.status != WellnessEventStatus.scheduled) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!today.isAtSameMomentAs(_eventDay(event))) return null;

    if (!_isTimeLocked(event, now)) return null;

    final startDateTime = event.startDateTime;
    return startDateTime != null
        ? 'Available from ${DateFormat.Hm().format(startDateTime)}'
        : 'Not yet available';
  }

  /// Returns true when a scheduled event has a non-empty [startTime] that
  /// either could not be parsed or has not yet been reached.
  bool _isTimeLocked(WellnessEvent event, DateTime now) {
    final startTime = event.startTime.trim();
    if (startTime.isEmpty) return false;
    final startDateTime = event.startDateTime;
    return startDateTime == null || now.isBefore(startDateTime);
  }

  /// Returns the date portion of an event's date (midnight local time, no
  /// time of day component). Uses toLocal() to correctly handle UTC DateTimes
  /// that Firestore's Timestamp.toDate() may return.
  DateTime _eventDay(WellnessEvent event) {
    final local = event.date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  // Start the event and navigate to WellnessFlowPage
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

      // Refresh events after returning from wellness flow
      if (!mounted) return;
      try {
        await _fetchUserEvents();
      } catch (e) {
        debugPrint('MyEventScreen: Error refreshing events after start: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _startingEventId = null);
      }
    }
  }

  // Finish the event
  Future<void> _finishEvent(BuildContext context, WellnessEvent event) async {
    final eventVM = context.read<EventViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    await eventVM.markEventCompleted(event.id);

    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Event finished successfully')),
    );

    // Refresh events after finishing
    if (!mounted) return;
    try {
      await _fetchUserEvents();
    } catch (e) {
      debugPrint('MyEventScreen: Error refreshing events after finish: $e');
    }
  }
}

// ── Premium My-Events widgets ─────────────────────────────────────────────────

/// Gradient hero banner at the top of the My Events scroll view.
class _MyEventsHeroBanner extends StatelessWidget {
  const _MyEventsHeroBanner({
    required this.totalEvents,
    required this.todayCount,
    required this.isToday,
  });

  final int totalEvents;
  final int todayCount;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            KenwellColors.secondaryNavy,
            Color(0xFF2E2880),
            KenwellColors.primaryGreenDark,
          ],
          stops: [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KenwellColors.secondaryNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left – text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KenwellSectionLabel(label: 'MY EVENTS'),
                const SizedBox(height: 10),
                Text(
                  isToday ? "Today's Events" : 'Upcoming Events',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isToday
                      ? 'Manage your wellness events for today.'
                      : 'Your scheduled events for the coming days.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right – count badge
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: KenwellColors.primaryGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$todayCount',
                      style: const TextStyle(
                        color: KenwellColors.primaryGreenLight,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      isToday ? 'today' : 'upcoming',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Segmented tab bar for switching between Today / Upcoming.
class _MyEventsTabBar extends StatelessWidget {
  const _MyEventsTabBar({
    required this.selectedIndex,
    required this.onChanged,
    required this.todayCount,
    required this.upcomingCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int todayCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'Today',
              count: todayCount,
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            _TabItem(
              label: 'Upcoming',
              count: upcomingCount,
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [KenwellColors.secondaryNavy, Color(0xFF3B3F86)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : KenwellColors.secondaryNavy.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty-state widget shown when no events match the selected tab.
class _MyEventsEmptyState extends StatelessWidget {
  const _MyEventsEmptyState({required this.isToday});

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: KenwellColors.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isToday ? Icons.today_rounded : Icons.date_range_rounded,
              size: 56,
              color: KenwellColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isToday ? 'No Events Today' : 'No Upcoming Events',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KenwellColors.secondaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? 'You have no events scheduled for today.\nCheck the Upcoming tab for future events.'
                : 'No events have been allocated to you yet.\nContact your administrator to be assigned.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium event card with gradient accent bar and modern layout.
class _PremiumEventCard extends StatelessWidget {
  const _PremiumEventCard({
    required this.event,
    required this.isStarting,
    required this.canStart,
    required this.startTooltip,
    required this.onStart,
    required this.onFinish,
  });

  final WellnessEvent event;
  final bool isStarting;
  final bool canStart;
  final String? startTooltip;
  final VoidCallback onStart;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final statusColor = EventStatusColors.getStatusColor(event.status);
    final fullAddress = [event.address, event.townCity, event.province]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Gradient top accent bar ──────────────────────────────────
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [KenwellColors.primaryGreen, Color(0xFF3B3F86)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // ── Card body ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: icon + title + status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              KenwellColors.secondaryNavy,
                              Color(0xFF3B3F86)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section micro-label
                            const Text(
                              'CLIENT ORGANIZATION',
                              style: TextStyle(
                                color: KenwellColors.primaryGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: KenwellColors.secondaryNavy,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 1),
                        ),
                        child: Text(
                          event.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Address
                  if (fullAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.5),
                          child: Icon(Icons.location_on_outlined,
                              size: 13, color: KenwellColors.neutralGrey),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            fullAddress,
                            style: const TextStyle(
                              fontSize: 12,
                              color: KenwellColors.neutralGrey,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(
                      height: 1,
                      thickness: 1,
                      color: KenwellColors.neutralDivider),
                  const SizedBox(height: 12),

                  // Meta row: date, time, participants
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MetaPill(
                        icon: Icons.calendar_today_outlined,
                        label:
                            '${event.date.day}/${event.date.month}/${event.date.year}',
                      ),
                      if (event.startTime.isNotEmpty)
                        _MetaPill(
                          icon: Icons.access_time_rounded,
                          label: event.endTime.isNotEmpty
                              ? '${event.startTime} – ${event.endTime}'
                              : event.startTime,
                        ),
                      if (event.expectedParticipation > 0)
                        _MetaPill(
                          icon: Icons.people_outline_rounded,
                          label:
                              '${event.expectedParticipation} participant${event.expectedParticipation == 1 ? '' : 's'}',
                        ),
                    ],
                  ),

                  if (event.servicesRequested.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.5),
                          child: Icon(Icons.medical_services_outlined,
                              size: 13, color: KenwellColors.neutralGrey),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Services: ${event.servicesRequested}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: KenwellColors.neutralGrey,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(
                      height: 1,
                      thickness: 1,
                      color: KenwellColors.neutralDivider),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final btn = CustomPrimaryButton(
                              label: event.status ==
                                      WellnessEventStatus.inProgress
                                  ? 'Resume Event'
                                  : 'Start Event',
                              onPressed:
                                  isStarting || !canStart ? null : onStart,
                              isBusy: isStarting,
                              fullWidth: true,
                            );
                            return startTooltip != null
                                ? Tooltip(message: startTooltip!, child: btn)
                                : btn;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomPrimaryButton(
                          label: 'Finish Event',
                          fullWidth: true,
                          onPressed: event.status ==
                                      WellnessEventStatus.inProgress &&
                                  event.screenedCount > 0
                              ? onFinish
                              : null,
                          backgroundColor: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pill chip for event metadata (date, time, etc.)
class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: KenwellColors.neutralBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KenwellColors.neutralDivider, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: KenwellColors.secondaryNavy),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: KenwellColors.secondaryNavy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


