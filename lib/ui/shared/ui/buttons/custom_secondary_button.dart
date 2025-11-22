import 'package:flutter/material.dart';
import '../colours/kenwell_colours.dart';

class CustomSecondaryButton extends StatelessWidget {
  const CustomSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.minHeight = 50,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final Color resolvedForeground =
        foregroundColor ?? KenwellColors.secondaryNavy;
    final Color resolvedBackground = backgroundColor ?? Colors.white;
    final Color resolvedBorder = borderColor ?? resolvedForeground;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
        padding: padding,
        backgroundColor: resolvedBackground,
        foregroundColor: resolvedForeground,
        side: BorderSide(color: resolvedBorder.withValues()),
      ),
      child: Text(label),
    );
  }
}
