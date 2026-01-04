import 'package:flutter/material.dart';
import '../buttons/custom_primary_button.dart';

/// A reusable information dialog for displaying helpful messages
class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData? icon;
  final Color? iconColor;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Got it',
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? Colors.blue),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        CustomPrimaryButton(
          label: buttonText,
          minHeight: 40,
          fullWidth: false,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Shows an info dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Got it',
    IconData? icon,
    Color? iconColor,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? Colors.blue),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            CustomPrimaryButton(
              label: buttonText,
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }
}
