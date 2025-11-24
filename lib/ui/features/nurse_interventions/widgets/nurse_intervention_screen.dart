import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/form/kenwell_referral_card.dart';
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
    final viewModel = context.watch<NurseInterventionViewModel>();

    return KenwellFormPage(
      title: 'Health Risk Assessment Nurse Intervention',
      sectionTitle: 'Section E: Health Risk Assessment Nurse Intervention',
      formKey: viewModel.formKey,
      children: [
        KenwellFormCard(
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
                validator:
                    _requireSelection('Did patient expect HIV (+) result?'),
              ),
              KenwellDropdownField<String>(
                label: 'Difficulty in dealing with result?',
                value: viewModel.difficultyDealingResult,
                items: viewModel.difficultyOptions,
                onChanged: viewModel.setDifficultyDealingResult,
                validator:
                    _requireSelection('Difficulty in dealing with result?'),
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
        ),
        const SizedBox(height: 16),
        KenwellReferralCard<NursingReferralOption>(
          title: 'Nursing Referrals',
          selectedValue: viewModel.nursingReferralSelection,
          onChanged: viewModel.setNursingReferralSelection,
          reasonValidator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter a reason' : null,
          options: [
            KenwellReferralOption(
              value: NursingReferralOption.patientNotReferred,
              label: 'Patient not referred',
              requiresReason: true,
              reasonController: viewModel.notReferredReasonController,
              reasonLabel: 'Reason patient not referred',
            ),
            KenwellReferralOption(
              value: NursingReferralOption.referredToGP,
              label: 'Patient referred to GP',
            ),
            KenwellReferralOption(
              value: NursingReferralOption.referredToStateClinic,
              label: 'Patient referred to State HIV clinic',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (viewModel.windowPeriod == 'Yes')
          KenwellFormCard(
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
          ),
        if (viewModel.windowPeriod == 'Yes') const SizedBox(height: 16),
        KenwellFormCard(
          title: 'Nurse Details',
          child: Column(
            children: [
              KenwellTextField(
                label: 'HIV Testing Nurse',
                hintText: 'Enter nurse name',
                controller: viewModel.hivTestingNurseController,
                inputFormatters:
                    AppTextInputFormatters.lettersOnly(allowHyphen: true),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter HIV Testing Nurse'
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
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter SANC No'
                    : null,
              ),
              KenwellDateField(
                label: 'Date',
                controller: viewModel.nurseDateController,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please select Date' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellSignatureActions(
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

  FormFieldValidator<String> _requireSelection(String label) {
    return (val) =>
        (val == null || val.isEmpty) ? 'Please select $label' : null;
  }
}
