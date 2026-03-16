import 'package:flutter/material.dart';
import '../../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../view_model/health_risk_assessment_view_model.dart';

/// Sections 5–7: Female-only health questions.
///
/// Shown only when [PersonalRiskAssessmentViewModel.showFemaleQuestions] is
/// true (i.e. the patient's gender is "Female").
///
/// The mammogram question (Section 7) is additionally guarded by
/// [showMammogramQuestion] (age > 40).
class HraFemaleQuestionsSection extends StatelessWidget {
  const HraFemaleQuestionsSection({super.key, required this.vm});

  final PersonalRiskAssessmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (!vm.showFemaleQuestions) return const SizedBox.shrink();

    return KenwellFormCard(
      title: 'Female Only Questions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 5: Pap smear in last 24 months
          KenwellYesNoQuestion<bool>(
            question:
                '5. Have you had a pap smear in the last 24 months?',
            value: vm.papSmear,
            onChanged: vm.setPapSmear,
            yesValue: true,
            noValue: false,
            textStyle: const TextStyle(fontSize: 16),
          ),
          // Section 6: Regular breast self-examination
          KenwellYesNoQuestion<bool>(
            question: '6. Do you examine your breasts regularly?',
            value: vm.breastExam,
            onChanged: vm.setBreastExam,
            yesValue: true,
            noValue: false,
            textStyle: const TextStyle(fontSize: 16),
          ),
          // Section 7: Mammogram (age > 40 only)
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
    );
  }
}

/// Sections 8–9: Male-only health questions.
///
/// Shown only when [PersonalRiskAssessmentViewModel.showMaleQuestions] is
/// true (i.e. the patient's gender is "Male").
///
/// The prostate-check question (Section 8) is additionally guarded by
/// [showProstateCheckQuestion] (age > 40).
class HraMaleQuestionsSection extends StatelessWidget {
  const HraMaleQuestionsSection({super.key, required this.vm});

  final PersonalRiskAssessmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (!vm.showMaleQuestions) return const SizedBox.shrink();

    return KenwellFormCard(
      title: 'Male Only Questions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 8: Prostate check (age > 40 only)
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
          // Section 9: PSA / prostate cancer test
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
    );
  }
}
