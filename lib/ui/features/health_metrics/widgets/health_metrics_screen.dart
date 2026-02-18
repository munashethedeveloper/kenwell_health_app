import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_referral_card.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/health_metrics_view_model.dart';

// HealthMetricsScreen displays the health metrics form
class HealthMetricsScreen extends StatelessWidget {
  final HealthMetricsViewModel viewModel;
  final dynamic nurseViewModel;

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  // Constructor
  const HealthMetricsScreen({
    super.key,
    required this.viewModel,
    required this.onNext,
    required this.onPrevious,
    required this.nurseViewModel,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    //final viewModel = context.watch<NurseInterventionViewModel>();

    // Provide the HealthMetricsViewModel to the widget tree
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<HealthMetricsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            // App bar
            appBar: const KenwellAppBar(
              title: 'Health Metrics Form',
              automaticallyImplyLeading: false,
              backgroundColor: KenwellColors.primaryGreen,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              // Form for health metrics
              child: Form(
                key: vm.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    const KenwellSectionHeader(
                      title: 'Section D: Health Metrics',
                      uppercase: true,
                      icon: Icons.health_and_safety,
                    ),
                    const SizedBox(height: 16),
                    // Measurements form card
                    KenwellFormCard(
                      title: 'Measurements',
                      child: Column(
                        children: [
                          //  Text fields for various health metrics
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
                          const SizedBox(height: 12),
                          // Height input field
                          KenwellTextField(
                            label: 'Height (cm)',
                            hintText: 'Enter your height in centimeters',
                            controller: vm.heightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: AppTextInputFormatters.numbersOnly(
                                allowDecimal: true),
                            validator: (val) =>
                                _validateRequired(val, 'Height (cm)'),
                          ),
                          const SizedBox(height: 12),
                          // Weight input field
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
                          // BMI display field
                          KenwellTextField(
                            label: 'BMI',
                            hintText: 'Automatically calculated',
                            controller: vm.bmiController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          // Blood pressure, cholesterol, and blood sugar fields
                          const Text(
                            'Blood Pressure (mmHg)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: KenwellTextField(
                                  label: 'Systolic (mmHg)',
                                  hintText: 'e.g., 120',
                                  controller: vm.systolicBpController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters:
                                      AppTextInputFormatters.numbersOnly(),
                                  validator: (val) =>
                                      _validateRequired(val, 'Systolic (mmHg)'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: KenwellTextField(
                                  label: 'Diastolic (mmHg)',
                                  hintText: 'e.g., 80',
                                  controller: vm.diastolicBpController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters:
                                      AppTextInputFormatters.numbersOnly(),
                                  validator: (val) => _validateRequired(
                                      val, 'Diastolic (mmHg)'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Cholesterol input field
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
                          // Blood sugar input field
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildReferrals(),
                    const SizedBox(
                      height: 24,
                    ),
                    // Navigation buttons
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

  // Build nursing referrals widget
  Widget _buildReferrals() {
    return KenwellReferralCard<NursingReferralOption>(
      title: 'Nursing Referrals',
      selectedValue: nurseViewModel.nursingReferralSelection,
      onChanged: nurseViewModel.setNursingReferralSelection,
      reasonValidator: (val) =>
          (val == null || val.isEmpty) ? 'Please enter a reason' : null,
      options: [
        // Referral options
        KenwellReferralOption(
          value: NursingReferralOption.patientNotReferred,
          label: 'Patient not referred',
          requiresReason: true,
          reasonController: nurseViewModel.notReferredReasonController,
          reasonLabel: 'Reason patient not referred',
        ),
        const KenwellReferralOption(
          value: NursingReferralOption.referredToGP,
          label: 'Patient referred to GP',
        ),
        const KenwellReferralOption(
          value: NursingReferralOption.referredToStateClinic,
          label: 'Patient referred to State HIV clinic',
        ),
      ],
    );
  }

  // Validate required fields
  String? _validateRequired(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }
}
