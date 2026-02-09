import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories_dcl/user_event_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
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
    debugPrint('MyEventScreen: Received ${userEventMaps.length} raw user events from Firestore');
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
              debugPrint('MyEventScreen: Invalid date type: ${rawDate.runtimeType}');
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
              servicesRequested: '',
              additionalServicesRequested: '',
              expectedParticipation: 0,
              nurses: 0,
              coordinators: 0,
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
    debugPrint('MyEventScreen: Successfully mapped ${events.length} WellnessEvent objects');
    debugPrint('MyEventScreen: Mapped WellnessEvent list:');
    for (final event in events) {
      debugPrint(
          '  - id: ${event.id}, title: ${event.title}, date: ${event.date}');
    }
    if (!mounted) return;
    setState(() {
      _userEvents = events;
    });
    debugPrint('MyEventScreen: State updated with ${_userEvents.length} events');
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
        debugPrint('  - "${event.title}" | Date: ${event.date} | StartTime: ${event.startTime} | StrikeDownTime: ${event.strikeDownTime} | Status: ${event.status}');
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
        final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
        if (!eventDate.isAtSameMomentAs(today)) {
          return false; // Not today
        }
        
        // Event is today, now check the time window
        final startDateTime = event.startDateTime;
        final strikeDownDateTime = event.strikeDownDateTime;
        
        // If we have both start and strike down times, check if we're within that window
        if (startDateTime != null && strikeDownDateTime != null) {
          // Show event if current time is before strike down time
          return now.isBefore(strikeDownDateTime) || now.isAtSameMomentAs(strikeDownDateTime);
        } else if (startDateTime != null) {
          // If we only have start time, show the event if it's today
          return true;
        } else {
          // If no times specified, show all today's events
          return true;
        }
      }).toList();
      
      debugPrint('MyEventScreen: TODAY tab - Found ${filteredEvents.length} events for today');
    } else {
      // UPCOMING TAB: Show all other events (future events + today's events that have passed)
      filteredEvents = allEvents.where((event) {
        final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
        
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
      
      debugPrint('MyEventScreen: UPCOMING tab - Found ${filteredEvents.length} upcoming events');
    }
    
    // Debug filtered events
    if (filteredEvents.isNotEmpty) {
      debugPrint('MyEventScreen: Filtered events for tab $_selectedWeek:');
      for (final event in filteredEvents) {
        debugPrint('  - "${event.title}" | Date: ${event.date} | Start: ${event.startDateTime} | StrikeDown: ${event.strikeDownDateTime}');
      }
    }

    // Build the Scaffold
    final eventVM = context.read<EventViewModel>();
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
                      _selectedWeek == 0 ? 'Today\'s Events' : 'Upcoming Events',
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
                      if (allEvents.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            '${allEvents.length} event(s) total',
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
              // List of events for the selected tab
              Column(
                children: filteredEvents.map((event) {
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

  // Build info chip widget
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
