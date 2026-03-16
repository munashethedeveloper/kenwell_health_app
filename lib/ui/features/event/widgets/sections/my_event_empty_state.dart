import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Empty-state widget shown when no events match the currently selected tab.
///
/// Pass [isToday] to get tab-specific messaging: "No Events Today" vs
/// "No Upcoming Events".
class MyEventEmptyState extends StatelessWidget {
  const MyEventEmptyState({super.key, required this.isToday});

  /// True when shown on the "Today" tab; false for the "Upcoming" tab.
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular icon background
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: KenwellColors.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isToday ? Icons.today_rounded : Icons.date_range_rounded,
              size: 56,
              color: KenwellColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isToday ? 'No Events Today' : 'No Upcoming Events',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KenwellColors.secondaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? 'You have no events scheduled for today.\nCheck the Upcoming tab for future events.'
                : 'No events have been allocated to you yet.\nContact your administrator to be assigned.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
