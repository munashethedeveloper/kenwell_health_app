import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../routing/route_names.dart';
import '../../event/view_model/event_view_model.dart';
import '../../event/widgets/event_screen.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../view_model/calendar_view_model.dart';
import 'day_events_dialog.dart';
import 'event_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CalendarScreenBody();
  }
}

class _CalendarScreenBody extends StatefulWidget {
  const _CalendarScreenBody();

  @override
  State<_CalendarScreenBody> createState() => _CalendarScreenBodyState();
}

class _CalendarScreenBodyState extends State<_CalendarScreenBody> {
  @override
  void initState() {
    super.initState();
    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarViewModel>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: KenwellAppBar(
              title: 'Wellness Planner',
              automaticallyImplyLeading: false,
              titleColor: const Color(0xFF201C58),
              titleStyle: const TextStyle(
                color: Color(0xFF201C58),
                fontWeight: FontWeight.bold,
              ),
              actions: [
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
                TextButton.icon(
                  onPressed: () {
                    if (mounted) {
                      Navigator.pushNamed(context, RouteNames.help);
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
                tabs: const [
                  Tab(
                      icon: Icon(Icons.calendar_today),
                      text: 'Events Calendar'),
                  Tab(icon: Icon(Icons.list), text: 'Events List'),
                ],
              ),
            ),
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
                              TextButton(
                                onPressed: () => viewModel.loadEvents(),
                                child: const Text('Retry'),
                              ),
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
                          children: [
                            _buildCalendarTab(viewModel),
                            _buildEventsListTab(viewModel),
                          ],
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF90C048),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Event',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                final targetDate =
                    viewModel.selectedDay ?? viewModel.focusedDay;
                _openEventForm(context, viewModel, targetDate);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab(CalendarViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: KenwellFormCard(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(3000, 12, 31),
                focusedDay: viewModel.focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(viewModel.selectedDay, day),
                eventLoader: (day) => viewModel.getEventsForDay(day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF201C58),
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  weekendTextStyle: const TextStyle(color: Colors.red),
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
                onDaySelected: (selectedDay, focusedDay) async {
                  viewModel.setSelectedDay(selectedDay);
                  viewModel.setFocusedDay(focusedDay);
                  final eventsForDay = viewModel.getEventsForDay(selectedDay);
                  showDialog(
                    context: context,
                    builder: (ctx) => DayEventsDialog(
                      selectedDay: selectedDay,
                      events: eventsForDay,
                      viewModel: viewModel,
                      onOpenEventForm: (date, {WellnessEvent? existingEvent}) =>
                          _openEventForm(context, viewModel, date,
                              existingEvent: existingEvent),
                    ),
                  );
                },
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

  Widget _buildEventsListTab(CalendarViewModel viewModel) {
    final eventsThisMonth = viewModel.getEventsForMonth(viewModel.focusedDay);

    return Column(
      children: [
        // Month navigation header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => viewModel.goToPreviousMonth(),
              ),
              Text(
                viewModel.getMonthYearTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF201C58),
                ),
              ),
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
                        Icon(
                          Icons.event_busy,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events this month',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an event to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
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
                            KenwellSectionHeader(
                              title: viewModel.formatDateLong(day),
                            ),
                            const SizedBox(height: 8),
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

  Future<void> _openEventForm(
      BuildContext context, CalendarViewModel viewModel, DateTime date,
      {WellnessEvent? existingEvent}) async {
    // Use global EventViewModel from provider
    final eventViewModel = context.read<EventViewModel>();
    await eventViewModel.initialized;

    if (!context.mounted) return;

    await Navigator.push(
      context,
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
