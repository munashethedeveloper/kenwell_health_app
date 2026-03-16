import 'package:flutter/material.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../../../utils/input_formatters.dart';
import '../../view_model/health_risk_assessment_view_model.dart';

/// Section 1: Chronic conditions checklist.
///
/// Renders a checkbox for each known chronic condition.  When "Other" is
/// checked a free-text field appears so the patient can specify the condition
/// and any treatment they are receiving.
class HraChronicConditionsSection extends StatelessWidget {
  const HraChronicConditionsSection({super.key, required this.vm});

  final PersonalRiskAssessmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title:
          '1. Do you suffer or take medication for any of the following conditions?',
      child: Column(
        children: [
          // Dynamic checkbox per condition from ViewModel
          ...vm.chronicConditions.keys.map((condition) {
            return CheckboxListTile(
              title: Text(condition),
              value: vm.chronicConditions[condition],
              onChanged: (val) => vm.toggleCondition(condition, val),
            );
          }),
          // "Other" free-text field (shown only when "Other" is checked)
          if (vm.chronicConditions['Other'] == true)
            KenwellTextField(
              label: 'If Other, please specify condition and treatment',
              controller: vm.otherConditionController,
              hintText: 'Specify other condition...',
              decoration: KenwellFormStyles.decoration(
                label: 'If Other, please specify condition and treatment',
                hint: 'Specify other condition...',
              ),
              validator: (val) => val == null || val.isEmpty
                  ? 'Please specify other condition'
                  : null,
            ),
        ],
      ),
    );
  }
}

/// Sections 2–4: Lifestyle questions (Exercise, Smoking, Alcohol).
///
/// Each sub-section is conditionally expanded based on the patient's yes/no
/// dropdown answer, e.g. smoking details only appear when the patient
/// indicates they do smoke.
class HraLifestyleSection extends StatelessWidget {
  const HraLifestyleSection({super.key, required this.vm});

  final PersonalRiskAssessmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Section 2: Exercise ──────────────────────────────────────────
        KenwellFormCard(
          title: '2. Do you have any exercising habits?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellDropdownField(
                label: 'Do you Exercise?',
                value: vm.exerciseStatus,
                items: vm.exerciseStatusOptions,
                onChanged: vm.setExerciseStatus,
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Select Exercise Status'
                    : null,
              ),
              if (vm.showExerciseFields) ...[
                const Text(
                  '2.1 Over the past month, how many days per week have you exercised for 30 minutes or longer?',
                  style: TextStyle(fontSize: 16),
                ),
                _buildStringRadioGroup(
                  selected:
                      vm.exerciseFrequency.isEmpty ? null : vm.exerciseFrequency,
                  options: const [
                    'Once/week',
                    'Twice/week',
                    'Three times/week or more',
                  ],
                  onChanged: vm.setExerciseFrequency,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Section 3: Smoking ───────────────────────────────────────────
        KenwellFormCard(
          title: '3. Do You Have Any Smoking Habits?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellDropdownField(
                label: 'Do you smoke?',
                value: vm.smokingStatus,
                items: vm.smokingStatusOptions,
                onChanged: vm.setSmokingStatus,
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Select Smoking Status'
                    : null,
              ),
              if (vm.showSmokingFields) ...[
                const Text('3.1 What do you smoke?',
                    style: TextStyle(fontSize: 16)),
                _buildStringRadioGroup(
                  selected: vm.smokeType.isEmpty ? null : vm.smokeType,
                  options: const ['Cigarette', 'Pipe', 'Dagga', 'Vape'],
                  onChanged: vm.setSmokeType,
                ),
                const SizedBox(height: 16),
                const Text('3.2 How much do you smoke per day?'),
                const SizedBox(height: 8),
                KenwellTextField(
                  label: '3. How much do you smoke per day?',
                  controller: vm.dailySmokeController,
                  hintText: 'Please Enter Amount of Times You Smoke',
                  keyboardType: TextInputType.number,
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  decoration: KenwellFormStyles.decoration(
                    label: 'Number per day',
                    hint: 'Please Enter Amount of Times You Smoke',
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter daily smoking amount'
                      : null,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Section 4: Alcohol ───────────────────────────────────────────
        KenwellFormCard(
          title: '4. Do you have any drinking habits?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellDropdownField(
                label: 'Do you drink?',
                value: vm.drinkingStatus,
                items: vm.drinkingStatusOptions,
                onChanged: vm.setDrinkingStatus,
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Select Drinking Status'
                    : null,
              ),
              if (vm.showDrinkingFields) ...[
                const SizedBox(height: 8),
                const Text(
                  '4.1 How often do you use alcoholic beverages?',
                  style: TextStyle(fontSize: 16),
                ),
                _buildStringRadioGroup(
                  selected: vm.alcoholFrequency.isEmpty
                      ? null
                      : vm.alcoholFrequency,
                  options: const [
                    'On occasion',
                    'Two-three drinks per day',
                    'More than 3 drinks per day',
                    'I often drink too much',
                  ],
                  onChanged: vm.setAlcoholFrequency,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Shared helper: radio button group for a list of string [options].
  Widget _buildStringRadioGroup({
    required String? selected,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: options
          .map(
            (option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selected,
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
              toggleable: false,
            ),
          )
          .toList(),
    );
  }
}
