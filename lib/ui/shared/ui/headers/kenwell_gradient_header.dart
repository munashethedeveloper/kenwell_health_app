import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';

/// Standard gradient section header used on every screen in the app.
///
/// Placed directly in the body Column, immediately below the [KenwellAppBar].
/// The gradient fills edge-to-edge with no rounded corners so it butts flush
/// against the app bar.
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: KenwellAppBar(title: 'KenWell365'),
///   body: Column(
///     children: [
///       KenwellGradientHeader(
///         label: 'EVENTS',
///         title: 'My\nEvents',
///         subtitle: 'View and manage your events.',
///       ),
///       Expanded(child: ...),
///     ],
///   ),
/// )
/// ```
class KenwellGradientHeader extends StatelessWidget {
  const KenwellGradientHeader({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;

  /// The standard body gradient shared by every screen.
  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      KenwellColors.secondaryNavy,
      Color(0xFF2E2880),
      KenwellColors.primaryGreenDark,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: _gradient),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KenwellSectionLabel(label: label),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
