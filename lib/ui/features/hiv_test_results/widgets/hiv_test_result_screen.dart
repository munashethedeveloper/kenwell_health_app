import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_referral_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../../nurse_interventions/view_model/nurse_intervention_form_mixin.dart';
import '../view_model/hiv_test_result_view_model.dart';

class HIVTestResultScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const HIVTestResultScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestResultViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'HIV Test Results Form',
        automaticallyImplyLeading: false,
        backgroundColor: KenwellColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KenwellSectionHeader(
                title: 'Section G: HIV Test Results',
                uppercase: true,
              ),
              KenwellFormCard(
                title: 'Screening Test',
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Name of Test',
                      controller: viewModel.screeningTestNameController,
                      hint: 'Enter test name',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Batch No',
                      controller: viewModel.screeningBatchNoController,
                      hint: 'Enter batch number',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Expiry Date',
                      controller: viewModel.screeningExpiryDateController,
                      readOnly: true,
                      hint: 'Select expiry date',
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: KenwellColors.primaryGreenDark),
                      onTap: () =>
                          viewModel.pickExpiryDate(context, isScreening: true),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'Test Result',
                      ['Negative', 'Positive'],
                      viewModel.screeningResult,
                      viewModel.setScreeningResult,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInitialAssessment(viewModel),
              const SizedBox(height: 24),
              _buildReferrals(viewModel),
              const SizedBox(height: 24),
              // if (viewModel.windowPeriod == 'Yes') ...[
              //  _buildFollowUpSection(viewModel),
              //   const SizedBox(height: 24),
              //  ],
              _buildNurseDetails(viewModel),
              const SizedBox(height: 24),
              KenwellSignatureActions(
                title: 'Signature',
                controller: viewModel.signatureController,
                onClear: viewModel.clearSignature,
                navigation: KenwellFormNavigation(
                  onPrevious: onPrevious,
                  onNext: () => viewModel.submitTestResult(onNext),
                  isNextBusy: viewModel.isSubmitting,
                  isNextEnabled:
                      viewModel.isFormValid && !viewModel.isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return KenwellTextField(
      label: label,
      hintText: hint,
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: hint,
        suffixIcon: suffixIcon,
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      void Function(String) onChanged) {
    return KenwellDropdownField<String>(
      label: label,
      value: value,
      items: items,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: 'Select $label',
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildInitialAssessment(HIVTestResultViewModel viewModel) {
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
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please select Window period risk assessment'
                : null,
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
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please select Urgent psychosocial follow-up needed?'
                : null,
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
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please select Committed to change behavior?'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildReferrals(HIVTestResultViewModel viewModel) {
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
          label: 'Patient referred to State Clinic',
        ),
      ],
    );
  }

  // Widget _buildFollowUpSection(HIVTestResultViewModel viewModel) {
  // return KenwellFormCard(
  //   title: 'Follow-up',
  //   child: Column(
  //    children: [
  //      KenwellDropdownField<String>(
  //       label: 'Follow-up location',
  //        value: viewModel.followUpLocation,
  //        items: viewModel.followUpLocationOptions,
  //        onChanged: viewModel.setFollowUpLocation,
  //        decoration: KenwellFormStyles.decoration(
  //          label: 'Follow-up location',
  //          hint: 'Select follow-up location',
  //        ),
  //        validator: (val) => (val == null || val.isEmpty)
  //            ? 'Please select Follow-up location'
  //            : null,
  //      ),
  //      if (viewModel.followUpLocation == 'Other')
  //        KenwellTextField(
  //          label: 'Other location detail',
  //          hintText: 'Specify other location',
  //          controller: viewModel.followUpOtherController,
  //          decoration: KenwellFormStyles.decoration(
  //           label: 'Other location detail',
  //           hint: 'Specify other location',
  //          ),
  //         validator: (val) => (val == null || val.isEmpty)
  //             ? 'Please enter Other location detail'
  //              : null,
  //       ),
  //   KenwellDateField(
  //    label: 'Follow-up test date',
  //    controller: viewModel.followUpDateController,
  //     validator: (val) => (val == null || val.isEmpty)
  //         ? 'Please select Follow-up test date'
  //         : null,
  //      ),
  //    ],
  //   ),
  // );
//  }

  Widget _buildNurseDetails(HIVTestResultViewModel viewModel) {
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
