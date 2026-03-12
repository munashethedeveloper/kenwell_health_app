import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  const CustomPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.backgroundColor,
    this.foregroundColor,
    this.minHeight = 50,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.leading,
    this.labelStyle,
    this.iconGap = 8,
    this.fullWidth = false,
    this.margin,
    this.minWidth = 600,
    this.maxWidthFactor = 0.8,
    //this.maxWidthFactor = 2.0,
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
  final EdgeInsetsGeometry? margin;
  final double minWidth;
  final double maxWidthFactor;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackground =
        backgroundColor ?? Theme.of(context).colorScheme.primary;

    final Color resolvedForeground =
        foregroundColor ?? Theme.of(context).colorScheme.onPrimary;

    final bool isDisabled = onPressed == null || isBusy;

    final button = FilledButton(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: resolvedBackground,
        foregroundColor: resolvedForeground,
        minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isBusy
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(resolvedForeground),
              ),
            )
          : _buildLabel(resolvedForeground),
    );

    final constrained = fullWidth
        ? button
        : Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth,
                maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
              ),
              child: button,
            ),
          );

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: constrained,
      );
    }
    return constrained;
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
          //suffixIcon: suffixIcon,
        ),
        SizedBox(width: iconGap),
        Flexible(child: textWidget),
      ],
    );
  }
}
