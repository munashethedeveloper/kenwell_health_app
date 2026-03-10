import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// The small green pill badge shown above the page title in all gradient
/// header sections across the app.
///
/// Usage:
/// ```dart
/// KenwellSectionLabel(label: 'ANALYTICS')
/// KenwellSectionLabel(label: 'MANAGEMENT')
/// ```
///
/// The [label] is automatically uppercased so callers may pass either case.
class KenwellSectionLabel extends StatelessWidget {
  const KenwellSectionLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: KenwellColors.primaryGreen.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KenwellColors.primaryGreen.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: KenwellColors.primaryGreenLight,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
