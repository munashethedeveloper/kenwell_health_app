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
    this.leading,
    this.labelStyle,
    this.iconGap = 8,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final Widget? leading;
  final TextStyle? labelStyle;
  final double iconGap;
  final bool fullWidth;

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
        minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
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
          : _buildLabel(resolvedForeground),
    );
  }

  Widget _buildLabel(Color resolvedForeground) {
    final textWidget = Text(
      label,
      style: labelStyle,
    );

    if (leading == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTheme(
          data: IconThemeData(color: resolvedForeground),
          child: leading!,
        ),
        SizedBox(width: iconGap),
        Flexible(child: textWidget),
      ],
    );
  }
}
