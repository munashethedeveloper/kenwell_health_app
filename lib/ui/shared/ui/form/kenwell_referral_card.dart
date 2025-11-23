import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'kenwell_form_card.dart';
import 'kenwell_form_styles.dart';

/// Configuration for a single referral option inside the shared referral card.
class KenwellReferralOption<T> {
  final T value;
  final String label;
  final bool requiresReason;
  final TextEditingController? reasonController;
  final String? reasonLabel;
  final int reasonMaxLines;

  const KenwellReferralOption({
    required this.value,
    required this.label,
    this.requiresReason = false,
    this.reasonController,
    this.reasonLabel,
    this.reasonMaxLines = 2,
  });
}

/// Standardized card for rendering referral radio groups with optional reason inputs.
class KenwellReferralCard<T> extends StatelessWidget {
  final String title;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;
  final List<KenwellReferralOption<T>> options;
  final FormFieldValidator<String>? reasonValidator;

  const KenwellReferralCard({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.onChanged,
    required this.options,
    this.reasonValidator,
  });

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...options.map((option) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<T>(
                    title: Text(option.label),
                    value: option.value,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    groupValue: selectedValue,
                    onChanged: onChanged,
                  ),
                  if (option.requiresReason &&
                      selectedValue == option.value &&
                      option.reasonController != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                      child: KenwellTextField(
                        label: option.reasonLabel ?? 'Reason',
                        controller: option.reasonController!,
                        maxLines: option.reasonMaxLines,
                        decoration: KenwellFormStyles.decoration(
                          label: option.reasonLabel ?? 'Reason',
                        ),
                        validator: reasonValidator,
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }
}
