import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/wellness_screening_results_view_model.dart';

class WellnessScreeningResultsScreen extends StatelessWidget {
  final WellnessScreeningResultsViewModel viewModel;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const WellnessScreeningResultsScreen({
    super.key,
    required this.viewModel,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<WellnessScreeningResultsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: const KenwellAppBar(
              title: 'Wellness Screening Results',
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: vm.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KenwellSectionHeader(
                      title: 'Section D: Wellness Screening Results',
                      uppercase: true,
                    ),
                    KenwellFormCard(
                      title: 'Measurements',
                      child: Column(
                        children: [
                          KenwellTextField(
                            label: 'Height (m or cm)',
                            hintText: 'Enter your height',
                            controller: vm.heightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                            validator: (val) =>
                                _validateRequired(val, 'Height (m or cm)'),
                          ),
                          const SizedBox(height: 12),
                          KenwellTextField(
                            label: 'Weight (kg)',
                            hintText: 'Enter your weight',
                            controller: vm.weightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                            validator: (val) =>
                                _validateRequired(val, 'Weight (kg)'),
                          ),
                          const SizedBox(height: 12),
                          KenwellTextField(
                            label: 'BMI',
                            hintText: 'Automatically calculated',
                            controller: vm.bmiController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          KenwellTextField(
                            label: 'Blood Pressure (mmHg)',
                            hintText: 'e.g., 120/80',
                            controller: vm.bloodPressureController,
                            validator: (val) =>
                                _validateRequired(val, 'Blood Pressure (mmHg)'),
                          ),
                          const SizedBox(height: 12),
                          KenwellTextField(
                            label: 'Cholesterol (mmol/L)',
                            hintText: 'e.g., 5.2',
                            controller: vm.cholesterolController,
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                            validator: (val) =>
                                _validateRequired(val, 'Cholesterol (mmol/L)'),
                          ),
                          const SizedBox(height: 12),
                          KenwellTextField(
                            label: 'Blood Sugar (mmol/L)',
                            hintText: 'e.g., 6.1',
                            controller: vm.bloodSugarController,
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                            validator: (val) =>
                                _validateRequired(val, 'Blood Sugar (mmol/L)'),
                          ),
                          const SizedBox(height: 12),
                          KenwellTextField(
                            label: 'Waist Circumference (cm)',
                            hintText: 'e.g., 80',
                            controller: vm.waistController,
                            keyboardType: TextInputType.number,
                            inputFormatters:
                                AppTextInputFormatters.numbersOnly(),
                            validator: (val) => _validateRequired(
                                val, 'Waist Circumference (cm)'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    KenwellFormNavigation(
                      onPrevious: vm.isSubmitting ? null : onPrevious,
                      onNext: () => vm.submitResults(context, onNext: onNext),
                      isNextBusy: vm.isSubmitting,
                      isNextEnabled: !vm.isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }
}
