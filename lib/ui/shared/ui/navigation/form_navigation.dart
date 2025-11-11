import 'package:flutter/material.dart';
import '../buttons/custom_primary_button.dart';
import '../buttons/custom_secondary_button.dart';
import '../colours/kenwell_colours.dart';

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
            child: CustomSecondaryButton(
              label: previousLabel,
              onPressed: onPrevious,
            ),
          ),
        if (onPrevious != null) SizedBox(width: spacing),
        Expanded(
          child: CustomPrimaryButton(
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
