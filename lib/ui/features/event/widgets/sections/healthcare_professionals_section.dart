import 'package:flutter/material.dart';
import '../../view_model/event_view_model.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import 'healthcare_professional_option_widget.dart';

class HealthcareProfessionalsSection extends StatefulWidget {
  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredSelection;

  const HealthcareProfessionalsSection({
    super.key,
    required this.viewModel,
    required this.requiredSelection,
  });

  @override
  State<HealthcareProfessionalsSection> createState() =>
      _HealthcareProfessionalsSectionState();
}

class _HealthcareProfessionalsSectionState
    extends State<HealthcareProfessionalsSection> {
  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: 'Healthcare Professionals Needed',
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Dental Hygienists
          HealthcareProfessionalOption(
            label: 'Do You Need Dental Hygienists?',
            professionalType: 'Dental Hygienists',
            selectedOption:
                _nullableValue(widget.viewModel.dentalHygenistsOption),
            count: widget.viewModel.dentalHygenistsCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.dentalHygenistsOption = val ?? 'No';
                if (val == 'No') widget.viewModel.dentalHygenistsCount = 0;
              });
            },
            onCountChanged: (count) {
              setState(() => widget.viewModel.dentalHygenistsCount = count);
            },
            validator: (val) =>
                widget.requiredSelection('Dental Hygienists', val),
          ),

          KenwellFormStyles.fieldSpacing,

          // Dieticians
          HealthcareProfessionalOption(
            label: 'Do You Need Dieticians?',
            professionalType: 'Dieticians',
            selectedOption: _nullableValue(widget.viewModel.dieticiansOption),
            count: widget.viewModel.dieticiansCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.dieticiansOption = val ?? 'No';
                if (val == 'No') widget.viewModel.dieticiansCount = 0;
              });
            },
            onCountChanged: (count) {
              setState(() => widget.viewModel.dieticiansCount = count);
            },
            validator: (val) => widget.requiredSelection('Dieticians', val),
          ),

          KenwellFormStyles.fieldSpacing,

          // Nurses
          HealthcareProfessionalOption(
            label: 'Do You Need Nurses?',
            professionalType: 'Nurses',
            selectedOption: _nullableValue(widget.viewModel.nursesOption),
            count: widget.viewModel.nursesCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.nursesOption = val ?? 'No';
                if (val == 'No') widget.viewModel.nursesCount = 0;
              });
            },
            onCountChanged: (count) {
              setState(() => widget.viewModel.nursesCount = count);
            },
            validator: (val) => widget.requiredSelection('Nurses', val),
          ),

          KenwellFormStyles.fieldSpacing,

          // Optometrists
          HealthcareProfessionalOption(
            label: 'Do You Need Optometrists?',
            professionalType: 'Optometrists',
            selectedOption: _nullableValue(widget.viewModel.optometristsOption),
            count: widget.viewModel.optometristsCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.optometristsOption = val ?? 'No';
                if (val == 'No') widget.viewModel.optometristsCount = 0;
              });
            },
            onCountChanged: (count) {
              setState(() => widget.viewModel.optometristsCount = count);
            },
            validator: (val) => widget.requiredSelection('Optometrists', val),
          ),

          KenwellFormStyles.fieldSpacing,

          // Occupational Therapists
          HealthcareProfessionalOption(
            label: 'Do You Need Occupational Therapists?',
            professionalType: 'Occupational Therapists',
            selectedOption:
                _nullableValue(widget.viewModel.occupationalTherapistsOption),
            count: widget.viewModel.occupationalTherapistsCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.occupationalTherapistsOption = val ?? 'No';
                if (val == 'No') {
                  widget.viewModel.occupationalTherapistsCount = 0;
                }
              });
            },
            onCountChanged: (count) {
              setState(
                  () => widget.viewModel.occupationalTherapistsCount = count);
            },
            validator: (val) =>
                widget.requiredSelection('Occupational Therapists', val),
          ),

          KenwellFormStyles.fieldSpacing,

          // Psychologists
          HealthcareProfessionalOption(
            label: 'Do You Need Psychologists?',
            professionalType: 'Psychologists',
            selectedOption:
                _nullableValue(widget.viewModel.psychologistsOption),
            count: widget.viewModel.psychologistsCount,
            onOptionChanged: (val) {
              setState(() {
                widget.viewModel.psychologistsOption = val ?? 'No';
                if (val == 'No') widget.viewModel.psychologistsCount = 0;
              });
            },
            onCountChanged: (count) {
              setState(() => widget.viewModel.psychologistsCount = count);
            },
            validator: (val) => widget.requiredSelection('Psychologists', val),
          ),
        ],
      ),
    );
  }

  String? _nullableValue(String value) => value.isEmpty ? null : value;
}
