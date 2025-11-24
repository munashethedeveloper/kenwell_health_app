import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../colours/kenwell_colours.dart';
import 'custom_text_field.dart';
import 'kenwell_form_styles.dart';

/// Reusable date picker text field with consistent styling.
class KenwellDateField extends StatelessWidget {
  const KenwellDateField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.dateFormat = 'dd/MM/yyyy',
    this.onDateSelected,
    this.validator,
    this.enabled = true,
    this.readOnly = true,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String dateFormat;
  final ValueChanged<DateTime>? onDateSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return KenwellTextField(
      label: label,
      hintText: hint ?? 'Select $label',
      controller: controller,
      readOnly: readOnly,
      enabled: enabled,
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: hint ?? 'Select $label',
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          size: 20,
          color: KenwellColors.primaryGreen,
        ),
      ),
      validator: validator ??
          (val) => (val == null || val.isEmpty) ? 'Please select $label' : null,
      onTap: enabled
          ? () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(2000),
                lastDate: lastDate ?? DateTime(2100),
              );
              if (pickedDate != null) {
                controller.text = DateFormat(dateFormat).format(pickedDate);
                onDateSelected?.call(pickedDate);
              }
            }
          : null,
    );
  }
}
