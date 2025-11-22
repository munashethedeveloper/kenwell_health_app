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
                        validator: _requireSelection(
                            'Did patient expect HIV (+) result?'),
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
                        validator: _requireSelection(
                            'Urgent psychosocial follow-up needed?'),
                      ),
                      KenwellDropdownField<String>(
                        label: 'Committed to change behavior?',
                        value: viewModel.committedToChange,
                        items: viewModel.committedOptions,
                        onChanged: viewModel.setCommittedToChange,
                        validator:
                            _requireSelection('Committed to change behavior?'),
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
                        KenwellTextField(
                          label: 'Reason patient not referred',
                          hintText: 'Enter reason',
                          controller: viewModel.notReferredReasonController,
                          validator: (val) =>
                              (val == null || val.isEmpty) ? 'Please enter Reason patient not referred' : null,
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
                        KenwellDropdownField<String>(
                          label: 'Follow-up location',
                          value: viewModel.followUpLocation,
                          items: viewModel.followUpLocationOptions,
                          onChanged: viewModel.setFollowUpLocation,
                          validator:
                              _requireSelection('Follow-up location'),
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
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Please enter SANC No' : null,
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

  FormFieldValidator<String> _requireSelection(String label) {
    return (val) => (val == null || val.isEmpty) ? 'Please select $label' : null;
  }
}
