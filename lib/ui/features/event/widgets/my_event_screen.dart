import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/utils/event_status_colors.dart';
import 'package:provider/provider.dart';
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
    final theme = Theme.of(context);
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
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () async {
              // Refresh user events from Firestore
              await _fetchUserEvents();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Events refreshed'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
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
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
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
            const SizedBox(height: 16),
            // Compact section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF201C58).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF201C58),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Events',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF201C58),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'View and manage your assigned wellness events',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Modern pill tab selector
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEventTab(
                          'Today', 0, Icons.today_rounded, theme),
                      _buildEventTab('Upcoming', 1,
                          Icons.calendar_month_rounded, theme),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _selectedWeek == 0 ? 'Today\'s Events' : 'Upcoming Events',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF201C58),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // If no events for selected tab, show friendly empty state
            if (filteredEvents.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF90C048).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedWeek == 0
                              ? Icons.today_rounded
                              : Icons.calendar_month_rounded,
                          color: const Color(0xFF90C048),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedWeek == 0
                            ? 'No Events Today'
                            : 'No Upcoming Events',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF201C58),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedWeek == 0
                            ? 'No events scheduled for today. Check the "Upcoming" tab for future events.'
                            : allEvents.isEmpty
                                ? 'No events have been assigned to you yet.'
                                : 'All your events are scheduled for today.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // List of events for the selected tab
              // Using Event Breakdown Card styling inline to preserve custom action buttons
              // (Start/Resume/Finish buttons are specific to this screen)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: filteredEvents.map((event) {
                    final isStarting = _startingEventId == event.id;
                    final theme = Theme.of(context);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.primaryColor.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row with icon and title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.event_rounded,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_rounded,
                                              size: 14,
                                              color: KenwellColors
                                                  .secondaryNavyDark,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${event.date.day}/${event.date.month}/${event.date.year}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: KenwellColors
                                                    .secondaryNavyDark,
                                                // .secondaryNavyDark,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: EventStatusColors
                                                        .getStatusColor(
                                                            event.status)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                event.status,
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: EventStatusColors
                                                      .getStatusColor(
                                                          event.status),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Additional event details
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: KenwellColors.secondaryNavyDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${event.startTime} - ${event.endTime}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: KenwellColors.secondaryNavyDark,
                                    ),
                                  ),
                                ],
                              ),
                              if (event.address.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: KenwellColors.secondaryNavyDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(event.address,
                                          style: const TextStyle(
                                            color:
                                                KenwellColors.secondaryNavyDark,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                              if (event.venue.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.business_rounded,
                                      size: 16,
                                      color: KenwellColors.secondaryNavyDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        event.venue,
                                        style: const TextStyle(
                                          color:
                                              KenwellColors.secondaryNavyDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (event.servicesRequested.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.medical_services_rounded,
                                      size: 16,
                                      color: KenwellColors.secondaryNavyDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                          'Services: ${event.servicesRequested}',
                                          style: const TextStyle(
                                            color:
                                                KenwellColors.secondaryNavyDark,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomPrimaryButton(
                                      label: event.status ==
                                              WellnessEventStatus.inProgress
                                          ? 'Resume Event'
                                          : 'Start Event',
                                      onPressed: isStarting ||
                                              !_canStartEvent(event)
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
                                                  WellnessEventStatus
                                                      .inProgress &&
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
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build animated pill tab button for the Today/Upcoming selector
  Widget _buildEventTab(
      String label, int index, IconData icon, ThemeData theme) {
    final isSelected = _selectedWeek == index;
    return GestureDetector(
      onTap: () {
        if (mounted) setState(() => _selectedWeek = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF201C58) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF201C58).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Determine if the event can be started based on current time and event start time
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
      SnackBar(
        content: const Text('Event finished successfully'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
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
