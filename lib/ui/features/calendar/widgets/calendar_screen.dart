import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../../routing/route_names.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../event/view_model/event_view_model.dart';
import '../../event/widgets/event_screen.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/calendar_view_model.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(),
      child: const _CalendarScreenBody(),
    );
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

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _logout() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: KenwellAppBar(
              title: 'Wellness Planner',
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              automaticallyImplyLeading: false,
              actions: [
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        if (mounted) {
                          Navigator.pushNamed(context, RouteNames.help);
                        }
                        break;
                      case 1:
                        await _logout();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<int>(
                      value: 0,
                      child: ListTile(
                        leading: Icon(Icons.help_outline, color: Colors.black),
                        title: Text('Help'),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: ListTile(
                        leading: Icon(Icons.logout, color: Colors.black),
                        title: Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
              bottom: const TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(color: Color(0xFF90C048)),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(icon: Icon(Icons.calendar_today), text: 'Events Calendar'),
                  Tab(icon: Icon(Icons.list), text: 'Events List'),
                ],
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(viewModel.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => viewModel.loadEvents(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        children: [
                          _buildCalendarTab(viewModel),
                          _buildEventsListTab(viewModel),
                        ],
                      ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF90C048),
              icon: const Icon(Icons.add, color: Colors.white),
              label:
                  const Text('Add Event', style: TextStyle(color: Colors.white)),
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
          const AppLogo(size: 200),
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
                    color: Colors.greenAccent.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF90C048),
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) async {
                  viewModel.setSelectedDay(selectedDay);
                  viewModel.setFocusedDay(focusedDay);
                  final eventsForDay = viewModel.getEventsForDay(selectedDay);
                  if (eventsForDay.isEmpty) {
                    await _openEventForm(context, viewModel, selectedDay);
                  } else {
                    _showDayActionsSheet(
                        context, viewModel, selectedDay, eventsForDay);
                  }
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const AppLogo(size: 200),
          const SizedBox(height: 16),
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
                  DateFormat.yMMMM().format(viewModel.focusedDay),
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
          Builder(
            builder: (_) {
              final eventsThisMonth =
                  viewModel.getEventsForMonth(viewModel.focusedDay);
              if (eventsThisMonth.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text("No events for this month."),
                  ),
                );
              }

              eventsThisMonth.sort(viewModel.compareEvents);

              final Map<DateTime, List<WellnessEvent>> groupedEvents = {};
              for (var event in eventsThisMonth) {
                final dayKey = _normalizeDate(event.date);
                groupedEvents.putIfAbsent(dayKey, () => []).add(event);
              }

              final sortedDates = groupedEvents.keys.toList()
                ..sort((a, b) => a.compareTo(b));

              return Column(
                children: [
                  for (var day in sortedDates) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: KenwellFormCard(
                        title: DateFormat.yMMMMd().format(day),
                        child: Column(
                          children: [
                            for (int i = 0;
                                i < groupedEvents[day]!.length;
                                i++) ...[
                              Dismissible(
                                key: Key(groupedEvents[day]![i].id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete Event'),
                                      content: const Text(
                                        'Are you sure you want to delete this event?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext)
                                                  .pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext)
                                                  .pop(true),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) async {
                                  final deletedEvent =
                                      await viewModel.deleteEvent(
                                          groupedEvents[day]![i].id);
                                  if (deletedEvent != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Event deleted'),
                                        action: SnackBarAction(
                                          label: 'UNDO',
                                          onPressed: () {
                                            viewModel
                                                .restoreEvent(deletedEvent);
                                          },
                                        ),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    // Create EventViewModel for event details
                                    final eventViewModel = EventViewModel();
                                    await eventViewModel.initializationFuture;
                                    
                                    if (!context.mounted) return;
                                    
                                    await Navigator.pushNamed(
                                      context,
                                      RouteNames.eventDetails,
                                      arguments: {
                                        'event': groupedEvents[day]![i],
                                        'viewModel': eventViewModel,
                                      },
                                    );
                                    
                                    // Reload events after returning from details screen
                                    if (context.mounted) {
                                      await viewModel.loadEvents();
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: i ==
                                                groupedEvents[day]!.length - 1
                                            ? 0
                                            : 12),
                                    child: _buildFormEventCard(
                                        viewModel, groupedEvents[day]![i]),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /*Widget _buildModernEventCard(WellnessEvent event) {
    final gradient = _eventGradient(event.servicesRequested);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteNames.eventDetails,
          arguments: {
            'event': event,
            'viewModel': widget.eventVM,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.event,
                    color: gradient.last,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.venue.isNotEmpty
                            ? event.venue
                            : (event.address.isNotEmpty ? event.address : ''),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (event.startTime.isNotEmpty || event.endTime.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label:
                        (event.startTime.isNotEmpty && event.endTime.isNotEmpty)
                            ? '${event.startTime} - ${event.endTime}'
                            : (event.startTime.isNotEmpty
                                ? event.startTime
                                : event.endTime),
                  ),
                if (event.expectedParticipation > 0)
                  _buildInfoChip(
                    icon: Icons.people_alt_outlined,
                    label: '${event.expectedParticipation} expected',
                  ),
                if (event.servicesRequested.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.medical_services_outlined,
                    label: event.servicesRequested,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  } */

  Widget _buildFormEventCard(CalendarViewModel viewModel, WellnessEvent event) {
    return KenwellFormCard(
      title: 'Event Name: ${event.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Date: ${DateFormat.yMMMMd().format(event.date)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Start Time: ${event.startTime}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'End Time: ${event.endTime}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Address: ${event.address.isNotEmpty ? event.address : event.venue}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (event.servicesRequested.isNotEmpty)
                _infoChip(Icons.medical_services, event.servicesRequested),
              if (event.expectedParticipation > 0)
                _infoChip(
                    Icons.people, '${event.expectedParticipation} expected'),
            ],
          ),
        ],
      ),
    );
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

  Future<void> _openEventForm(
      BuildContext context, CalendarViewModel viewModel, DateTime date,
      {WellnessEvent? existingEvent}) async {
    // Create EventViewModel for the form
    final eventViewModel = EventViewModel();
    await eventViewModel.initializationFuture;

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

  void _showDayActionsSheet(BuildContext context, CalendarViewModel viewModel,
      DateTime selectedDay, List<WellnessEvent> events) {
    final dayEvents = [...events]..sort(viewModel.compareEvents);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events on ${DateFormat.yMMMMd().format(selectedDay)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...dayEvents.map(
                  (event) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          viewModel.getCategoryColor(event.servicesRequested),
                    ),
                    title: Text(event.title),
                    subtitle: Text(viewModel.getEventSubtitle(event)),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openEventForm(context, viewModel, selectedDay,
                          existingEvent: event);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                CustomPrimaryButton(
                  label: 'Add another event',
                  leading: const Icon(Icons.add),
                  minHeight: 48,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openEventForm(context, viewModel, selectedDay);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
