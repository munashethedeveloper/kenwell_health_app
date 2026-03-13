import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../domain/models/wellness_event.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../view_model/calendar_view_model.dart';
import '../day_events_dialog.dart';

/// Calendar tab view displaying a full [TableCalendar] with event markers.
///
/// ## Marker strategy
/// - **1–2 events**: coloured dots are rendered below the day number.
/// - **3+ events**: a circular count badge replaces the dots to avoid clutter.
///
/// The [TableCalendar] widget's built-in markers are disabled
/// (`markersMaxCount: 0`) so this custom [CalendarBuilders.markerBuilder]
/// has full control over the rendering.
class CalendarTabView extends StatelessWidget {
  const CalendarTabView({
    super.key,
    required this.viewModel,
    required this.onOpenEventForm,
  });

  final CalendarViewModel viewModel;

  /// Callback invoked when the user wants to add/edit an event on [date].
  /// Pass [existingEvent] when editing an existing one.
  final void Function(
    DateTime date, {
    WellnessEvent? existingEvent,
  }) onOpenEventForm;

  // Marker colours also used by the legend widgets.
  static const Color _dotColor = Color(0xFF201C58);
  static const Color _badgeColor = Color(0xFF201C58);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsThisMonth =
        viewModel.getTotalEventsThisMonth(viewModel.focusedDay);
    final upcomingEventsCount = viewModel.getUpcomingEvents();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Stats strip ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CalendarStatChip(
                  icon: Icons.calendar_month_rounded,
                  label: 'This Month',
                  value: '$eventsThisMonth',
                  color: const Color(0xFF201C58),
                ),
                const SizedBox(width: 10),
                CalendarStatChip(
                  icon: Icons.upcoming_rounded,
                  label: "Upcoming Month's",
                  value: '$upcomingEventsCount',
                  color: KenwellColors.secondaryNavy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Calendar widget ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: KenwellColors.secondaryNavy.withValues(alpha: 0.08),
                  width: 2.5,
                ),
              ),
              child: KenwellFormCard(
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(3000, 12, 31),
                  focusedDay: viewModel.focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(viewModel.selectedDay, day),
                  eventLoader: (day) => viewModel.getEventsForDay(day),
                  calendarFormat: CalendarFormat.month,
                  // Monday start enforces a standard week layout
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
                    // Disable built-in markers; custom builder used instead
                    markersMaxCount: 0,
                    weekendTextStyle: const TextStyle(color: Colors.red),
                    todayDecoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF90C048),
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return const SizedBox.shrink();

                      if (events.length <= 2) {
                        // 1–2 events: coloured dot per event
                        return Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              events.length,
                              (_) => Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5),
                                decoration: const BoxDecoration(
                                  color: _dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      // 3+ events: count badge in bottom-right corner
                      return Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _badgeColor,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '${events.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) async {
                    viewModel.setSelectedDay(selectedDay);
                    viewModel.setFocusedDay(focusedDay);
                    final eventsForDay =
                        viewModel.getEventsForDay(selectedDay);
                    // Show events for the tapped day in a bottom sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => DayEventsDialog(
                        selectedDay: selectedDay,
                        events: eventsForDay,
                        viewModel: viewModel,
                        onOpenEventForm: (date, {existingEvent}) =>
                            onOpenEventForm(date,
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
          ),
          const SizedBox(height: 16),

          // ── Legend ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              children: [
                // Dot legend entry
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '1–2 events',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: KenwellColors.secondaryNavyDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                // Badge legend entry
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '3+ events — tap a date to view details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: KenwellColors.secondaryNavyDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Compact stat chip shown in the stats strip above the calendar.
///
/// Displays an [icon] badge on the left and a [value] + [label] column on
/// the right, all tinted by [color].
class CalendarStatChip extends StatelessWidget {
  const CalendarStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withValues(alpha: 0.18), width: 1),
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            // Value + label column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: KenwellColors.secondaryNavyDark,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
