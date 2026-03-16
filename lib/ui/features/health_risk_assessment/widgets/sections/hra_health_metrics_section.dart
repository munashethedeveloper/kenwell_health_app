import 'package:flutter/material.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/health_metric_status_badge.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../../utils/input_formatters.dart';
import '../../view_model/health_risk_assessment_view_model.dart';

/// Section D: Health Metrics — measurements, blood pressure, cholesterol and
/// blood sugar.
///
/// All values are entered by the nurse during the screening.  The ViewModel
/// computes derived fields (BMI, status badges) reactively as the nurse types.
///
/// **Status badges** (green / amber / red) are rendered below each field that
/// has an associated status in [PersonalRiskAssessmentViewModel].  The colour
/// is determined by the ViewModel using clinically accepted ranges.
class HraHealthMetricsSection extends StatelessWidget {
  const HraHealthMetricsSection({super.key, required this.vm});

  final PersonalRiskAssessmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        const Text(
          'Section D: Health Metrics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF201C58),
          ),
        ),
        const SizedBox(height: 16),

        KenwellFormCard(
          title: 'Measurements',
          child: Column(
            children: [
              // Waist circumference
              KenwellTextField(
                label: 'Waist Circumference (cm)',
                hintText: 'e.g., 80',
                controller: vm.waistController,
                keyboardType: TextInputType.number,
                inputFormatters: AppTextInputFormatters.numbersOnly(),
                validator: (val) =>
                    _validateRequired(val, 'Waist Circumference (cm)'),
              ),
              const SizedBox(height: 12),

              // Height
              KenwellTextField(
                label: 'Height (cm)',
                hintText: 'Enter your height in centimeters',
                controller: vm.heightController,
                keyboardType: TextInputType.number,
                inputFormatters:
                    AppTextInputFormatters.numbersOnly(allowDecimal: true),
                validator: (val) => _validateRequired(val, 'Height (cm)'),
              ),
              const SizedBox(height: 12),

              // Weight
              KenwellTextField(
                label: 'Weight (kg)',
                hintText: 'Enter your weight',
                controller: vm.weightController,
                keyboardType: TextInputType.number,
                inputFormatters:
                    AppTextInputFormatters.numbersOnly(allowDecimal: true),
                validator: (val) => _validateRequired(val, 'Weight (kg)'),
              ),
              const SizedBox(height: 12),

              // BMI — read-only, calculated from height & weight by ViewModel
              KenwellTextField(
                label: 'BMI',
                hintText: 'Automatically calculated',
                controller: vm.bmiController,
                readOnly: true,
              ),
              const SizedBox(height: 12),

              // Blood Pressure heading
              const Text(
                'Blood Pressure (mmHg)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Systolic + Diastolic (side by side)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KenwellTextField(
                          label: 'Systolic (mmHg)',
                          hintText: 'e.g., 120',
                          controller: vm.systolicBpController,
                          keyboardType: TextInputType.number,
                          inputFormatters:
                              AppTextInputFormatters.numbersOnly(),
                          validator: (val) =>
                              _validateRequired(val, 'Systolic (mmHg)'),
                        ),
                        // Colour-coded status badge (e.g. Normal / High)
                        HealthMetricStatusBadge(status: vm.systolicStatus),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KenwellTextField(
                          label: 'Diastolic (mmHg)',
                          hintText: 'e.g., 80',
                          controller: vm.diastolicBpController,
                          keyboardType: TextInputType.number,
                          inputFormatters:
                              AppTextInputFormatters.numbersOnly(),
                          validator: (val) =>
                              _validateRequired(val, 'Diastolic (mmHg)'),
                        ),
                        HealthMetricStatusBadge(status: vm.diastolicStatus),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cholesterol
              KenwellTextField(
                label: 'Cholesterol (mmol/L)',
                hintText: 'e.g., 5.2',
                controller: vm.cholesterolController,
                keyboardType: TextInputType.number,
                inputFormatters:
                    AppTextInputFormatters.numbersOnly(allowDecimal: true),
                validator: (val) =>
                    _validateRequired(val, 'Cholesterol (mmol/L)'),
              ),
              HealthMetricStatusBadge(status: vm.cholesterolStatus),
              const SizedBox(height: 12),

              // Blood Sugar
              KenwellTextField(
                label: 'Blood Sugar (mmol/L)',
                hintText: 'e.g., 6.1',
                controller: vm.bloodSugarController,
                keyboardType: TextInputType.number,
                inputFormatters:
                    AppTextInputFormatters.numbersOnly(allowDecimal: true),
                validator: (val) =>
                    _validateRequired(val, 'Blood Sugar (mmol/L)'),
              ),
              HealthMetricStatusBadge(status: vm.bloodSugarStatus),
            ],
          ),
        ),
      ],
    );
  }

  /// Returns an error string when [value] is null or empty.
  String? _validateRequired(String? value, String label) {
    if (value == null || value.isEmpty) return 'Please enter $label';
    return null;
  }
}
