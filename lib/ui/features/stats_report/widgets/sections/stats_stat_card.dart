import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// A compact stat summary card used in the event statistics dashboard.
///
/// Shows an icon badge, a large numeric [value], and a [title] label.
/// The entire card is tinted using the supplied [color].
///
/// **Usage example:**
/// ```dart
/// StatsStatCard(
///   icon: Icons.people_outline_rounded,
///   title: 'Total Screened',
///   value: '142',
///   color: KenwellColors.primaryGreen,
/// )
/// ```
class StatsStatCard extends StatelessWidget {
  const StatsStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge with gradient background
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          // Value (large number)
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: KenwellColors.secondaryNavy,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          // Label
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
