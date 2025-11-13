import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../../routing/route_names.dart';
import '../../event/widgets/event_screen.dart';
import '../../event/view_model/event_view_model.dart';
import '../../../../data/services/auth_service.dart';

class CalendarScreen extends StatefulWidget {
  final EventViewModel eventVM;

  const CalendarScreen({super.key, required this.eventVM});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<WellnessEvent> _getEventsForDay(DateTime day) =>
      widget.eventVM.getEventsForDate(day);

  List<WellnessEvent> _getEventsForMonth(DateTime month) =>
      widget.eventVM.events
          .where((event) =>
              event.date.year == month.year && event.date.month == month.month)
          .toList();

  void _goToPreviousMonth() {
    setState(() =>
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1));
  }

  void _goToNextMonth() {
    setState(() =>
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1));
  }

  void _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'screening':
        return Colors.orange;
      case 'wellness':
        return Colors.green;
      case 'workshop':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Wellness Planner',
            style: TextStyle(
              color: Color(0xFF201C58),
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF90C048),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: Color(0xFF201C58)),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Events Calendar'),
              Tab(icon: Icon(Icons.list), text: 'Events List'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ===== Calendar Tab =====
            Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(3000, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  headerStyle: const HeaderStyle(formatButtonVisible: false),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventScreen(
                          date: selectedDay,
                          existingEvents:
                              widget.eventVM.getEventsForDate(selectedDay),
                          onSave: (newEvent) {
                            widget.eventVM.addEvent(newEvent);
                          },
                          viewModel: widget.eventVM,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // ===== Events List Tab =====
            Column(
              children: [
                // === Month Navigation ===
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _goToPreviousMonth,
                      ),
                      Text(
                        DateFormat.yMMMM().format(_focusedDay),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _goToNextMonth,
                      ),
                    ],
                  ),
                ),

                // === Events List ===
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final eventsThisMonth = _getEventsForMonth(_focusedDay);
                      if (eventsThisMonth.isEmpty) {
                        return const Center(
                          child: Text("No events for this month."),
                        );
                      }

                      eventsThisMonth.sort((a, b) => a.date.compareTo(b.date));

                      final Map<DateTime, List<WellnessEvent>> groupedEvents =
                          {};
                      for (var event in eventsThisMonth) {
                        final dayKey = _normalizeDate(event.date);
                        groupedEvents.putIfAbsent(dayKey, () => []).add(event);
                      }

                      final sortedDates = groupedEvents.keys.toList()
                        ..sort((a, b) => a.compareTo(b));

                      return ListView.builder(
                        itemCount: groupedEvents.length,
                        itemBuilder: (context, index) {
                          final day = sortedDates[index];
                          final events = groupedEvents[day]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                color: const Color(0xFF201C58),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Text(
                                  DateFormat.yMMMMd().format(day),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ...events.map(
                                (event) => Dismissible(
                                  key: Key(event.id),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
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
                                        );
                                      },
                                    );
                                  },
                                  onDismissed: (direction) {
                                    final deletedEvent =
                                        widget.eventVM.deleteEvent(event.id);
                                    if (deletedEvent != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              const Text('Event deleted'),
                                          action: SnackBarAction(
                                            label: 'UNDO',
                                            onPressed: () {
                                              widget.eventVM
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
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _categoryColor(
                                            event.servicesRequested),
                                      ),
                                      title: Text(
                                        event.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (event.address.isNotEmpty)
                                            Text('Address: ${event.address}'),
                                          if (event.venue.isNotEmpty)
                                            Text('Venue: ${event.venue}'),
                                          if (event.startTime.isNotEmpty)
                                            Text('Start: ${event.startTime}'),
                                          if (event.endTime.isNotEmpty)
                                            Text('End: ${event.endTime}'),
                                        ],
                                      ),
                                      onTap: () {
                                        // Navigate to EventDetailsScreen with the actual event
                                        Navigator.pushNamed(
                                          context,
                                          RouteNames.eventDetails,
                                          arguments: {
                                            'event': event,
                                            'viewModel': widget.eventVM,
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF201C58),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            final targetDate = _selectedDay ?? _focusedDay;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventScreen(
                  date: targetDate,
                  existingEvents: widget.eventVM.getEventsForDate(targetDate),
                  onSave: (newEvent) {
                    widget.eventVM.addEvent(newEvent);
                  },
                  viewModel: widget.eventVM,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
