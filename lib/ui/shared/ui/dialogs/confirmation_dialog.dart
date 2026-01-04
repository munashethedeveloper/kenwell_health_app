import 'package:flutter/material.dart';
import '../buttons/custom_primary_button.dart';
import '../buttons/custom_secondary_button.dart';

/// A reusable confirmation dialog for important actions
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.confirmColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: confirmColor),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        CustomSecondaryButton(
          label: cancelText,
          minHeight: 40,
          fullWidth: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        CustomPrimaryButton(
          label: confirmText,
          backgroundColor: confirmColor ?? Colors.red,
          foregroundColor: Colors.white,
          minHeight: 40,
          fullWidth: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
        ),
      ],
    );
  }

  /// Shows a confirmation dialog and returns true if confirmed
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: confirmColor),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            CustomSecondaryButton(
              label: cancelText,
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            CustomPrimaryButton(
              label: confirmText,
              backgroundColor: confirmColor ?? Colors.red,
              foregroundColor: Colors.white,
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
