import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_checkbox_field.dart';
import '../../../shared/ui/form/custom_date_picker.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_section_tile.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/hiv_test_nursing_intervention_view_model.dart';

class HIVTestNursingInterventionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const HIVTestNursingInterventionScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HIVTestNursingInterventionViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'HIV Test Nursing Intervention',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KenwellSectionTitle('HCT Nursing Interventions'),
            const SizedBox(height: 16),

            // 1. Window period
            KenwellYesNoQuestion<String>(
              question: '1. Did the risk assessment indicate window period?',
              value: vm.windowPeriod,
              onChanged: (val) {
                if (val != null) vm.setWindowPeriod(val);
              },
              yesValue: 'Yes',
              noValue: 'No',
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            // 2. Follow-up test location
            const KenwellSectionTitle('2. Follow-up test location'),
            const SizedBox(height: 8),
            KenwellCheckbox(
              title: 'State Clinic',
              value: vm.followUpClinic,
              onChanged: (val) => vm.setFollowUpClinic(val ?? false),
            ),
            KenwellCheckbox(
              title: 'Private Doctor',
              value: vm.followUpPrivateDoctor,
              onChanged: (val) => vm.setFollowUpPrivateDoctor(val ?? false),
            ),
            KenwellCheckbox(
              title: 'Other (give detail)',
              value: vm.followUpOther,
              onChanged: (val) => vm.setFollowUpOther(val ?? false),
            ),
            if (vm.followUpOther)
              KenwellTextField(
                label: 'Specify other location',
                controller: vm.followUpOtherDetailsController,
              ),

            const SizedBox(height: 16),
            // 3. Follow-up test date
            const KenwellSectionTitle('3. Follow-up test date'),
            const SizedBox(height: 8),
            KenwellDatePickerField(
              label: 'Follow-up Date',
              controller: vm.followUpDateController,
              onDateChanged: vm.handleFollowUpDate,
            ),

            const SizedBox(height: 16),
            // 4. Expected result
            KenwellYesNoQuestion<String>(
              question: '4. Expected Result',
              value: vm.expectedResult,
              onChanged: (val) {
                if (val != null) vm.setExpectedResult(val);
              },
              yesValue: 'Yes',
              noValue: 'No',
            ),

            const SizedBox(height: 16),
            // 5. Difficulty dealing with result
            KenwellYesNoQuestion<String>(
              question: '5. Difficulty dealing with result',
              value: vm.difficultyResult,
              onChanged: (val) {
                if (val != null) vm.setDifficultyResult(val);
              },
              yesValue: 'Yes',
              noValue: 'No',
            ),

            const SizedBox(height: 16),
            // 6. Psychosocial follow-up
            KenwellYesNoQuestion<String>(
              question: '6. Psychosocial follow-up',
              value: vm.psychosocialFollowUp,
              onChanged: (val) {
                if (val != null) vm.setPsychosocialFollowUp(val);
              },
              yesValue: 'Yes',
              noValue: 'No',
            ),

            const SizedBox(height: 16),
            // 7. Behavior change commitment
            KenwellYesNoQuestion<String>(
              question: '7. Behavior change commitment',
              value: vm.behaviorChange,
              onChanged: (val) {
                if (val != null) vm.setBehaviorChange(val);
              },
              yesValue: 'Yes',
              noValue: 'No',
            ),

            const SizedBox(height: 16),
            // Referrals
            const KenwellSectionTitle('Referrals'),
            const SizedBox(height: 8),
            KenwellCheckbox(
              title: 'Not Referred',
              value: vm.notReferred,
              onChanged: (val) => vm.setNotReferred(val ?? false),
            ),
            if (vm.notReferred)
              KenwellTextField(
                label: 'Reason',
                controller: vm.notReferredReasonController,
              ),
            KenwellCheckbox(
              title: 'Referred to GP',
              value: vm.referredGP,
              onChanged: (val) => vm.setReferredGP(val ?? false),
            ),
            KenwellCheckbox(
              title: 'Referred to HIV Clinic',
              value: vm.referredHIVClinic,
              onChanged: (val) => vm.setReferredHIVClinic(val ?? false),
            ),

            const SizedBox(height: 16),
            // Notes
            const KenwellSectionTitle('Session Notes'),
            const SizedBox(height: 8),
            KenwellTextField(
              label: 'Notes',
              controller: vm.sessionNotesController,
            ),

            const SizedBox(height: 24),
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () => vm.submitIntervention(onNext),
              isNextEnabled: vm.isFormValid && !vm.isSubmitting,
              isNextBusy: vm.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
