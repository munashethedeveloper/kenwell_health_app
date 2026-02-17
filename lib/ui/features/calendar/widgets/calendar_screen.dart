import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../event/view_model/event_view_model.dart';
import '../../event/widgets/event_screen.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../view_model/calendar_view_model.dart';
import 'day_events_dialog.dart';
import 'event_card.dart';

/// The main calendar screen displaying events in calendar and list views.
class CalendarScreen extends StatelessWidget {
  // Constructor
  const CalendarScreen({super.key});

  // Build method to create the widget tree
  @override
  Widget build(BuildContext context) {
    // Return the body of the calendar screen
    return const _CalendarScreenBody();
  }
}

// The stateful body of the calendar screen
class _CalendarScreenBody extends StatefulWidget {
  // Constructor
  const _CalendarScreenBody();

  // Create state for the widget
  @override
  State<_CalendarScreenBody> createState() => _CalendarScreenBodyState();
}

// State class for the calendar screen body
class _CalendarScreenBodyState extends State<_CalendarScreenBody> {
  // Helper to check if user can add events using RolePermissions
  bool _canAddEvent(BuildContext context) {
    final profileVM = context.read<ProfileViewModel>();
    return RolePermissions.canAccessFeature(profileVM.role, 'create_event');
  }

  // Helper to generate personalized welcome title
  String _getWelcomeTitle() {
    final profileVM = context.read<ProfileViewModel>();
    final firstName = profileVM.firstName;
    if (firstName.isEmpty) {
      return 'Welcome to KenWell365';
    }
    // Capitalize the first character of the firstName
    final capitalizedFirstName = firstName[0].toUpperCase() +
        (firstName.length > 1 ? firstName.substring(1) : '');
    return 'Welcome to KenWell365, $capitalizedFirstName';
  }

  // Initialize state
  @override
  void initState() {
    super.initState();
    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarViewModel>().loadEvents();
    });
  }

  // Build method to create the widget tree
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use Consumer to listen to CalendarViewModel changes
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, _) {
        // Main scaffold with tab controller
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            // App bar with title and actions
            appBar: KenwellAppBar(
              title: 'Wellness Planner',
              automaticallyImplyLeading: false,
              titleColor: const Color(0xFF201C58),
              titleStyle: const TextStyle(
                color: Color(0xFF201C58),
                fontWeight: FontWeight.bold,
              ),
              actions: [
                // Refresh events button
                IconButton(
                  onPressed: () {
                    if (mounted) {
                      viewModel.loadEvents();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Events refreshed'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, color: Color(0xFF201C58)),
                  tooltip: 'Refresh events',
                ),
                // Help button
                TextButton.icon(
                  onPressed: () {
                    if (mounted) {
                      context.pushNamed('help');
                    }
                  },
                  icon:
                      const Icon(Icons.help_outline, color: Color(0xFF201C58)),
                  label: const Text(
                    'Help',
                    style: TextStyle(color: Color(0xFF201C58)),
                  ),
                ),
              ],
              // Tab bar for switching views
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3.0,
                    color: theme.colorScheme.onPrimary,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor:
                    theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                // Tabs for calendar and list views
                tabs: const [
                  Tab(
                      icon: Icon(Icons.calendar_today),
                      text: 'Events Calendar'),
                  Tab(icon: Icon(Icons.list), text: 'Events List'),
                ],
              ),
            ),
            // Body with loading indicator, error banner, and tab views
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Show error banner if there's an error, but still show calendar
                      if (viewModel.error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: Colors.orange.shade100,
                          child: Row(
                            children: [
                              // Warning icon and error message
                              Icon(Icons.warning,
                                  color: Colors.orange.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.error!,
                                  style:
                                      TextStyle(color: Colors.orange.shade900),
                                ),
                              ),
                              // Retry button
                              TextButton(
                                onPressed: () => viewModel.loadEvents(),
                                child: const Text('Retry'),
                              ),
                              // Dismiss button
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => viewModel.clearError(),
                                color: Colors.orange.shade900,
                                tooltip: 'Dismiss',
                              ),
                            ],
                          ),
                        ),
                      // Always show the calendar and events list
                      Expanded(
                        child: TabBarView(
                          // Two tabs: Calendar view and Events list view
                          children: [
                            _buildCalendarTab(viewModel),
                            _buildEventsListTab(viewModel),
                          ],
                        ),
                      ),
                    ],
                  ),

            // Floating action button to add new events
            floatingActionButton: _canAddEvent(context)
                ? FloatingActionButton.extended(
                    backgroundColor: const Color(0xFF90C048),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Event',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      final targetDate =
                          viewModel.selectedDay ?? viewModel.focusedDay;
                      _openEventForm(context, viewModel, targetDate);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  // Build the calendar tab view
  Widget _buildCalendarTab(CalendarViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        //Welcome Message and Calendar widget
        children: [
          KenwellSectionHeader(
            title: _getWelcomeTitle(),
            subtitle: 'View and manage your wellness events for the month.',
            textAlign: TextAlign.center,
            icon: Icons.calendar_month,
          ),
          const SizedBox(height: 10),
          const AppLogo(size: 150),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Calendar widget inside a form card
            child: KenwellFormCard(
              child: TableCalendar(
                // Calendar configuration
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(3000, 12, 31),
                focusedDay: viewModel.focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(viewModel.selectedDay, day),
                eventLoader: (day) => viewModel.getEventsForDay(day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                // Calendar styles
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF201C58),
                  ),
                ),
                // Days of week styles
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                // Calendar day styles
                calendarStyle: CalendarStyle(
                  // Styles for weekdays and weekends
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  // Styles for today, selected day, and event markers
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF90C048),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF201C58),
                    shape: BoxShape.circle,
                  ),
                ),
                // Handle day selection and page changes
                onDaySelected: (selectedDay, focusedDay) async {
                  viewModel.setSelectedDay(selectedDay);
                  viewModel.setFocusedDay(focusedDay);
                  // Show dialog with events for the selected day
                  final eventsForDay = viewModel.getEventsForDay(selectedDay);
                  showDialog(
                    context: context,
                    builder: (ctx) => DayEventsDialog(
                      selectedDay: selectedDay,
                      events: eventsForDay,
                      viewModel: viewModel,
                      // Callback to open the event form
                      onOpenEventForm: (date, {WellnessEvent? existingEvent}) =>
                          _openEventForm(context, viewModel, date,
                              existingEvent: existingEvent),
                    ),
                  );
                },
                // Handle month navigation
                onPageChanged: (focusedDay) {
                  viewModel.setFocusedDay(focusedDay);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Build the events list tab view
  Widget _buildEventsListTab(CalendarViewModel viewModel) {
    // Get events for the focused month
    final eventsThisMonth = viewModel.getEventsForMonth(viewModel.focusedDay);

    return Column(
      children: [
        //Welcome Message and Month Navigation Header
        KenwellSectionHeader(
          title: _getWelcomeTitle(),
          subtitle: 'View and manage your wellness events for the month.',
          textAlign: TextAlign.center,
          icon: Icons.calendar_month,
        ),
        const SizedBox(height: 10),
        const AppLogo(size: 150),
        const SizedBox(height: 10),
        // Month navigation header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous month button
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => viewModel.goToPreviousMonth(),
              ),
              // Month and year title
              Text(
                viewModel.getMonthYearTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF201C58),
                ),
              ),
              // Next month button
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => viewModel.goToNextMonth(),
              ),
            ],
          ),
        ),
        // Events list
        Expanded(
          child: eventsThisMonth.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // No events illustration and message
                        Icon(
                          Icons.event_busy,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        // Informative message
                        Text(
                          'No events this month',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Suggestion to create events
                        if (_canAddEvent(context))
                          Text(
                            'Create an event to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Button to create a new event
                        if (_canAddEvent(context))
                          CustomPrimaryButton(
                            label: 'Create Event',
                            onPressed: () => _openEventForm(
                                context, viewModel, viewModel.focusedDay),
                            leading: const Icon(Icons.add),
                          ),
                      ],
                    ),
                  ),
                )
              // List of events for the month
              : Builder(
                  builder: (_) {
                    // Sort events
                    final sortedEvents = [...eventsThisMonth];
                    sortedEvents.sort(viewModel.compareEvents);

                    // Group events by day
                    final Map<DateTime, List<WellnessEvent>> groupedEvents = {};
                    for (var event in sortedEvents) {
                      final dayKey = viewModel.normalizeDate(event.date);
                      groupedEvents.putIfAbsent(dayKey, () => []).add(event);
                    }

                    final sortedDates = groupedEvents.keys.toList()
                      ..sort((a, b) => a.compareTo(b));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final day = sortedDates[index];
                        final dayEvents = groupedEvents[day]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day header
                            KenwellSectionHeader(
                              title: viewModel.formatDateLong(day),
                              icon: Icons.event,
                              showBackground: false,
                            ),
                            const SizedBox(height: 8),
                            // Event cards for the day
                            ...dayEvents
                                .map((event) => EventCard(
                                    event: event, viewModel: viewModel))
                                .toList(),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Open the event form for adding or editing events
  Future<void> _openEventForm(
      BuildContext context, CalendarViewModel viewModel, DateTime date,
      {WellnessEvent? existingEvent}) async {
    // Use global EventViewModel from provider
    final eventViewModel = context.read<EventViewModel>();
    await eventViewModel.initialized;

    // Navigate to the EventScreen
    if (!context.mounted) return;

    // Push EventScreen and wait for it to close
    await Navigator.push(
      context,
      // Navigate to EventScreen
      MaterialPageRoute(
        builder: (_) => EventScreen(
          date: date,
          existingEvent: existingEvent,
          onSave: (event) async {
            if (existingEvent == null) {
              await viewModel.addEvent(event);
            } else {
              await viewModel.updateEvent(event);
            }
          },
          viewModel: eventViewModel,
        ),
      ),
    );
  }
}
