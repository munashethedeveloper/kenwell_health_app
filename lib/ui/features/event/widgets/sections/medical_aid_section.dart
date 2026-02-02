import 'package:flutter/material.dart';
import '../../view_model/event_view_model.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';

/// Medical aid information form section
class MedicalAidSection extends StatefulWidget {
  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredSelection;

  // Constructor
  const MedicalAidSection({
    super.key,
    required this.viewModel,
    required this.requiredSelection,
  });

  // Create state
  @override
  State<MedicalAidSection> createState() => _MedicalAidSectionState();
}

// State class for MedicalAidSection
class _MedicalAidSectionState extends State<MedicalAidSection> {
  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: 'Medical Aid Option',
      margin: const EdgeInsets.only(bottom: 16),
      child: KenwellDropdownField<String>(
        label: 'Do the Clients Have Medical Aid?',
        value: _nullableValue(widget.viewModel.medicalAid),
        items: const ['Yes', 'No'],
        onChanged: (val) {
          setState(() {
            widget.viewModel.medicalAid = val ?? '';
          });
        },
        padding: EdgeInsets.zero,
        validator: (val) => widget.requiredSelection('Medical Aid', val),
      ),
    );
  }

  // Helper method to convert empty string to null
  String? _nullableValue(String value) => value.isEmpty ? null : value;
}
