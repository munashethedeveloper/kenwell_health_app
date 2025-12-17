import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_checkbox_group.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_yes_no_list.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_referral_card.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../../nurse_interventions/view_model/nurse_intervention_form_mixin.dart';
import '../view_model/hiv_test_view_model.dart';

class HIVTestScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const HIVTestScreen({super.key, this.onNext, this.onPrevious});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestViewModel>();

    return KenwellFormPage(
      title: 'HIV Test Screening Form',
      sectionTitle: 'Section F: HIV Screening',
      formKey: viewModel.formKey,
      children: [
        KenwellFormCard(
          title: 'HIV Testing History',
          child: Column(
            children: [
              KenwellYesNoQuestion<String>(
                question: 'Is this your first HIV test?',
                value: viewModel.firstHIVTest,
                onChanged: viewModel.setFirstHIVTest,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              if (viewModel.firstHIVTest == 'No') ...[
                KenwellTextField(
                  label: 'Month of last test',
                  hintText: 'MM',
                  controller: viewModel.lastTestMonthController,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Month of last test',
                    hint: 'MM',
                  ),
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                KenwellTextField(
                  label: 'Year of last test',
                  hintText: 'YYYY',
                  controller: viewModel.lastTestYearController,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Year of last test',
                    hint: 'YYYY',
                  ),
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                KenwellDropdownField<String>(
                  label: 'Result of last test',
                  value: viewModel.lastTestResult,
                  items: const ['Positive', 'Negative'],
                  onChanged: viewModel.setLastTestResult,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Result of last test',
                    hint: 'Select result of last test',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: 'Risk Behaviors (last 12 months)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellYesNoList<String>(
                items: [
                  KenwellYesNoItem(
                    question:
                        'Have you ever shared used needles or syringes with someone?',
                    value: viewModel.sharedNeedles,
                    onChanged: viewModel.setSharedNeedles,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question:
                        'Have you had unprotected sexual intercourse with more than one partner in the last 12 months?',
                    value: viewModel.unprotectedSex,
                    onChanged: viewModel.setUnprotectedSex,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question:
                        'Have you been diagnosed/treated for a sexually transmitted infection in the last 12 months?',
                    value: viewModel.treatedSTI,
                    onChanged: viewModel.setTreatedSTI,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question:
                        'Have you been diagnosed/treated for TB in the last 12 months?',
                    value: viewModel.treatedTB,
                    onChanged: viewModel.setTreatedTB,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question: 'Do you sometimes not use a condom?',
                    value: viewModel.noCondomUse,
                    onChanged: viewModel.setNoCondomUse,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                ],
              ),
              if (viewModel.noCondomUse == 'Yes')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: KenwellTextField(
                    label: 'Reason for not using a condom',
                    hintText: 'Explain why',
                    controller: viewModel.noCondomReasonController,
                    decoration: KenwellFormStyles.decoration(
                      label: 'Reason for not using a condom',
                      hint: 'Explain why',
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: 'Partner HIV Status & Risk Reasons',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellYesNoQuestion<String>(
                question:
                    'Do you know the HIV status of your regular sex partner/s?',
                value: viewModel.knowPartnerStatus,
                onChanged: viewModel.setKnowPartnerStatus,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              const SizedBox(height: 12),
              const Text(
                'Reasons that may have put you at risk:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF201C58),
                    fontSize: 16),
              ),
              KenwellCheckboxGroup(
                separator: const Divider(height: 0),
                options: _riskReasonOptions(viewModel),
              ),
              KenwellTextField(
                label: 'Other risk reason',
                hintText: 'Specify if "Other"',
                controller: viewModel.otherRiskReasonController,
                decoration: KenwellFormStyles.decoration(
                  label: 'Other risk reason',
                  hint: 'Specify if "Other"',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInitialAssessment(viewModel),
        const SizedBox(height: 24),
        _buildReferrals(viewModel),
        const SizedBox(height: 24),
        if (viewModel.windowPeriod == 'Yes') ...[
          _buildFollowUpSection(viewModel),
          const SizedBox(height: 24),
        ],
        _buildNurseDetails(viewModel),
        const SizedBox(height: 24),
        KenwellSignatureActions(
          title: 'Signature',
          controller: viewModel.signatureController,
          onClear: viewModel.clearSignature,
          navigation: KenwellFormNavigation(
            onPrevious: onPrevious,
            onNext: () => viewModel.submitHIVTest(onNext),
            isNextEnabled: viewModel.isFormValid && !viewModel.isSubmitting,
            isNextBusy: viewModel.isSubmitting,
          ),
        ),
      ],
    );
  }

  List<KenwellCheckboxOption> _riskReasonOptions(HIVTestViewModel vm) {
    const reasons = [
      'Partner has been unfaithful',
      'Exposed to another person’s body fluids while assisting with an injury',
      'A partner who had a sexually transmitted infection',
      'A partner who injects drugs and shares needles with other people',
      'Rape',
      'Other (specify below)',
    ];
    return reasons
        .map(
          (reason) => KenwellCheckboxOption(
            label: reason,
            value: vm.riskReasons.contains(reason),
            onChanged: (_) => vm.toggleRiskReason(reason),
          ),
        )
        .toList();
  }

  Widget _buildInitialAssessment(HIVTestViewModel viewModel) {
    return KenwellFormCard(
      title: 'Initial Assessment',
      child: Column(
        children: [
          KenwellDropdownField<String>(
            label: 'Window period risk assessment',
            value: viewModel.windowPeriod,
            items: viewModel.windowPeriodOptions,
            onChanged: viewModel.setWindowPeriod,
            decoration: KenwellFormStyles.decoration(
              label: 'Window period risk assessment',
              hint: 'Select window period risk assessment',
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Window period risk assessment' : null,
          ),
          KenwellDropdownField<String>(
            label: 'Did patient expect HIV (+) result?',
            value: viewModel.expectedResult,
            items: viewModel.expectedResultOptions,
            onChanged: viewModel.setExpectedResult,
            decoration: KenwellFormStyles.decoration(
              label: 'Did patient expect HIV (+) result?',
              hint: 'Select expected result',
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Did patient expect HIV (+) result?' : null,
          ),
          KenwellDropdownField<String>(
            label: 'Difficulty in dealing with result?',
            value: viewModel.difficultyDealingResult,
            items: viewModel.difficultyOptions,
            onChanged: viewModel.setDifficultyDealingResult,
            decoration: KenwellFormStyles.decoration(
              label: 'Difficulty in dealing with result?',
              hint: 'Select difficulty level',
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Difficulty in dealing with result?' : null,
          ),
          KenwellDropdownField<String>(
            label: 'Urgent psychosocial follow-up needed?',
            value: viewModel.urgentPsychosocial,
            items: viewModel.urgentOptions,
            onChanged: viewModel.setUrgentPsychosocial,
            decoration: KenwellFormStyles.decoration(
              label: 'Urgent psychosocial follow-up needed?',
              hint: 'Select urgent psychosocial status',
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Urgent psychosocial follow-up needed?' : null,
          ),
          KenwellDropdownField<String>(
            label: 'Committed to change behavior?',
            value: viewModel.committedToChange,
            items: viewModel.committedOptions,
            onChanged: viewModel.setCommittedToChange,
            decoration: KenwellFormStyles.decoration(
              label: 'Committed to change behavior?',
              hint: 'Select commitment status',
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Committed to change behavior?' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildReferrals(HIVTestViewModel viewModel) {
    return KenwellReferralCard<NursingReferralOption>(
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

  Widget _buildFollowUpSection(HIVTestViewModel viewModel) {
    return KenwellFormCard(
      title: 'Follow-up',
      child: Column(
        children: [
          KenwellDropdownField<String>(
            label: 'Follow-up location',
            value: viewModel.followUpLocation,
            items: viewModel.followUpLocationOptions,
            onChanged: viewModel.setFollowUpLocation,
            decoration: KenwellFormStyles.decoration(
              label: 'Follow-up location',
              hint: 'Select follow-up location',
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Follow-up location' : null,
          ),
          if (viewModel.followUpLocation == 'Other')
            KenwellTextField(
              label: 'Other location detail',
              hintText: 'Specify other location',
              controller: viewModel.followUpOtherController,
              decoration: KenwellFormStyles.decoration(
                label: 'Other location detail',
                hint: 'Specify other location',
              ),
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

  Widget _buildNurseDetails(HIVTestViewModel viewModel) {
    return KenwellFormCard(
      title: 'Nurse Details',
      child: Column(
        children: [
          KenwellTextField(
            label: 'Nurse First Name',
            hintText: 'Enter nurse first name',
            controller: viewModel.nurseFirstNameController,
            decoration: KenwellFormStyles.decoration(
              label: 'Nurse First Name',
              hint: 'Enter nurse first name',
            ),
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
            decoration: KenwellFormStyles.decoration(
              label: 'Nurse Last Name',
              hint: 'Enter nurse last name',
            ),
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
            decoration: KenwellFormStyles.decoration(
              label: 'Rank',
              hint: 'Enter nurse rank',
            ),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter Rank' : null,
          ),
          KenwellTextField(
            label: 'SANC No',
            hintText: 'Enter SANC number',
            controller: viewModel.sancNumberController,
            decoration: KenwellFormStyles.decoration(
              label: 'SANC No',
              hint: 'Enter SANC number',
            ),
            inputFormatters: AppTextInputFormatters.numbersOnly(),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter SANC No' : null,
          ),
          KenwellDateField(
            label: 'Date',
            controller: viewModel.nurseDateController,
            readOnly: true,
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Date' : null,
          ),
        ],
      ),
    );
  }
}
