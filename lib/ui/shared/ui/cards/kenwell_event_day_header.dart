import 'package:flutter/material.dart';
import '../colours/kenwell_colours.dart';

/// A day-group header for event list views.
///
/// Renders:  [accent bar]  [date label]  [···divider···]  [N event badge]
///
/// Used by both [AllEventsScreen] and [EventsListTabView] to ensure a
/// consistent look across all event-list surfaces.
class KenwellEventDayHeader extends StatelessWidget {
  const KenwellEventDayHeader({
    super.key,
    required this.label,
    required this.eventCount,
  });

  /// Pre-formatted date string, e.g. "Friday, 15 March 2024".
  final String label;

  /// Number of events on this day, shown as a small count badge.
  final int eventCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          // Coloured left accent bar
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          // Date label
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KenwellColors.secondaryNavy,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(width: 8),
          // Horizontal rule
          Expanded(
            child: Divider(
              color: KenwellColors.secondaryNavy.withValues(alpha: 0.12),
              height: 1,
            ),
          ),
          const SizedBox(width: 8),
          // Event count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$eventCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
