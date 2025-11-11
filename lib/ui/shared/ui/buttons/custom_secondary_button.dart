import 'package:flutter/material.dart';
import '../colours/kenwell_colours.dart';

class CustomSecondaryButton extends StatelessWidget {
  const CustomSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.minHeight = 50,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  final String label;
  final VoidCallback? onPressed;
  final double minHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(minHeight),
        padding: padding,
        backgroundColor: Colors.white,
        foregroundColor: KenwellColors.secondaryNavy,
        side: BorderSide(color: KenwellColors.secondaryNavy.withValues()),
      ),
      child: Text(label),
    );
  }
}
