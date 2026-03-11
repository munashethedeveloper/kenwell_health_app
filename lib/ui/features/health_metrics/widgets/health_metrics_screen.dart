import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/health_metric_status_badge.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/nursing_referral_status_card.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
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
          // Auto-refer when any metric is in the danger zone
          if (vm.hasRedMetrics) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (nurseViewModel.nursingReferralSelection == null ||
                  nurseViewModel.nursingReferralSelection ==
                      NursingReferralOption.patientNotReferred) {
                nurseViewModel.setNursingReferralSelection(
                    NursingReferralOption.referredToStateClinic);
              }
            });
          }
          return Scaffold(
            // App bar
            appBar: const KenwellAppBar(
              title: 'KenWell365',
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                // ── Gradient section header ─────────────────────────
                const KenwellGradientHeader(
                  label: 'HEALTH',
                  title: 'Health\nMetrics',
                  subtitle: 'Section D: Record health measurements',
                ),
                // ── Scrollable form ─────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    // Form for health metrics
                    child: Form(
                      key: vm.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
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
                                  inputFormatters:
                                      AppTextInputFormatters.numbersOnly(
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
                                  inputFormatters:
                                      AppTextInputFormatters.numbersOnly(
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          KenwellTextField(
                                            label: 'Systolic (mmHg)',
                                            hintText: 'e.g., 120',
                                            controller: vm.systolicBpController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters:
                                                AppTextInputFormatters
                                                    .numbersOnly(),
                                            validator: (val) =>
                                                _validateRequired(
                                                    val, 'Systolic (mmHg)'),
                                          ),
                                          HealthMetricStatusBadge(
                                              status: vm.systolicStatus),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          KenwellTextField(
                                            label: 'Diastolic (mmHg)',
                                            hintText: 'e.g., 80',
                                            controller:
                                                vm.diastolicBpController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters:
                                                AppTextInputFormatters
                                                    .numbersOnly(),
                                            validator: (val) =>
                                                _validateRequired(
                                                    val, 'Diastolic (mmHg)'),
                                          ),
                                          HealthMetricStatusBadge(
                                              status: vm.diastolicStatus),
                                        ],
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
                                  inputFormatters:
                                      AppTextInputFormatters.numbersOnly(
                                          allowDecimal: true),
                                  validator: (val) => _validateRequired(
                                      val, 'Cholesterol (mmol/L)'),
                                ),
                                HealthMetricStatusBadge(
                                    status: vm.cholesterolStatus),
                                const SizedBox(height: 12),
                                // Blood sugar input field
                                KenwellTextField(
                                  label: 'Blood Sugar (mmol/L)',
                                  hintText: 'e.g., 6.1',
                                  controller: vm.bloodSugarController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters:
                                      AppTextInputFormatters.numbersOnly(
                                          allowDecimal: true),
                                  validator: (val) => _validateRequired(
                                      val, 'Blood Sugar (mmol/L)'),
                                ),
                                HealthMetricStatusBadge(
                                    status: vm.bloodSugarStatus),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Auto-referral alert shown when any metric is in the red zone
                          if (vm.hasRedMetrics) ...[
                            const HealthMetricRedAlert(),
                            const SizedBox(height: 12),
                          ],
                          _buildReferrals(),
                          const SizedBox(
                            height: 24,
                          ),
                          // Navigation buttons
                          KenwellFormNavigation(
                            onPrevious: vm.isSubmitting ? null : onPrevious,
                            onNext: () =>
                                vm.submitResults(context, onNext: onNext),
                            isNextBusy: vm.isSubmitting,
                            isNextEnabled: !vm.isSubmitting,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build nursing referrals widget
  Widget _buildReferrals() {
    return NursingReferralStatusCard(
      title: 'Nursing Referrals',
      selectedValue: nurseViewModel.nursingReferralSelection,
      onChanged: nurseViewModel.setNursingReferralSelection,
      notReferredReasonController: nurseViewModel.notReferredReasonController,
      isCaution: viewModel.isCaution,
      reasonValidator: (val) =>
          (val == null || val.isEmpty) ? 'Please enter a reason' : null,
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
