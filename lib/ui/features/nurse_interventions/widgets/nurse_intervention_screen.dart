import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_checkbox_field.dart';
import '../../../shared/ui/form/custom_date_picker.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_signature_pad.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/nurse_intervention_view_model.dart';

class NurseInterventionScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const NurseInterventionScreen({
    super.key,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NurseInterventionViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Health Risk Assessment Nurse Intervention',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Dropdowns (Using KenwellDropdownField) ---
            KenwellDropdownField<WindowPeriod>(
              label: 'Window period risk assessment',
              value: vm.windowPeriod,
              items: WindowPeriod.values,
              optionLabelBuilder: (e) => e.toString().split('.').last,
              onChanged: (val) => vm.toggleField('windowPeriod', val),
            ),
            KenwellDropdownField<FollowUpLocation>(
              label: 'Follow-up test location',
              value: vm.followUpLocation,
              items: FollowUpLocation.values,
              optionLabelBuilder: (e) => e.toString().split('.').last,
              onChanged: (val) => vm.toggleField('followUpLocation', val),
            ),
            if (vm.isFollowUpOtherSelected)
              KenwellTextField(
                label: 'Other location detail',
                controller: vm.followUpOtherController,
              ),
            KenwellDatePickerField(
              controller: vm.followUpDateController,
              label: 'Follow-up test date',
              displayFormat: DateFormat('dd/MM/yyyy'),
            ),

            const SizedBox(height: 24),

            KenwellDropdownField<ExpectedResult>(
              label: 'Expected HIV result',
              value: vm.expectedResult,
              items: ExpectedResult.values,
              optionLabelBuilder: (e) => e.toString().split('.').last,
              onChanged: (val) => vm.toggleField('expectedResult', val),
            ),
            KenwellDropdownField<DifficultyDealingResult>(
              label: 'Difficulty dealing with result',
              value: vm.difficultyDealingResult,
              items: DifficultyDealingResult.values,
              optionLabelBuilder: (e) => e.toString().split('.').last,
              onChanged: (val) =>
                  vm.toggleField('difficultyDealingResult', val),
            ),
            KenwellDropdownField<UrgentPsychosocial>(
              label: 'Urgent psychosocial follow-up',
              value: vm.urgentPsychosocial,
              items: UrgentPsychosocial.values,
              optionLabelBuilder: (e) => e.toString().split('.').last,
              onChanged: (val) => vm.toggleField('urgentPsychosocial', val),
            ),
            KenwellDropdownField<CommittedToChange>(
              label: 'Committed to behavior change',
              value: vm.committedToChange,
              items: CommittedToChange.values,
              optionLabelBuilder: (e) => e.toString().split('.').last,
              onChanged: (val) => vm.toggleField('committedToChange', val),
            ),

            const SizedBox(height: 24),

            // --- Referral Checkboxes (using KenwellCheckbox) ---
            const Text(
              'Referral Nursing Interventions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            KenwellCheckbox(
              title: 'Patient Not Referred',
              value: vm.patientNotReferred,
              onChanged: (val) => vm.toggleField('patientNotReferred', val),
            ),
            if (vm.patientNotReferred)
              KenwellTextField(
                label: 'Reason',
                controller: vm.notReferredReasonController,
              ),
            KenwellCheckbox(
              title: 'Referred to GP',
              value: vm.referredToGP,
              onChanged: (val) => vm.toggleField('referredToGP', val),
            ),
            KenwellCheckbox(
              title: 'Referred to State Clinic',
              value: vm.referredToStateClinic,
              onChanged: (val) => vm.toggleField('referredToStateClinic', val),
            ),

            const SizedBox(height: 24),

            // --- Nurse Details ---
            const Text(
              'Nurse Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            KenwellTextField(
              label: 'HIV Testing Nurse',
              controller: vm.hivTestingNurseController,
            ),
            KenwellTextField(
              label: 'Rank',
              controller: vm.rankController,
            ),
            KenwellTextField(
              label: 'SANC Number',
              controller: vm.sancNumberController,
            ),
            KenwellDatePickerField(
              controller: vm.nurseDateController,
              label: 'Date',
              displayFormat: DateFormat('dd/MM/yyyy'),
            ),

            const SizedBox(height: 12),

            // --- Signature ---
            const Text(
              'Signature',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            KenwellSignaturePad(
              controller: vm.signatureController,
              height: 150,
            ),

            const SizedBox(height: 16),

            // --- Navigation ---
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () => vm.submitIntervention(context, onNext),
              isNextEnabled: vm.isFormValid && !vm.isSubmitting,
              isNextBusy: vm.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
