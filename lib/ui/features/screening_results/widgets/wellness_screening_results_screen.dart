import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
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
              child: Column(
                children: [
                  KenwellTextField(
                    label: 'Height (m or cm)',
                    controller: vm.heightController,
                    keyboardType: TextInputType.number,
                  ),
                  KenwellTextField(
                    label: 'Weight (kg)',
                    controller: vm.weightController,
                    keyboardType: TextInputType.number,
                  ),
                  KenwellTextField(
                    label: 'BMI',
                    controller: vm.bmiController,
                    readOnly: true,
                  ),
                  KenwellTextField(
                    label: 'Blood Pressure (mmHg)',
                    controller: vm.bloodPressureController,
                  ),
                  KenwellTextField(
                    label: 'Cholesterol (mmol/L)',
                    controller: vm.cholesterolController,
                    keyboardType: TextInputType.number,
                  ),
                  KenwellTextField(
                    label: 'Blood Sugar (mmol/L)',
                    controller: vm.bloodSugarController,
                    keyboardType: TextInputType.number,
                  ),
                  KenwellTextField(
                    label: 'Waist Circumference (cm)',
                    controller: vm.waistController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // ✅ Navigation using KenwellFormNavigation
                  KenwellFormNavigation(
                    onPrevious: onPrevious,
                    onNext: () => vm.submitResults(context, onNext: onNext),
                    isNextEnabled: !vm.isSubmitting,
                    isNextBusy: vm.isSubmitting,
                    previousLabel: 'Previous',
                    nextLabel: 'Next',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
