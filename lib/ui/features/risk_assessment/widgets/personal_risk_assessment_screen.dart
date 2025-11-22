import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/personal_risk_assessment_view_model.dart';

class PersonalRiskAssessmentScreen extends StatelessWidget {
  final PersonalRiskAssessmentViewModel viewModel;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isFemale;

  const PersonalRiskAssessmentScreen({
    super.key,
    required this.viewModel,
    required this.isFemale,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PersonalRiskAssessmentViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: const KenwellAppBar(
              title: 'Personal Risk Assessment',
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
                      title: 'Section C: Health Risk Assessment',
                      uppercase: true,
                    ),

                    // ===== Section 1: Chronic Conditions =====
                    KenwellFormCard(
                      title:
                          '1. Do you suffer or take medication for any of the following conditions?',
                      child: Column(
                        children: [
                          ...vm.chronicConditions.keys.map((condition) {
                            return CheckboxListTile(
                              title: Text(condition),
                              value: vm.chronicConditions[condition],
                              onChanged: (val) =>
                                  vm.toggleCondition(condition, val),
                            );
                          }).toList(),
                          if (vm.chronicConditions['Other'] == true)
                            KenwellTextField(
                              label:
                                  'If Other, please specify condition and treatment',
                              controller: vm.otherConditionController,
                              hintText: 'Specify other condition...',
                              decoration: KenwellFormStyles.decoration(
                                label:
                                    'If Other, please specify condition and treatment',
                                hint: 'Specify other condition...',
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Please specify other condition'
                                  : null,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Section 2: Exercise =====
                    KenwellFormCard(
                      title:
                          '2. Over the past month, how many days per week have you exercised for 30 minutes or longer?',
                      child: _buildStringRadioGroup(
                        selected: vm.exerciseFrequency.isEmpty
                            ? null
                            : vm.exerciseFrequency,
                        options: const [
                          'Never',
                          'Once/week',
                          'Twice/week',
                          'Three times/week or more',
                        ],
                        onChanged: vm.setExerciseFrequency,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Section 3: Smoking =====
                    KenwellFormCard(
                      title: '3. How much do you smoke per day?',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KenwellTextField(
                            label: 'Number per day',
                            controller: vm.dailySmokeController,
                            hintText: 'Enter number of cigarettes/day',
                            keyboardType: TextInputType.number,
                            inputFormatters:
                                AppTextInputFormatters.numbersOnly(),
                            decoration: KenwellFormStyles.decoration(
                              label: 'Number per day',
                              hint: 'Enter number of cigarettes/day',
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Please enter daily smoking amount'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          const Text('3.1 What do you smoke?',
                              style: TextStyle(fontSize: 16)),
                          _buildStringRadioGroup(
                            selected:
                                vm.smokeType.isEmpty ? null : vm.smokeType,
                            options: const ['Cigarette', 'Pipe', 'Dagga'],
                            onChanged: vm.setSmokeType,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Section 4: Alcohol =====
                    KenwellFormCard(
                      title: '4. How often do you use alcoholic beverages?',
                      child: _buildStringRadioGroup(
                        selected: vm.alcoholFrequency.isEmpty
                            ? null
                            : vm.alcoholFrequency,
                        options: const [
                          'Never',
                          'On occasion',
                          'Two-three drinks per day',
                          'More than 3 drinks per day',
                          'I often drink too much',
                        ],
                        onChanged: vm.setAlcoholFrequency,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Section 5-7: Female Only =====
                    if (isFemale)
                      KenwellFormCard(
                        title: 'Female Only Questions',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KenwellYesNoQuestion<bool>(
                              question:
                                  '5. Have you had a pap smear in the last 24 months?',
                              value: vm.papSmear,
                              onChanged: vm.setPapSmear,
                              yesValue: true,
                              noValue: false,
                            ),
                            KenwellYesNoQuestion<bool>(
                              question:
                                  '6. Do you examine your breasts regularly?',
                              value: vm.breastExam,
                              onChanged: vm.setBreastExam,
                              yesValue: true,
                              noValue: false,
                            ),
                            KenwellYesNoQuestion<bool>(
                              question:
                                  '7. If older than 40, have you had a mammogram done?',
                              value: vm.mammogram,
                              onChanged: vm.setMammogram,
                              yesValue: true,
                              noValue: false,
                            ),
                          ],
                        ),
                      ),

                    // ===== Section 8-9: Male Only =====
                    if (!isFemale)
                      KenwellFormCard(
                        title: 'Male Only Questions',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KenwellYesNoQuestion<bool>(
                              question:
                                  '8. If > than 40, have you had your prostate checked?',
                              value: vm.prostateCheck,
                              onChanged: vm.setProstateCheck,
                              yesValue: true,
                              noValue: false,
                            ),
                            KenwellYesNoQuestion<bool>(
                              question:
                                  '9. Have you been tested for prostate cancer?',
                              value: vm.prostateTested,
                              onChanged: vm.setProstateTested,
                              yesValue: true,
                              noValue: false,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ===== Navigation Buttons =====
                    KenwellFormNavigation(
                      onPrevious: onPrevious,
                      onNext: () {
                        if (vm.formKey.currentState!.validate() &&
                            vm.isFormValid) {
                          if (onNext != null) onNext!();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please complete all required fields')),
                          );
                        }
                      },
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
            ),
          )
          .toList(),
    );
  }
}
