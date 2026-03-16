import 'package:flutter/material.dart';

/// A compact inline badge showing an icon + text label in a given [color].
///
/// Used to display quick stats (e.g. verified / unverified count) inside
/// list cards.
///
/// ```dart
/// StatPill(
///   icon: Icons.verified_rounded,
///   label: '12 verified',
///   color: Colors.green,
/// )
/// ```
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
