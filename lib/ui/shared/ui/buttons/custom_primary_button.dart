import 'package:flutter/material.dart';
import '../colours/kenwell_colours.dart';

class CustomPrimaryButton extends StatelessWidget {
  const CustomPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.backgroundColor,
    this.foregroundColor,
    this.minHeight = 50,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double minHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackground =
        backgroundColor ?? KenwellColors.secondaryNavy;
    final Color resolvedForeground = foregroundColor ?? Colors.white;
    final bool isDisabled = onPressed == null || isBusy;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: resolvedBackground,
        foregroundColor: resolvedForeground,
        minimumSize: Size.fromHeight(minHeight),
        padding: padding,
      ),
      child: isBusy
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(resolvedForeground),
              ),
            )
          : Text(label),
    );
  }
}
