import 'package:flutter/material.dart';
import '../colours/kenwell_colours.dart';
import 'custom_primary_button.dart';

/// Reusable form action buttons (Cancel and Save/Submit)
class FormActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  final bool isLoading;

  const FormActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.saveLabel = 'Save',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              side:
                  const BorderSide(color: KenwellColors.primaryGreen, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: KenwellColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomPrimaryButton(
            label: saveLabel,
            onPressed: isLoading ? null : onSave,
          ),
        ),
      ],
    );
  }
}
