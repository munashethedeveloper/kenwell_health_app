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
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF201C58),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(color: Color(0xFF90C048)),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
              Tab(icon: Icon(Icons.list), text: 'List'),
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
                      weekdayStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      weekendStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    todayDecoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF90C048),
                      shape: BoxShape.circle,
                    ),
                  ),
                    onDaySelected: (selectedDay, focusedDay) async {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                      final eventsForDay = _getEventsForDay(selectedDay);
                      if (eventsForDay.isEmpty) {
                        await _openEventForm(selectedDay);
                      } else {
                        _showDayActionsSheet(selectedDay, eventsForDay);
                      }
                  },
                ),
              ],
            ),

            // ===== Events List Tab =====
            Column(
              children: [
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
                                          content: const Text('Event deleted'),
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
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF90C048),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Event', style: TextStyle(color: Colors.white)),
            onPressed: () {
              final targetDate = _selectedDay ?? _focusedDay;
              _openEventForm(targetDate);
            },
        ),
      ),
    );
  }

    Future<void> _openEventForm(DateTime date,
        {WellnessEvent? existingEvent}) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventScreen(
            date: date,
            existingEvent: existingEvent,
            onSave: (event) {
              if (existingEvent == null) {
                widget.eventVM.addEvent(event);
              } else {
                widget.eventVM.updateEvent(event);
              }
            },
            viewModel: widget.eventVM,
          ),
        ),
      );
      if (!mounted) return;
      setState(() {});
    }

    void _showDayActionsSheet(
        DateTime selectedDay, List<WellnessEvent> events) {
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
                  ...events.map(
                    (event) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _categoryColor(event.servicesRequested),
                      ),
                      title: Text(event.title),
                      subtitle: Text(_eventSubtitle(event)),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openEventForm(selectedDay, existingEvent: event);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add another event'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFF201C58),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openEventForm(selectedDay);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    String _eventSubtitle(WellnessEvent event) {
      final parts = <String>[];
      final times = [
        if (event.startTime.isNotEmpty) event.startTime,
        if (event.endTime.isNotEmpty) event.endTime,
      ];
      if (times.isNotEmpty) {
        parts.add(times.join(' - '));
      }
      final location = event.venue.isNotEmpty
          ? event.venue
          : (event.address.isNotEmpty ? event.address : '');
      if (location.isNotEmpty) {
        parts.add(location);
      }
      return parts.isEmpty ? 'Tap to edit' : parts.join(' · ');
    }
}
