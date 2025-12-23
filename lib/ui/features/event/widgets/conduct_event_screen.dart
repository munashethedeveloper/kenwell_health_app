import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/routing/route_names.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/auth_view_model.dart';
import 'package:kenwell_health_app/ui/features/auth/widgets/login_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/event_view_model.dart';
import '../../wellness/widgets/wellness_flow_page.dart';

class ConductEventScreen extends StatefulWidget {
  const ConductEventScreen({super.key});

  @override
  State<ConductEventScreen> createState() => _ConductEventScreenState();
}

class _ConductEventScreenState extends State<ConductEventScreen> {
  String? _startingEventId;
  int _selectedWeek = 0; // 0 = this week, 1 = next week
  DateTime? _lastReloadTime;

  @override
  void initState() {
    super.initState();
    // Initial load of events
    _reloadEventsIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload events when screen becomes visible again
    _reloadEventsIfNeeded();
  }

  void _reloadEventsIfNeeded() {
    // Only reload if it's been more than 2 seconds since last reload
    // This prevents excessive reloads while still keeping data fresh
    final now = DateTime.now();
    if (_lastReloadTime == null ||
        now.difference(_lastReloadTime!) > const Duration(seconds: 2)) {
      _lastReloadTime = now;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<EventViewModel>().reloadEvents();
        }
      });
    }
  }

  // LOGOUT METHOD using AuthViewModel
  Future<void> _logout() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventVM = context.watch<EventViewModel>();
    final allUpcoming = eventVM.getUpcomingEvents();

    debugPrint(
        'ConductEventScreen: Total upcoming events = ${allUpcoming.length}');

    // Compute week ranges
    final now = DateTime.now();
    final weekStart = _startOfWeek(now); // Sunday 00:00:00 of this week
    final nextWeekStart = weekStart.add(const Duration(days: 7));

    final selectedStart = _selectedWeek == 0 ? weekStart : nextWeekStart;
    final selectedEnd = _endOfWeek(selectedStart);

    // Filter events for the selected week (inclusive)
    final weeklyEvents = allUpcoming.where((e) {
      final eventDate = _normalizeDate(e.date);
      final weekStartDate = _normalizeDate(selectedStart);
      final weekEndDate = _normalizeDate(selectedEnd);
      return (eventDate.isAfter(weekStartDate) || eventDate.isAtSameMomentAs(weekStartDate)) &&
             (eventDate.isBefore(weekEndDate) || eventDate.isAtSameMomentAs(weekEndDate));
    }).toList();

    debugPrint(
        'ConductEventScreen: Events in selected week = ${weeklyEvents.length}');

    return Scaffold(
      appBar: KenwellAppBar(
        title: 'Upcoming Events',
        backgroundColor: const Color(0xFF201C58),
        titleColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          // 🔹 Popup menu
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 0: // Profile
                  if (mounted) {
                    Navigator.pushNamed(context, RouteNames.profile);
                  }
                  break;
                case 1: // Help
                  if (mounted) {
                    Navigator.pushNamed(context, RouteNames.help);
                  }
                  break;
                case 2: // Logout
                  await _logout();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.black),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.black),
                  title: Text('Help'),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const AppLogo(size: 200),
            const SizedBox(height: 16),

            // Row with left toggle, centered date-range text, and right toggle
            Row(
              children: [
                // Left single-button Toggle for "This week"
                ToggleButtons(
                  isSelected: [_selectedWeek == 0],
                  onPressed: (index) {
                    if (mounted) {
                      setState(() {
                        _selectedWeek = 0;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  selectedColor: Colors.white,
                  color: const Color(0xFF201C58),
                  fillColor: const Color(0xFF201C58),
                  constraints: const BoxConstraints(minWidth: 96),
                  children: const [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text('This week'),
                    ),
                  ],
                ),

                // Centered date range
                Expanded(
                  child: Center(
                    child: Text(
                      '${DateFormat.yMMMMd().format(selectedStart)} - ${DateFormat.yMMMMd().format(selectedEnd)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Right single-button Toggle for "Next week"
                ToggleButtons(
                  isSelected: [_selectedWeek == 1],
                  onPressed: (index) {
                    if (mounted) {
                      setState(() {
                        _selectedWeek = 1;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  selectedColor: Colors.white,
                  color: const Color(0xFF201C58),
                  fillColor: const Color(0xFF201C58),
                  constraints: const BoxConstraints(minWidth: 96),
                  children: const [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text('Next week'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // If no events for selected week, show friendly empty state
            if (weeklyEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_available,
                        size: 64, color: Color(0xFF90C048)),
                    const SizedBox(height: 16),
                    Text(
                      allUpcoming.isEmpty
                          ? 'No upcoming events.\nCreate an event to get started!'
                          : 'No events scheduled for the week of ${DateFormat.yMMMMd().format(selectedStart)} - ${DateFormat.yMMMMd().format(selectedEnd)}.\nSwitch weeks to see other events.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (allUpcoming.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          '${allUpcoming.length} event(s) total',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              // List of events for the selected week
              Column(
                children: weeklyEvents.map((event) {
                  final isStarting = _startingEventId == event.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: KenwellFormCard(
                      title: 'Event Name: ${event.title}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Date:  ${DateFormat.yMMMMd().format(event.date)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.9)),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Start Time:  ${event.startTime}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.9)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'End Time:  ${event.endTime}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.9)),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.venue.isNotEmpty
                                ? event.venue
                                : event.address,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (event.servicesRequested.isNotEmpty)
                                _infoChip(Icons.medical_services,
                                    event.servicesRequested),
                              if (event.expectedParticipation > 0)
                                _infoChip(Icons.people,
                                    '${event.expectedParticipation} expected'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Inline Start + Finish buttons
                          Row(
                            children: [
                              Expanded(
                                child: CustomPrimaryButton(
                                  label: event.status ==
                                          WellnessEventStatus.inProgress
                                      ? 'Resume Event'
                                      : 'Start Event',
                                  onPressed:
                                      isStarting || !_canStartEvent(event)
                                          ? null
                                          : () => _startEvent(context, event),
                                  isBusy: isStarting,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomPrimaryButton(
                                  label: 'Finish Event',
                                  onPressed: () {
                                    if (event.status ==
                                        WellnessEventStatus.inProgress) {
                                      _finishEvent(context, event);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Start the event first')),
                                      );
                                    }
                                  },
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Screened counter
                          Text(
                            'Screened: ${event.screenedCount} participants',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  DateTime _startOfWeek(DateTime date) {
    // weekday: 1=Monday, 7=Sunday
    // To start week on Sunday: if Sunday (7), subtract 0 days; if Monday (1), subtract 1 day, etc.
    final int daysToSubtract = date.weekday % 7;
    final dt = DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
    return DateTime(dt.year, dt.month, dt.day, 0, 0, 0, 0);
  }

  DateTime _endOfWeek(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 6));
    return DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
  }

  // Normalize date to midnight for comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  bool _canStartEvent(WellnessEvent event) {
    // Allow resuming events that are already in progress
    if (event.status == WellnessEventStatus.inProgress) {
      return true;
    }

    // Check if start time has been reached
    final startTime = event.startDateTime;
    if (startTime == null) {
      // If no start time is set, allow starting the event
      return true;
    }

    final now = DateTime.now();
    // Allow starting the event at or after the start time
    return !now.isBefore(startTime);
  }

  Future<void> _startEvent(BuildContext context, WellnessEvent event) async {
    setState(() => _startingEventId = event.id);
    try {
      final eventVM = context.read<EventViewModel>();
      final updated = await eventVM.markEventInProgress(event.id) ?? event;
      if (!mounted) return;

      await Navigator.of(context).push(
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
    } finally {
      if (mounted) {
        setState(() => _startingEventId = null);
      }
    }
  }

  Future<void> _finishEvent(BuildContext context, WellnessEvent event) async {
    final eventVM = context.read<EventViewModel>();
    await eventVM.markEventCompleted(event.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event finished successfully')),
    );

    setState(() {});
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF201C58)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF201C58),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
