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
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';

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

  Future<void> _logout() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.logout();
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
                      Navigator.pushNamed(context, RouteNames.profile);
                    }
                    break;
                  case 1:
                    if (mounted) Navigator.pushNamed(context, RouteNames.help);
                    break;
                  case 2:
                    await _logout();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.black),
                    title: Text('Profile'),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.help_outline, color: Colors.black),
                    title: Text('Help'),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
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
        body: TabBarView(
          children: [
            // ===== Calendar Tab =====
            SingleChildScrollView(
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
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ===== Events List Tab (Scrollable) =====
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const AppLogo(size: 200),
                  const SizedBox(height: 16),
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
                            color: Color(0xFF201C58),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _goToNextMonth,
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (_) {
                      final eventsThisMonth = _getEventsForMonth(_focusedDay);
                      if (eventsThisMonth.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text("No events for this month."),
                          ),
                        );
                      }

                      eventsThisMonth.sort(_compareEvents);

                      final Map<DateTime, List<WellnessEvent>> groupedEvents =
                          {};
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
                                            builder: (dialogContext) =>
                                                AlertDialog(
                                              title: const Text('Delete Event'),
                                              content: const Text(
                                                'Are you sure you want to delete this event?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                          dialogContext)
                                                      .pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                          dialogContext)
                                                      .pop(true),
                                                  style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        onDismissed: (direction) async {
                                          final deletedEvent =
                                              await widget.eventVM.deleteEvent(
                                                  groupedEvents[day]![i].id);
                                          if (deletedEvent != null &&
                                              context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    const Text('Event deleted'),
                                                action: SnackBarAction(
                                                  label: 'UNDO',
                                                  onPressed: () {
                                                    widget.eventVM.restoreEvent(
                                                        deletedEvent);
                                                  },
                                                ),
                                                duration:
                                                    const Duration(seconds: 5),
                                              ),
                                            );
                                          }
                                        },
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          color: Colors.red,
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: i ==
                                                      groupedEvents[day]!
                                                              .length -
                                                          1
                                                  ? 0
                                                  : 12),
                                          child: _buildModernEventCard(
                                              groupedEvents[day]![i]),
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

  Widget _buildModernEventCard(WellnessEvent event) {
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
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _eventGradient(String _) {
    return const [
      KenwellColors.primaryGreenLight,
      KenwellColors.primaryGreen,
    ];
  }

  int _compareEvents(WellnessEvent a, WellnessEvent b) {
    final dateComparison = a.date.compareTo(b.date);
    if (dateComparison != 0) return dateComparison;

    final aMinutes = _timeStringToMinutes(a.startTime);
    final bMinutes = _timeStringToMinutes(b.startTime);

    if (aMinutes != null && bMinutes != null) {
      final timeComparison = aMinutes.compareTo(bMinutes);
      if (timeComparison != 0) {
        return timeComparison;
      }
    } else if (aMinutes != null) {
      return -1;
    } else if (bMinutes != null) {
      return 1;
    }

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  int? _timeStringToMinutes(String raw) {
    if (raw.trim().isEmpty) return null;
    final timeText = raw.trim();

    final formatters = <DateFormat>[DateFormat.Hm(), DateFormat.jm()];

    for (final formatter in formatters) {
      try {
        final parsed = formatter.parse(timeText);
        return parsed.hour * 60 + parsed.minute;
      } catch (_) {
        continue;
      }
    }

    final match =
        RegExp(r'^(?<hour>\d{1,2}):(?<minute>\d{2})').firstMatch(timeText);
    if (match != null) {
      final hour = int.tryParse(match.namedGroup('hour') ?? '');
      final minute = int.tryParse(match.namedGroup('minute') ?? '');
      if (hour != null && minute != null && hour < 24 && minute < 60) {
        return hour * 60 + minute;
      }
    }

    return null;
  }

  Future<void> _openEventForm(DateTime date,
      {WellnessEvent? existingEvent}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventScreen(
          date: date,
          existingEvent: existingEvent,
          onSave: (event) async {
            if (existingEvent == null) {
              await widget.eventVM.addEvent(event);
            } else {
              await widget.eventVM.updateEvent(event);
            }
          },
          viewModel: widget.eventVM,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  void _showDayActionsSheet(DateTime selectedDay, List<WellnessEvent> events) {
    final dayEvents = [...events]..sort(_compareEvents);

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
                      backgroundColor: _categoryColor(event.servicesRequested),
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
                CustomPrimaryButton(
                  label: 'Add another event',
                  leading: const Icon(Icons.add),
                  minHeight: 48,
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
    if (times.isNotEmpty) parts.add(times.join(' - '));

    final location = event.venue.isNotEmpty
        ? event.venue
        : (event.address.isNotEmpty ? event.address : '');
    if (location.isNotEmpty) parts.add(location);

    return parts.isEmpty ? 'Tap to edit' : parts.join(' · ');
  }
}
