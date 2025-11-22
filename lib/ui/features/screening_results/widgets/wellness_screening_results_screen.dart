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
                          _buildTextField(
                            'Height (m or cm)',
                            vm.heightController,
                            hint: 'Enter your height',
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Weight (kg)',
                            vm.weightController,
                            hint: 'Enter your weight',
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'BMI',
                            vm.bmiController,
                            hint: 'Automatically calculated',
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Blood Pressure (mmHg)',
                            vm.bloodPressureController,
                            hint: 'e.g., 120/80',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Cholesterol (mmol/L)',
                            vm.cholesterolController,
                            hint: 'e.g., 5.2',
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Blood Sugar (mmol/L)',
                            vm.bloodSugarController,
                            hint: 'e.g., 6.1',
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Waist Circumference (cm)',
                            vm.waistController,
                            hint: 'e.g., 80',
                            keyboardType: TextInputType.number,
                            inputFormatters:
                                AppTextInputFormatters.numbersOnly(),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return KenwellTextField(
      label: label,
      hintText: hint,
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: KenwellFormStyles.decoration(label: label, hint: hint),
      validator: (val) {
        if (!readOnly && (val == null || val.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
