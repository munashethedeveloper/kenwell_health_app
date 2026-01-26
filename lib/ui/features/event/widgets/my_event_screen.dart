import 'package:flutter/material.dart';
import 'package:kenwell_health_app/routing/route_names.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/event_view_model.dart';
import '../../wellness/widgets/wellness_flow_page.dart';

class MyEventScreen extends StatefulWidget {
  const MyEventScreen({super.key});

  @override
  State<MyEventScreen> createState() => _MyEventScreenState();
}

class _MyEventScreenState extends State<MyEventScreen> {
  String? _startingEventId;
  int _selectedWeek = 0; // 0 = this week, 1 = next week

  @override
  void initState() {
    super.initState();
    // Reload events when screen is displayed to ensure latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventViewModel>().reloadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventVM = context.watch<EventViewModel>();
    final allEvents = eventVM.events; // Get ALL events
    final allUpcoming = eventVM.getUpcomingEvents();

    debugPrint(
        'ConductEventScreen: Total events in database = ${allEvents.length}');
    debugPrint(
        'ConductEventScreen: Total upcoming events = ${allUpcoming.length}');
    debugPrint('ConductEventScreen: Current date/time = ${DateTime.now()}');

    // Debug: Print ALL events with details
    if (allEvents.isNotEmpty) {
      debugPrint('ConductEventScreen: All events:');
      for (final event in allEvents) {
        debugPrint(
            '  - "${event.title}" | Date: ${event.date} | Status: ${event.status}');
      }
    }

    // Debug: Print details about filtered out events
    final filteredOut =
        allEvents.where((e) => !allUpcoming.contains(e)).toList();
    if (filteredOut.isNotEmpty) {
      debugPrint(
          'ConductEventScreen: ${filteredOut.length} events were filtered out:');
      for (final event in filteredOut) {
        debugPrint(
            '  - "${event.title}" | Date: ${event.date} | Status: ${event.status} | StrikeDown: ${event.strikeDownDateTime}');
      }
    }

    // Compute week ranges
    final now = DateTime.now();
    final weekStart = _startOfWeek(now); // Sunday 00:00:00 of this week
    final nextWeekStart = weekStart.add(const Duration(days: 7));

    final selectedStart = _selectedWeek == 0 ? weekStart : nextWeekStart;
    final selectedEnd = _endOfWeek(selectedStart);

    debugPrint(
        'ConductEventScreen: Selected week range: $selectedStart to $selectedEnd');

    // Filter events for the selected week (inclusive)
    final weeklyEvents = allUpcoming.where((e) {
      final ev = e.date.toLocal();
      return !(ev.isBefore(selectedStart) || ev.isAfter(selectedEnd));
    }).toList();

    debugPrint(
        'ConductEventScreen: Events in selected week = ${weeklyEvents.length}');
    if (weeklyEvents.isEmpty && allUpcoming.isNotEmpty) {
      debugPrint(
          'ConductEventScreen: No events in selected week. Event dates:');
      for (final event in allUpcoming) {
        debugPrint('  - "${event.title}": ${event.date}');
      }
    }

    return Scaffold(
      appBar: KenwellAppBar(
        title: 'My Events',
        titleColor: const Color(0xFF201C58),
        titleStyle: const TextStyle(
          color: Color(0xFF201C58),
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Color(0xFF201C58)),
            onPressed: () async {
              // Refresh events from Firestore
              await eventVM.reloadEvents();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Events refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          TextButton.icon(
            onPressed: () {
              if (mounted) {
                Navigator.pushNamed(context, RouteNames.help);
              }
            },
            icon: const Icon(Icons.help_outline, color: Color(0xFF201C58)),
            label: const Text(
              'Help',
              style: TextStyle(color: Color(0xFF201C58)),
            ),
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
                      eventVM.formatDateRange(selectedStart, selectedEnd),
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
              Center(
                child: Padding(
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
                            : 'No events scheduled for the week of ${eventVM.formatDateRange(selectedStart, selectedEnd)}.\nSwitch weeks to see other events.',
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
                      title: event.title,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date and Time Information
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 6),
                              Text(
                                eventVM.formatEventDateLong(event.date),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 6),
                              Text(
                                '${event.startTime} - ${event.endTime}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (event.address.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    event.address,
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (event.venue.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.business,
                                    size: 16, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    event.venue,
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ],
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
                          const SizedBox(height: 12),
                          // Screened counter with badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF201C58)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people,
                                    size: 18, color: Color(0xFF201C58)),
                                const SizedBox(width: 6),
                                Text(
                                  'Screened: ${event.screenedCount} participants',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF201C58),
                                  ),
                                ),
                              ],
                            ),
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
                                  fullWidth: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomPrimaryButton(
                                  label: 'Finish Event',
                                  fullWidth: true,
                                  onPressed: event.status ==
                                              WellnessEventStatus.inProgress &&
                                          event.screenedCount > 0
                                      ? () => _finishEvent(context, event)
                                      : null,
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
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
    final int daysToSubtract = date.weekday % 7;
    final dt = DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
    return DateTime(dt.year, dt.month, dt.day);
  }

  DateTime _endOfWeek(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 6));
    return DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
  }

  bool _canStartEvent(WellnessEvent event) {
    // Allow resuming events that are already in progress
    if (event.status == WellnessEventStatus.inProgress) {
      return true;
    }

    // Check if start time has been reached
    final startTime = event.startDateTime;
    if (startTime == null) {
      // If no start time is set, don't allow starting
      return false;
    }

    final now = DateTime.now();
    // Allow starting the event 5 minutes before the start time
    final fiveMinutesBeforeStart =
        startTime.subtract(const Duration(minutes: 5));
    return !now.isBefore(fiveMinutesBeforeStart);
  }

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
    } finally {
      if (mounted) {
        setState(() => _startingEventId = null);
      }
    }
  }

  Future<void> _finishEvent(BuildContext context, WellnessEvent event) async {
    final eventVM = context.read<EventViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    await eventVM.markEventCompleted(event.id);

    if (!mounted) return;

    messenger.showSnackBar(
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
