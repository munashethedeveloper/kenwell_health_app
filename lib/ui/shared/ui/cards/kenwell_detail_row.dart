import 'package:flutter/material.dart';

/// A labelled detail row used in information/summary screens.
///
/// Renders a fixed-width [label] column (130 px) alongside an [Expanded]
/// [value] column.  Both columns start at the top when values wrap.
///
/// Used in: [EventDetailsScreen], [MemberEventsScreen].
///
/// **Usage example:**
/// ```dart
/// KenwellDetailRow(label: 'Date', value: event.dateString),
/// KenwellDetailRow(label: 'Venue', value: event.venue),
/// ```
class KenwellDetailRow extends StatelessWidget {
  const KenwellDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed-width label column
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ),
          // Value expands to fill remaining space
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF201C58),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
