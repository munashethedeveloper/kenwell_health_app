import 'package:flutter/material.dart';

/// A titled section card with a small icon badge in the header.
///
/// Wraps a list of [children] inside a white rounded container with a subtle
/// navy border and drop shadow.  The header row shows an icon badge on the
/// left and [title] text on the right, separated from the body by a divider.
///
/// Used in: [EventDetailsScreen], [MemberEventsScreen].
///
/// **Usage example:**
/// ```dart
/// KenwellSectionCard(
///   title: 'Event Details',
///   icon: Icons.info_outline_rounded,
///   children: [
///     KenwellDetailRow(label: 'Date', value: '2025-03-01'),
///     KenwellDetailRow(label: 'Venue', value: 'City Hall'),
///   ],
/// )
/// ```
class KenwellSectionCard extends StatelessWidget {
  const KenwellSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  // Shared navy accent colour used for icon and text.
  static const _navyColor = Color(0xFF201C58);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _navyColor.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _navyColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _navyColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _navyColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Divider between header and content
          Divider(
            height: 1,
            thickness: 1,
            color: _navyColor.withValues(alpha: 0.06),
          ),
          // ── Content area ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
