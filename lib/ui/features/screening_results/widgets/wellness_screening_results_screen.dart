import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                automaticallyImplyLeading: false),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCard(
                    child: Column(
                      children: [
                        _buildTextField('Height (m or cm)', vm.heightController,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildTextField('Weight (kg)', vm.weightController,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildTextField('BMI', vm.bmiController,
                            readOnly: true),
                        const SizedBox(height: 12),
                        _buildTextField('Blood Pressure (mmHg)',
                            vm.bloodPressureController),
                        const SizedBox(height: 12),
                        _buildTextField(
                            'Cholesterol (mmol/L)', vm.cholesterolController,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildTextField(
                            'Blood Sugar (mmol/L)', vm.bloodSugarController,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildTextField(
                            'Waist Circumference (cm)', vm.waistController,
                            keyboardType: TextInputType.number),
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
                              : () => vm.submitResults(context, onNext: onNext),
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
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
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
}
