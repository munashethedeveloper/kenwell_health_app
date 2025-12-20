import 'package:flutter/material.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/form/kenwell_referral_card.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../../../shared/models/nursing_referral_option.dart';

/// A reusable form widget for nursing interventions.
/// Uses dynamic typing for viewModel to avoid inheritance/mixin dependencies.
/// The viewModel is expected to have properties like: formKey, showInitialAssessment,
/// windowPeriod, expectedResult, nursingReferralSelection, signatureController, etc.
class NurseInterventionForm extends StatelessWidget {
  final dynamic viewModel;
  final String title;
  final String sectionTitle;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const NurseInterventionForm({
    super.key,
    required this.viewModel,
    required this.title,
    required this.sectionTitle,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return KenwellFormPage(
      title: title,
      sectionTitle: sectionTitle,
      formKey: viewModel.formKey,
      children: [
        if (viewModel.showInitialAssessment) ...[
          _buildInitialAssessment(),
          const SizedBox(height: 16),
        ],
        _buildReferrals(),
        const SizedBox(height: 16),
        if (viewModel.showInitialAssessment &&
            viewModel.windowPeriod == 'Yes') ...[
          _buildFollowUpSection(),
          const SizedBox(height: 16),
        ],
        _buildNurseDetails(),
        const SizedBox(height: 24),
        KenwellSignatureActions(
          title: 'Signature',
          controller: viewModel.signatureController,
          onClear: viewModel.clearSignature,
          navigation: KenwellFormNavigation(
            onPrevious: onPrevious,
            onNext: () => viewModel.submitIntervention(context, onNext),
            isNextBusy: viewModel.isSubmitting,
            isNextEnabled: !viewModel.isSubmitting,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialAssessment() {
    return KenwellFormCard(
      title: 'Initial Assessment',
      child: Column(
        children: [
          KenwellDropdownField<String>(
            label: 'Window period risk assessment',
            value: viewModel.windowPeriod,
            items: viewModel.windowPeriodOptions,
            onChanged: viewModel.setWindowPeriod,
            validator: _requireSelection('Window period risk assessment'),
          ),
          KenwellDropdownField<String>(
            label: 'Did patient expect HIV (+) result?',
            value: viewModel.expectedResult,
            items: viewModel.expectedResultOptions,
            onChanged: viewModel.setExpectedResult,
            validator: _requireSelection('Did patient expect HIV (+) result?'),
          ),
          KenwellDropdownField<String>(
            label: 'Difficulty in dealing with result?',
            value: viewModel.difficultyDealingResult,
            items: viewModel.difficultyOptions,
            onChanged: viewModel.setDifficultyDealingResult,
            validator: _requireSelection('Difficulty in dealing with result?'),
          ),
          KenwellDropdownField<String>(
            label: 'Urgent psychosocial follow-up needed?',
            value: viewModel.urgentPsychosocial,
            items: viewModel.urgentOptions,
            onChanged: viewModel.setUrgentPsychosocial,
            validator:
                _requireSelection('Urgent psychosocial follow-up needed?'),
          ),
          KenwellDropdownField<String>(
            label: 'Committed to change behavior?',
            value: viewModel.committedToChange,
            items: viewModel.committedOptions,
            onChanged: viewModel.setCommittedToChange,
            validator: _requireSelection('Committed to change behavior?'),
          ),
        ],
      ),
    );
  }

  Widget _buildReferrals() {
    return KenwellReferralCard<NursingReferralOption>(
      title: 'Clinical Outcomes',
      selectedValue: viewModel.nursingReferralSelection,
      onChanged: viewModel.setNursingReferralSelection,
      reasonValidator: (val) =>
          (val == null || val.isEmpty) ? 'Please enter a reason' : null,
      options: [
        KenwellReferralOption(
          value: NursingReferralOption.patientNotReferred,
          label: 'Member not referred',
          requiresReason: true,
          reasonController: viewModel.notReferredReasonController,
          reasonLabel: 'Reason member not referred',
        ),
        const KenwellReferralOption(
          value: NursingReferralOption.referredToGP,
          label: 'Member referred to GP',
        ),
        const KenwellReferralOption(
          value: NursingReferralOption.referredToStateClinic,
          label: 'Member referred to State HIV clinic',
        ),
      ],
    );
  }

  Widget _buildFollowUpSection() {
    return KenwellFormCard(
      title: 'Follow-up',
      child: Column(
        children: [
          KenwellDropdownField<String>(
            label: 'Follow-up location',
            value: viewModel.followUpLocation,
            items: viewModel.followUpLocationOptions,
            onChanged: viewModel.setFollowUpLocation,
            validator: _requireSelection('Follow-up location'),
          ),
          if (viewModel.followUpLocation == 'Other')
            KenwellTextField(
              label: 'Other location detail',
              hintText: 'Specify other location',
              controller: viewModel.followUpOtherController,
              validator: (val) => (val == null || val.isEmpty)
                  ? 'Please enter Other location detail'
                  : null,
            ),
          KenwellDateField(
            label: 'Follow-up test date',
            controller: viewModel.followUpDateController,
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please select Follow-up test date'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNurseDetails() {
    return KenwellFormCard(
      title: 'Nurse Details',
      child: Column(
        children: [
          KenwellTextField(
            label: 'Nurse First Name',
            hintText: 'Enter nurse first name',
            controller: viewModel.nurseFirstNameController,
            inputFormatters:
                AppTextInputFormatters.lettersOnly(allowHyphen: true),
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Nurse First Name'
                : null,
          ),
          KenwellTextField(
            label: 'Nurse Last Name',
            hintText: 'Enter nurse last name',
            controller: viewModel.nurseLastNameController,
            inputFormatters:
                AppTextInputFormatters.lettersOnly(allowHyphen: true),
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Nurse Last Name'
                : null,
          ),
          KenwellTextField(
            label: 'Rank',
            hintText: 'Enter nurse rank',
            controller: viewModel.rankController,
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter Rank' : null,
          ),
          KenwellTextField(
            label: 'SANC No',
            hintText: 'Enter SANC number',
            controller: viewModel.sancNumberController,
            inputFormatters: AppTextInputFormatters.numbersOnly(),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter SANC No' : null,
          ),
          KenwellDateField(
            label: 'Date',
            controller: viewModel.nurseDateController,
            readOnly: true, // <-- pre-filled from WellnessEvent
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Date' : null,
          ),
        ],
      ),
    );
  }

  FormFieldValidator<String> _requireSelection(String label) {
    return (val) =>
        (val == null || val.isEmpty) ? 'Please select $label' : null;
  }
}
