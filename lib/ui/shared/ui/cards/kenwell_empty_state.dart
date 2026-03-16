import 'package:flutter/material.dart';

/// A reusable empty-state widget used across list screens when no data is
/// available (e.g. no members, no users, no events).
///
/// Renders a centred column with a circular icon background, a bold title
/// and a softer message below.  The [icon] and accent [color] are
/// customisable so the widget can fit any screen's visual language.
///
/// **Usage example:**
/// ```dart
/// KenwellEmptyState(
///   icon: Icons.people_outline_rounded,
///   title: 'No Members Found',
///   message: 'Try adjusting your search or filter.',
/// )
/// ```
class KenwellEmptyState extends StatelessWidget {
  const KenwellEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.color,
  });

  final String title;
  final String message;

  /// Icon displayed inside the circular background.
  final IconData icon;

  /// Accent colour for the icon background and icon itself.  Defaults to the
  /// theme's primary colour when not supplied.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular icon container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF201C58),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
