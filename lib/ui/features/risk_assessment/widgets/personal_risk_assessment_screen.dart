import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/nurse_interventions/view_model/nurse_intervention_form_mixin.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/custom_dropdown_field.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_referral_card.dart';
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
  final NurseInterventionFormMixin nurseViewModel;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isFemale;
  final int age;

  const PersonalRiskAssessmentScreen({
    super.key,
    required this.viewModel,
    required this.nurseViewModel,
    required this.isFemale,
    required this.age,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the view model with gender and age data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.setPersonalDetails(
        gender: isFemale ? 'Female' : 'Male',
        age: age,
      );
    });

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PersonalRiskAssessmentViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: const KenwellAppBar(
              title: 'Health Risk Assessment Form',
              backgroundColor: KenwellColors.primaryGreen,
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
                      title: '2. Do you have any exercising habits?',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KenwellDropdownField(
                            label: 'Do you Exercise?',
                            value: vm.smokingStatus,
                            items: vm.smokingStatusOptions,
                            onChanged: vm.setSmokingStatus,
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Select Exercise Status'
                                : null,
                          ),
                          if (vm.showSmokingFields) ...[
                            const Text(
                                '2.1 Over the past month, how many days per week have you exercised for 30 minutes or longer?',
                                style: TextStyle(fontSize: 16)),
                            _buildStringRadioGroup(
                              selected: vm.exerciseFrequency.isEmpty
                                  ? null
                                  : vm.exerciseFrequency,
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

                    // ===== Section 3: Smoking =====
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
                              selected:
                                  vm.smokeType.isEmpty ? null : vm.smokeType,
                              options: const [
                                'Cigarette',
                                'Pipe',
                                'Dagga',
                                'Vape'
                              ],
                              onChanged: vm.setSmokeType,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text('3.2 How much do you smoke per day?'),
                            const SizedBox(
                              height: 8,
                            ),
                            KenwellTextField(
                              label: '3. How much do you smoke per day?',
                              controller: vm.dailySmokeController,
                              hintText:
                                  'Please Enter Amount of Times You Smoke',
                              keyboardType: TextInputType.number,
                              inputFormatters:
                                  AppTextInputFormatters.numbersOnly(),
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

                    // ===== Section 4: Alcohol =====
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
                                style: TextStyle(fontSize: 16)),
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

                    const SizedBox(height: 24),

                    // ===== Section 5-7: Female Only =====
                    if (vm.showFemaleQuestions)
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
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            KenwellYesNoQuestion<bool>(
                              question:
                                  '6. Do you examine your breasts regularly?',
                              value: vm.breastExam,
                              onChanged: vm.setBreastExam,
                              yesValue: true,
                              noValue: false,
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            if (vm.showMammogramQuestion)
                              KenwellYesNoQuestion<bool>(
                                question:
                                    '7. If older than 40, have you had a mammogram done?',
                                value: vm.mammogram,
                                onChanged: vm.setMammogram,
                                yesValue: true,
                                noValue: false,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),

                    // ===== Section 8-9: Male Only =====
                    if (vm.showMaleQuestions)
                      KenwellFormCard(
                        title: 'Male Only Questions',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (vm.showProstateCheckQuestion)
                              KenwellYesNoQuestion<bool>(
                                question:
                                    '8. If > than 40, have you had your prostate checked?',
                                value: vm.prostateCheck,
                                onChanged: vm.setProstateCheck,
                                yesValue: true,
                                noValue: false,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            KenwellYesNoQuestion<bool>(
                              question:
                                  '9. Have you been tested for prostate cancer?',
                              value: vm.prostateTested,
                              onChanged: vm.setProstateTested,
                              yesValue: true,
                              noValue: false,
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ===== Section D: Health Metrics =====
                    const KenwellSectionHeader(
                      title: 'Section D: Health Metrics',
                      uppercase: true,
                    ),

                    KenwellFormCard(
                      title: 'Measurements',
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildReferrals(),
                    const SizedBox(height: 24),

                    // ===== Navigation Buttons =====
                    KenwellFormNavigation(
                      onPrevious: vm.isSubmitting ? null : onPrevious,
                      onNext: () =>
                          vm.submitResults(context, onNext: onNext ?? () {}),
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

  Widget _buildReferrals() {
    return KenwellReferralCard<NursingReferralOption>(
      title: 'Nursing Referrals',
      selectedValue: nurseViewModel.nursingReferralSelection,
      onChanged: nurseViewModel.setNursingReferralSelection,
      reasonValidator: (val) =>
          (val == null || val.isEmpty) ? 'Please enter a reason' : null,
      options: [
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

  String? _validateRequired(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }
}
