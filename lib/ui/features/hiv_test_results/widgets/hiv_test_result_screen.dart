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
import '../../../shared/ui/form/kenwell_modern_section_header.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../../../shared/models/nursing_referral_option.dart';
import '../view_model/hiv_test_result_view_model.dart';

// HIVTestResultScreen displays the HIV test results form
class HIVTestResultScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final PreferredSizeWidget? appBar;

  // Constructor
  const HIVTestResultScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
    this.appBar,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestResultViewModel>();

    // Auto-refer when the screening result is Positive (at risk)
    if (viewModel.isAtRisk) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.nursingReferralSelection == null ||
            viewModel.nursingReferralSelection ==
                NursingReferralOption.patientNotReferred) {
          viewModel.setNursingReferralSelection(
              NursingReferralOption.referredToStateClinic);
        }
      });
    }

    // Build the scaffold
    return Scaffold(
      // App bar
      appBar: appBar ??
          const KenwellAppBar(
            title: 'HIV Test Results Form',
            automaticallyImplyLeading: false,
            backgroundColor: KenwellColors.primaryGreen,
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Form
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Section Header
              const KenwellModernSectionHeader(
                title: 'Section C: HIV Test Results',
                subtitle:
                    'Please complete the form below to provide your HIV testing history and risk behaviors.',
                uppercase: true,
                icon: Icons.vaccines,
              ),
              // Spacing
              const SizedBox(height: 16),
              // Screening Test Card
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
              // Confirmatory Test Card
              _buildInitialAssessment(viewModel),
              const SizedBox(height: 24),
              // Show referral card only for positive (at-risk) results;
              // hide it for negative results and show a healthy status banner
              if (viewModel.isAtRisk) ...[
                _buildReferrals(viewModel),
                const SizedBox(height: 24),
              ] else ...[
                _buildNegativeBanner(),
                const SizedBox(height: 24),
              ],
              // Nurse Details Card
              _buildNurseDetails(viewModel),
              const SizedBox(height: 24),
              // Signature Actions
              KenwellSignatureActions(
                title: 'Signature',
                controller: viewModel.signatureController,
                onClear: viewModel.clearSignature,
                navigation: KenwellFormNavigation(
                  onPrevious: onPrevious,
                  onNext: () {
                    if (!viewModel.isFormValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all required fields'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    viewModel.submitTestResult(context, onNext: onNext);
                  },
                  isNextBusy: viewModel.isSubmitting,
                  isNextEnabled: !viewModel.isSubmitting,
                  nextLabel: 'Submit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a text field
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

  // Build a dropdown field
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

  // Build Initial Assessment section
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

  // Build Referrals section
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

  // Green banner shown when the HIV test result is negative (healthy)
  Widget _buildNegativeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E7D32), width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'HIV test result is Negative. No nursing referral is required.',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Nurse Details section
  Widget _buildNurseDetails(HIVTestResultViewModel viewModel) {
    return KenwellFormCard(
      title: 'Nurse Details',
      child: Column(
        children: [
          KenwellTextField(
            label: 'Nurse First Name',
            hintText: 'Auto-filled from profile',
            enabled: false,
            controller: viewModel.nurseFirstNameController,
            decoration: KenwellFormStyles.decoration(
              label: 'Nurse First Name',
              hint: 'Auto-filled from profile',
            ),
            readOnly: true,
            inputFormatters:
                AppTextInputFormatters.lettersOnly(allowHyphen: true),
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Nurse First Name'
                : null,
          ),
          KenwellTextField(
            label: 'Nurse Last Name',
            hintText: 'Auto-filled from profile',
            enabled: false,
            controller: viewModel.nurseLastNameController,
            decoration: KenwellFormStyles.decoration(
              label: 'Nurse Last Name',
              hint: 'Auto-filled from profile',
            ),
            readOnly: true,
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
            enabled: false,
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select Date' : null,
          ),
        ],
      ),
    );
  }
}
