import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/form_input_borders.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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
                    Text(
                      'SECTION D: WELLNESS SCREENING RESULTS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: const Color(0xFF201C58),
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildCard(
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

                    // ✅ Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: vm.isSubmitting ? null : onPrevious,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: vm.isSubmitting
                                ? null
                                : () =>
                                    vm.submitResults(context, onNext: onNext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF90C048),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: vm.isSubmitting
                                ? const CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  )
                                : const Text(
                                    'Next',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
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
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _profileFieldDecoration(label, hint),
      validator: (val) {
        if (!readOnly && (val == null || val.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.white,
      shadowColor: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  InputDecoration _profileFieldDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: authOutlineInputBorder,
      enabledBorder: authOutlineInputBorder,
      focusedBorder: authOutlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF7643)),
      ),
    );
  }
}
