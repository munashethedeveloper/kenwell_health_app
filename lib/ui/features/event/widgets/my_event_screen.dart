import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:kenwell_health_app/utils/event_status_colors.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories_dcl/user_event_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_modern_section_header.dart';
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

  // Initialize state
  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
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
    // Fetch user events from repository
    final repo = UserEventRepository();
    debugPrint('MyEventScreen: Fetching events for user ${user.id}...');
    final userEventMaps = await repo.fetchUserEvents(user.id);
    debugPrint(
        'MyEventScreen: Received ${userEventMaps.length} raw user events from Firestore');
    debugPrint('MyEventScreen: Raw userEventMaps from Firestore:');
    for (final map in userEventMaps) {
      debugPrint('  - ${map.toString()}');
    }
    // Convert Firestore maps to WellnessEvent objects
    final events = userEventMaps
        .map((e) {
          try {
            // Handle eventDate - could be Timestamp or DateTime
            DateTime eventDate;
            final rawDate = e['eventDate'];
            if (rawDate is Timestamp) {
              eventDate = rawDate.toDate();
            } else if (rawDate is DateTime) {
              eventDate = rawDate;
            } else {
              debugPrint(
                  'MyEventScreen: Invalid date type: ${rawDate.runtimeType}');
              return null;
            }

            return WellnessEvent(
              id: e['eventId'] ?? '',
              title: e['eventTitle'] ?? '',
              date: eventDate,
              venue: e['eventVenue'] ?? '',
              address: e['eventLocation'] ?? '',
              townCity: '',
              province: '',
              onsiteContactFirstName: '',
              onsiteContactLastName: '',
              onsiteContactNumber: '',
              onsiteContactEmail: '',
              aeContactFirstName: '',
              aeContactLastName: '',
              aeContactNumber: '',
              aeContactEmail: '',
              servicesRequested: e['servicesRequested'] ?? '',
              // additionalServicesRequested: '',
              expectedParticipation: 0,
              nurses: 0,
              //  coordinators: 0,
              setUpTime: '',
              startTime: e['eventStartTime'] ?? '',
              endTime: e['eventEndTime'] ?? '',
              strikeDownTime: '',
              mobileBooths: '',
              description: '',
              medicalAid: '',
              status: 'scheduled',
              actualStartTime: null,
              actualEndTime: null,
            );
          } catch (err) {
            debugPrint(
                'MyEventScreen: Failed to map event: ${e.toString()} | Error: ${err.toString()}');
            return null;
          }
        })
        .whereType<WellnessEvent>()
        .toList();
    debugPrint(
        'MyEventScreen: Successfully mapped ${events.length} WellnessEvent objects');
    debugPrint('MyEventScreen: Mapped WellnessEvent list:');
    for (final event in events) {
      debugPrint(
          '  - id: ${event.id}, title: ${event.title}, date: ${event.date}');
    }
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
      // TODAY TAB: Show only today's events
      // An event is "today's event" if:
      // 1. The event date is today
      // 2. Current time is within the event window (between start time and strike down time)
      //    OR if there's no strike down time, just check if it hasn't ended yet
      filteredEvents = allEvents.where((event) {
        // Check if event is today
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        if (!eventDate.isAtSameMomentAs(today)) {
          return false; // Not today
        }

        // Event is today, now check the time window
        final startDateTime = event.startDateTime;
        final strikeDownDateTime = event.strikeDownDateTime;

        // If we have both start and strike down times, check if we're within that window
        if (startDateTime != null && strikeDownDateTime != null) {
          // Show event if current time is before strike down time
          return now.isBefore(strikeDownDateTime) ||
              now.isAtSameMomentAs(strikeDownDateTime);
        } else if (startDateTime != null) {
          // If we only have start time, show the event if it's today
          return true;
        } else {
          // If no times specified, show all today's events
          return true;
        }
      }).toList();

      debugPrint(
          'MyEventScreen: TODAY tab - Found ${filteredEvents.length} events for today');
    } else {
      // UPCOMING TAB: Show all other events (future events + today's events that have passed)
      filteredEvents = allEvents.where((event) {
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);

        // Include future events (after today)
        if (eventDate.isAfter(today)) {
          return true;
        }

        // For today's events, include only those that have passed strike down time
        if (eventDate.isAtSameMomentAs(today)) {
          final strikeDownDateTime = event.strikeDownDateTime;
          if (strikeDownDateTime != null) {
            // Include if current time is after strike down time
            return now.isAfter(strikeDownDateTime);
          }
          // If no strike down time, exclude from upcoming (they're in TODAY)
          return false;
        }

        // Exclude past events
        return false;
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
    //  final eventVM = context.read<EventViewModel>();
    return Scaffold(
      appBar: KenwellAppBar(
        title: 'KenWell365',
        titleColor: Colors.white,
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
              // Refresh user events from Firestore
              await _fetchUserEvents();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Events refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          TextButton.icon(
            onPressed: () {
              if (mounted) {
                context.pushNamed('help');
              }
            },
            icon: const Icon(Icons.help_outline, color: Colors.white),
            label: const Text(
              'Help',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //const SizedBox(height: 16),
            //const AppLogo(size: 150),
            const SizedBox(height: 16),
            const KenwellModernSectionHeader(
              title: 'My Events Screen',
              subtitle:
                  'Switch between the \'Today\' and \'Upcoming\' tabs to view and manage your wellness events.',
              icon: Icons.event_available,
              //textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Row with left toggle, centered label, and right toggle
            Row(
              children: [
                // Left single-button Toggle for "Today"
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
                      child: Text('Today'),
                    ),
                  ],
                ),

                // Centered label
                Expanded(
                  child: Center(
                    child: Text(
                      _selectedWeek == 0
                          ? 'Today\'s Events'
                          : 'Upcoming Events',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Right single-button Toggle for "Upcoming"
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
                      child: Text('Upcoming'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // If no events for selected tab, show friendly empty state
            if (filteredEvents.isEmpty)
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
                        _selectedWeek == 0
                            ? 'No events scheduled for today.\nCheck the "Upcoming" tab for future events.'
                            : allEvents.isEmpty
                                ? 'No upcoming events.\nCreate an event to get started!'
                                : 'No upcoming events.\nAll your events are scheduled for today.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              // List of events for the selected tab
              Column(
                children: filteredEvents.map((event) {
                  final isStarting = _startingEventId == event.id;
                  final theme = Theme.of(context);
                  return Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left green accent bar
                              Container(
                                width: 5,
                                color: KenwellColors.primaryGreen,
                              ),
                              // Main card body
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      14, 14, 14, 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header: icon badge + org label + title + address
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Calendar icon badge
                                          Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: KenwellColors.primaryGreen
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.event_rounded,
                                              color: KenwellColors.primaryGreen,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Organization label, title and address
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'CLIENT ORGANIZATION',
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: KenwellColors
                                                        .primaryGreen,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.8,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  event.title,
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    color: KenwellColors
                                                        .secondaryNavy,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Builder(
                                                  builder: (_) {
                                                    final fullAddress = [
                                                      event.venue,
                                                      event.address,
                                                      event.townCity,
                                                      event.province,
                                                    ]
                                                        .where((s) =>
                                                            s.isNotEmpty)
                                                        .join(', ');
                                                    if (fullAddress.isEmpty) {
                                                      return const SizedBox
                                                          .shrink();
                                                    }
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 1),
                                                            child: Icon(
                                                              Icons
                                                                  .location_on_outlined,
                                                              size: 13,
                                                              color: KenwellColors
                                                                  .neutralGrey,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 3),
                                                          Expanded(
                                                            child: Text(
                                                              fullAddress,
                                                              style: theme
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                color: KenwellColors
                                                                    .neutralGrey,
                                                                fontSize: 12,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: KenwellColors.neutralDivider),
                                      const SizedBox(height: 10),
                                      // Meta chips: date, time, and status badge
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _MyEventMetaChip(
                                              icon: Icons.calendar_today_outlined,
                                              label:
                                                  '${event.date.day}/${event.date.month}/${event.date.year}',
                                            ),
                                          ),
                                          if (event.startTime.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _MyEventMetaChip(
                                                icon: Icons.access_time_rounded,
                                                label: event.endTime.isNotEmpty
                                                    ? '${event.startTime} – ${event.endTime}'
                                                    : event.startTime,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 9, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: EventStatusColors
                                                      .getStatusColor(
                                                          event.status)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: KenwellColors
                                                    .neutralDivider,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              event.status,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: EventStatusColors
                                                    .getStatusColor(
                                                        event.status),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (event.expectedParticipation > 0) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.people_outline_rounded,
                                              size: 13,
                                              color: KenwellColors.neutralGrey,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${event.expectedParticipation} expected participant${event.expectedParticipation == 1 ? '' : 's'}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: KenwellColors.neutralGrey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (event
                                          .servicesRequested.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.medical_services,
                                              size: 13,
                                              color: KenwellColors.neutralGrey,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Services: ${event.servicesRequested}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color:
                                                      KenwellColors.neutralGrey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: KenwellColors.neutralDivider),
                                      const SizedBox(height: 12),
                                      // Action buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomPrimaryButton(
                                              label: event.status ==
                                                      WellnessEventStatus
                                                          .inProgress
                                                  ? 'Resume Event'
                                                  : 'Start Event',
                                              onPressed: isStarting ||
                                                      !_canStartEvent(event)
                                                  ? null
                                                  : () => _startEvent(
                                                      context, event),
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
                                                          WellnessEventStatus
                                                              .inProgress &&
                                                      event.screenedCount > 0
                                                  ? () => _finishEvent(
                                                      context, event)
                                                  : null,
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                      .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // Determine if the event can be started based on the event date
  bool _canStartEvent(WellnessEvent event) {
    // Allow resuming events that are already in progress
    if (event.status == WellnessEventStatus.inProgress) {
      return true;
    }

    // Don't allow starting already completed events
    if (event.status == WellnessEventStatus.completed) {
      return false;
    }

    // Allow starting any event whose day has arrived (today or earlier)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay =
        DateTime(event.date.year, event.date.month, event.date.day);
    return !today.isBefore(eventDay);
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

// ── Small pill chip used in the meta row ──────────────────────────────────────
class _MyEventMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MyEventMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: KenwellColors.neutralBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: KenwellColors.neutralDivider,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: KenwellColors.secondaryNavy),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: KenwellColors.secondaryNavy,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
