import 'package:flutter/material.dart';

/// A circular badge displaying a number
/// Used for sequential numbering in lists
class NumberBadge extends StatelessWidget {
  final int number;
  final double size;

  const NumberBadge({
    super.key,
    required this.number,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}
