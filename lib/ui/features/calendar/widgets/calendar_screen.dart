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
import '../../../shared/ui/form/kenwell_modern_section_header.dart';
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
          KenwellModernSectionHeader(
            title: _getWelcomeTitle(),
            //subtitle: 'View and manage your wellness events for the month.',
            textAlign: TextAlign.center,
            //icon: Icons.calendar_month,
          ),
          //const SizedBox(height: 10),
          //const AppLogo(size: 150),
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
    final theme = Theme.of(context);

    return Column(
      children: [
        //Welcome Message and Month Navigation Header
        KenwellModernSectionHeader(
          title: _getWelcomeTitle(),
          //subtitle: 'View and manage your wellness events for the month.',
          textAlign: TextAlign.center,
          //icon: Icons.calendar_month,
        ),
        // const SizedBox(height: 10),
        //const AppLogo(size: 150),
        const SizedBox(height: 10),
        // Enhanced month navigation header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.08),
                theme.primaryColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous month button with enhanced styling
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => viewModel.goToPreviousMonth(),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: const Color(0xFF201C58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Month and year title with enhanced typography
              Text(
                viewModel.getMonthYearTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF201C58),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 16),
              // Next month button with enhanced styling
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => viewModel.goToNextMonth(),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: const Color(0xFF201C58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Events list
        Expanded(
          child: eventsThisMonth.isEmpty
              ? SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Enhanced no events illustration
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event_busy_rounded,
                                size: 80,
                                color:
                                    theme.primaryColor.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Informative message with enhanced typography
                            Text(
                              'No events this month',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Suggestion to create events
                            if (_canAddEvent(context))
                              Text(
                                'Create an event to get started',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            const SizedBox(height: 32),
                            // Enhanced button to create a new event
                            if (_canAddEvent(context))
                              CustomPrimaryButton(
                                label: 'Create Event',
                                onPressed: () => _openEventForm(
                                    context, viewModel, viewModel.focusedDay),
                                leading: const Icon(Icons.add_rounded),
                              ),
                          ],
                        ),
                      ),
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
                            // Enhanced day header with better styling
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, bottom: 12, left: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      viewModel.formatDateLong(day),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  // Event count badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${dayEvents.length}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Event cards for the day
                            ...dayEvents
                                .map((event) => EventCard(
                                    event: event, viewModel: viewModel))
                                .toList(),
                            const SizedBox(height: 8),
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
