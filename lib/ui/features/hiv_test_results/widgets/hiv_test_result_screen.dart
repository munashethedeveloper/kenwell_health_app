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
import '../../../shared/ui/form/nursing_referral_status_card.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../../../shared/models/nursing_referral_option.dart';
import '../view_model/hiv_test_result_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

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

    // Auto-refer based on the screening result.
    // This mirrors the logic in setScreeningResult() for the case where
    // the screen is first built after the VM already has a result selected.
    if (viewModel.isAtRisk) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.nursingReferralSelection == null ||
            viewModel.nursingReferralSelection ==
                NursingReferralOption.patientNotReferred) {
          viewModel.setNursingReferralSelection(
              NursingReferralOption.referredToStateClinic);
        }
      });
    } else if (viewModel.isHealthy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.nursingReferralSelection !=
            NursingReferralOption.patientNotReferred) {
          viewModel.setNursingReferralSelection(
              NursingReferralOption.patientNotReferred);
        }
      });
    }

    // Build the scaffold
    return Scaffold(
      // App bar
      appBar: appBar ??
          const KenwellAppBar(
            title: 'KenWell365',
            automaticallyImplyLeading: false,
          ),
      body: Column(
        children: [
          // ── Gradient section header ─────────────────────────────
          const KenwellGradientHeader(
            label: 'HIV RESULTS',
            title: 'HIV Test\nResults',
            subtitle:
                'Section C: Record HIV testing history and risk behaviors',
          ),
          // ── Scrollable form ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              // Form
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
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
                            onTap: () => viewModel.pickExpiryDate(
                              isScreening: true,
                              showPicker: () => showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              ),
                            ),
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
                    // Initial Assessment
                    _buildInitialAssessment(viewModel),
                    const SizedBox(height: 24),
                    // Nursing Referral — always shown, automatically locked
                    // to Healthy (Negative result) or At Risk (Positive result).
                    NursingReferralStatusCard(
                      title: 'Nursing Referrals',
                      selectedValue: viewModel.nursingReferralSelection,
                      onChanged: viewModel.setNursingReferralSelection,
                      // HCT has no caution state — outcome is always
                      // automatically determined from the test result.
                      readOnly: true,
                    ),
                    const SizedBox(height: 24),
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
                        onNext: () => viewModel.submitTestResult(
                          onNext: onNext,
                          onValidationFailed: (msg) =>
                              AppSnackbar.showWarning(context, msg),
                          onSuccess: (msg) =>
                              AppSnackbar.showSuccess(context, msg),
                          onError: (msg) => AppSnackbar.showError(context, msg),
                        ),
                        isNextBusy: viewModel.isSubmitting,
                        isNextEnabled: !viewModel.isSubmitting,
                        nextLabel: 'Submit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
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
