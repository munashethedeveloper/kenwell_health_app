import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/form/kenwell_signature_field.dart';
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

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Health Risk Assessment Nurse Intervention',
        automaticallyImplyLeading: false,
      ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KenwellSectionHeader(
                  title: 'Section E: Health Risk Assessment Nurse Intervention',
                  uppercase: true,
                ),
                KenwellFormCard(
                  title: 'Initial Assessment',
                  child: Column(
                    children: [
                      _buildDropdownField(
                        label: 'Window period risk assessment',
                        value: viewModel.windowPeriod,
                        options: viewModel.windowPeriodOptions,
                        onChanged: viewModel.setWindowPeriod,
                      ),
                      _buildDropdownField(
                        label: 'Did patient expect HIV (+) result?',
                        value: viewModel.expectedResult,
                        options: viewModel.expectedResultOptions,
                        onChanged: viewModel.setExpectedResult,
                      ),
                      _buildDropdownField(
                        label: 'Difficulty in dealing with result?',
                        value: viewModel.difficultyDealingResult,
                        options: viewModel.difficultyOptions,
                        onChanged: viewModel.setDifficultyDealingResult,
                      ),
                      _buildDropdownField(
                        label: 'Urgent psychosocial follow-up needed?',
                        value: viewModel.urgentPsychosocial,
                        options: viewModel.urgentOptions,
                        onChanged: viewModel.setUrgentPsychosocial,
                      ),
                      _buildDropdownField(
                        label: 'Committed to change behavior?',
                        value: viewModel.committedToChange,
                        options: viewModel.committedOptions,
                        onChanged: viewModel.setCommittedToChange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                KenwellFormCard(
                  title: 'Nursing Referrals',
                  child: Column(
                    children: [
                      _buildReferralRadio(
                        viewModel: viewModel,
                        option: NursingReferralOption.patientNotReferred,
                        label: 'Patient not referred',
                      ),
                      if (viewModel.nursingReferralSelection ==
                          NursingReferralOption.patientNotReferred)
                        _buildTextField(
                          label: 'Reason patient not referred',
                          controller: viewModel.notReferredReasonController,
                          hint: 'Enter reason',
                          requiredField: true,
                        ),
                      _buildReferralRadio(
                        viewModel: viewModel,
                        option: NursingReferralOption.referredToGP,
                        label: 'Patient referred to GP',
                      ),
                      _buildReferralRadio(
                        viewModel: viewModel,
                        option: NursingReferralOption.referredToStateClinic,
                        label: 'Patient referred to State HIV clinic',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (viewModel.windowPeriod == 'Yes')
                  KenwellFormCard(
                    title: 'Follow-up',
                    child: Column(
                      children: [
                        _buildDropdownField(
                          label: 'Follow-up location',
                          value: viewModel.followUpLocation,
                          options: viewModel.followUpLocationOptions,
                          onChanged: viewModel.setFollowUpLocation,
                          requiredField: true,
                        ),
                        if (viewModel.followUpLocation == 'Other')
                          _buildTextField(
                            label: 'Other location detail',
                            controller: viewModel.followUpOtherController,
                            hint: 'Specify other location',
                            requiredField: true,
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
                      _buildTextField(
                        label: 'HIV Testing Nurse',
                        controller: viewModel.hivTestingNurseController,
                        hint: 'Enter nurse name',
                        requiredField: true,
                        inputFormatters:
                            AppTextInputFormatters.lettersOnly(allowHyphen: true),
                      ),
                      _buildTextField(
                        label: 'Rank',
                        controller: viewModel.rankController,
                        hint: 'Enter nurse rank',
                        requiredField: true,
                      ),
                      _buildTextField(
                        label: 'SANC No',
                        controller: viewModel.sancNumberController,
                        hint: 'Enter SANC number',
                        requiredField: true,
                        inputFormatters: AppTextInputFormatters.numbersOnly(),
                      ),
                      KenwellDateField(
                        label: 'Date',
                        controller: viewModel.nurseDateController,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Please select Date'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      KenwellSignatureField(
                        controller: viewModel.signatureController,
                        onClear: viewModel.clearSignature,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                KenwellFormNavigation(
                  onPrevious: onPrevious,
                  onNext: () => viewModel.submitIntervention(context, onNext),
                  isNextBusy: viewModel.isSubmitting,
                  isNextEnabled: !viewModel.isSubmitting,
                ),
              ],
            ),
          ),
        ),
    );
  }

  // ------------------ Reusable Widgets ------------------
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool requiredField = true,
  }) {
    return KenwellDropdownField<String>(
      label: label,
      value: value,
      items: options,
      onChanged: onChanged,
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: 'Select $label',
      ),
      validator: requiredField
          ? (val) =>
              (val == null || val.isEmpty) ? 'Please select $label' : null
          : null,
    );
  }

  Widget _buildReferralRadio({
    required NurseInterventionViewModel viewModel,
    required NursingReferralOption option,
    required String label,
  }) {
    return RadioListTile<NursingReferralOption>(
      value: option,
      groupValue: viewModel.nursingReferralSelection,
      onChanged: viewModel.setNursingReferralSelection,
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool requiredField = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return KenwellTextField(
      label: label,
      hintText: hint,
      controller: controller,
      inputFormatters: inputFormatters,
      decoration: KenwellFormStyles.decoration(label: label, hint: hint),
      validator: requiredField
          ? (val) => (val == null || val.isEmpty) ? 'Please enter $label' : null
          : null,
    );
  }
}
