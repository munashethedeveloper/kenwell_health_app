import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';

/// Reusable widget for healthcare professional option (Yes/No dropdown + conditional count spinbox)
class HealthcareProfessionalOption extends StatelessWidget {
  final String label;
  final String professionalType; // e.g., "Dental Hygienists", "Nurses"
  final String? selectedOption; // "Yes" or "No"
  final int count;
  final ValueChanged<String?> onOptionChanged;
  final ValueChanged<int> onCountChanged;
  final String? Function(String?)? validator;
  final int minCount;
  final int maxCount;

  // Constructor
  const HealthcareProfessionalOption({
    super.key,
    required this.label,
    required this.professionalType,
    required this.selectedOption,
    required this.count,
    required this.onOptionChanged,
    required this.onCountChanged,
    this.validator,
    this.minCount = 0,
    this.maxCount = 20,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown for Yes/No selection
        KenwellDropdownField<String>(
          label: label,
          value: selectedOption,
          items: const ['Yes', 'No'],
          onChanged: onOptionChanged,
          padding: EdgeInsets.zero,
          validator: validator,
        ),
        if (selectedOption == 'Yes') ...[
          KenwellFormStyles.fieldSpacing,
          SpinBox(
            min: minCount.toDouble(),
            max: maxCount.toDouble(),
            value: count.toDouble(),
            decoration: KenwellFormStyles.decoration(
              label: 'Number of $professionalType Needed',
              hint: 'Please Enter Number',
            ),
            onChanged: (value) => onCountChanged(value.toInt()),
          ),
        ],
      ],
    );
  }
}
