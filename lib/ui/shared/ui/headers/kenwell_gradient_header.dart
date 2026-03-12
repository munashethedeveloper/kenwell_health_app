import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';

/// Standard gradient section header used on every screen in the app.
///
/// Rendered as a rounded card with a navy drop-shadow, placed directly in the
/// body Column immediately below the [KenwellAppBar].
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
    this.label,
    required this.title,
    required this.subtitle,
  });

  final String? label;
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
    stops: [0.0, 0.6, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KenwellColors.secondaryNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  KenwellSectionLabel(label: label!),
                  const SizedBox(height: 10),
                ],
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
        ],
      ),
    );
  }
}
