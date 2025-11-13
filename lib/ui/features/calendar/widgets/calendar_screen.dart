import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../routing/route_names.dart';
import '../../event/widgets/event_screen.dart';
import '../view_model/calendar_view_model.dart';

class CalendarScreen extends StatefulWidget {
  final CalendarViewModel vm;

  const CalendarScreen({super.key, required this.vm});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final CalendarViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = widget.vm;
  }

  void _openEventScreen(DateTime date) {
    final eventsForDay = vm.getEventsForDay(date);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventScreen(
          date: date,
          existingEvents: eventsForDay,
          onSave: (newEvent) {
            vm.addEvent(newEvent);
          },
        ),
      ),
    );
  }

  void _logout() async {
    // Replace this with your AuthService logout if needed
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

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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
                  focusedDay: vm.focusedDay,
                  selectedDayPredicate: (day) => isSameDay(vm.selectedDay, day),
                  eventLoader: vm.getEventsForDay,
                  headerStyle: const HeaderStyle(formatButtonVisible: false),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      vm.setSelectedDay(selectedDay);
                      vm.setFocusedDay(focusedDay);
                    });
                    _openEventScreen(selectedDay);
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
                        onPressed: () {
                          setState(() => vm.goToPreviousMonth());
                        },
                      ),
                      Text(
                        DateFormat.yMMMM().format(vm.focusedDay),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() => vm.goToNextMonth());
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final eventsThisMonth =
                          vm.getEventsForMonth(vm.focusedDay);

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
                                (event) => Card(
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
                                    onTap: () => _openEventScreen(event.date),
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
            final targetDate = vm.selectedDay ?? vm.focusedDay;
            _openEventScreen(targetDate);
          },
        ),
      ),
    );
  }
}
