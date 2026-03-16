import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../../../domain/models/wellness_event.dart';
import '../../view_model/calendar_view_model.dart';
import '../event_card.dart';

/// Events list tab view — shows all events for the focused month grouped by
/// calendar day.
///
/// A month navigation header (← Month Year →) lets the user page through
/// months without switching to the Calendar tab.  Events are sorted by start
/// time within each day, and grouped days are sorted ascending.
///
/// When no events exist for the month an empty-state illustration is shown.
class EventsListTabView extends StatelessWidget {
  const EventsListTabView({
    super.key,
    required this.viewModel,
    required this.canAddEvent,
  });

  final CalendarViewModel viewModel;

  /// Whether the current user has permission to add events.
  /// Used to conditionally show helper text in the empty state.
  final bool canAddEvent;

  @override
  Widget build(BuildContext context) {
    final eventsThisMonth = viewModel.getEventsForMonth(viewModel.focusedDay);
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),

        // ── Month navigation header ────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [KenwellColors.secondaryNavy, Color(0xFF2E2880)],
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
              // Previous month button
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
              Text(
                viewModel.getMonthYearTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 16),
              // Next month button
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

        // ── Events list or empty state ─────────────────────────────────
        Expanded(
          child: eventsThisMonth.isEmpty
              ? _buildEmptyState(context, theme)
              : _buildGroupedList(context, theme, eventsThisMonth),
        ),
      ],
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────

  /// Empty state shown when the month has no events.
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_busy_rounded,
                    size: 80,
                    color: theme.primaryColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
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
                if (canAddEvent)
                  Text(
                    'Create an event to get started',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Renders the sorted, day-grouped list of [WellnessEvent] cards.
  ///
  /// Grouping: events are sorted by start time, then grouped by normalised
  /// day key (midnight local time).  Each day group shows a coloured
  /// day-header row with an event count badge.
  Widget _buildGroupedList(
    BuildContext context,
    ThemeData theme,
    List<WellnessEvent> events,
  ) {
    // Sort events
    final sorted = [...events]..sort(viewModel.compareEvents);

    // Group by day (normalised to midnight)
    final Map<DateTime, List<WellnessEvent>> grouped = {};
    for (final event in sorted) {
      final key = viewModel.normalizeDate(event.date);
      grouped.putIfAbsent(key, () => []).add(event);
    }
    final sortedDays = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final dayEvents = grouped[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12, left: 4),
              child: Row(
                children: [
                  // Coloured left accent bar
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: KenwellColors.secondaryNavy,
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
                      color: theme.primaryColor.withValues(alpha: 0.15),
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
            ...dayEvents.map(
              (event) => EventCard(
                event: event,
                viewModel: viewModel,
                showBorder: true,
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
