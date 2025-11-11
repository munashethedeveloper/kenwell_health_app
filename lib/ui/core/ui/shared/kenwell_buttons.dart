import 'package:flutter/material.dart';

import 'kenwell_colors.dart';

class KenwellFilledButton extends StatelessWidget {
  const KenwellFilledButton({
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

class KenwellSecondaryButton extends StatelessWidget {
  const KenwellSecondaryButton({
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
        side: BorderSide(color: KenwellColors.secondaryNavy.withOpacity(0.4)),
      ),
      child: Text(label),
    );
  }
}

class KenwellFormNavigation extends StatelessWidget {
  const KenwellFormNavigation({
    super.key,
    required this.onNext,
    this.onPrevious,
    this.isNextEnabled = true,
    this.isNextBusy = false,
    this.previousLabel = 'Previous',
    this.nextLabel = 'Next',
    this.spacing = 16,
  });

  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final bool isNextEnabled;
  final bool isNextBusy;
  final String previousLabel;
  final String nextLabel;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onPrevious != null)
          Expanded(
            child: KenwellSecondaryButton(
              label: previousLabel,
              onPressed: onPrevious,
            ),
          ),
        if (onPrevious != null) SizedBox(width: spacing),
        Expanded(
          child: KenwellFilledButton(
            label: nextLabel,
            onPressed: isNextEnabled ? onNext : null,
            isBusy: isNextBusy,
            backgroundColor: KenwellColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
