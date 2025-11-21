import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/form_input_borders.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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
              // --- Initial Assessment Section ---
              Text(
                'SECTION E: HEALTH RISK ASSESSMENT NURSE INTERVENTION',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: const Color(0xFF201C58),
                    ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Initial Assessment',
                child: Column(
                  children: [
                    _buildDropdown(
                      'Window period risk assessment',
                      viewModel.windowPeriod,
                      viewModel.windowPeriodOptions,
                      viewModel.setWindowPeriod,
                    ),
                    _buildDropdown(
                      'Did patient expect HIV (+) result?',
                      viewModel.expectedResult,
                      viewModel.expectedResultOptions,
                      viewModel.setExpectedResult,
                    ),
                    _buildDropdown(
                      'Difficulty in dealing with result?',
                      viewModel.difficultyDealingResult,
                      viewModel.difficultyOptions,
                      viewModel.setDifficultyDealingResult,
                    ),
                    _buildDropdown(
                      'Urgent psychosocial follow-up needed?',
                      viewModel.urgentPsychosocial,
                      viewModel.urgentOptions,
                      viewModel.setUrgentPsychosocial,
                    ),
                    _buildDropdown(
                      'Committed to change behavior?',
                      viewModel.committedToChange,
                      viewModel.committedOptions,
                      viewModel.setCommittedToChange,
                    ),
                  ],
                ),
              ),
                const SizedBox(height: 16),

                // --- Referral Nursing Interventions Section ---
                _buildCard(
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
                          'Reason patient not referred',
                          viewModel.notReferredReasonController,
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

              // --- Follow-up Section ---
              if (viewModel.windowPeriod == 'Yes')
                _buildCard(
                  title: 'Follow-up',
                  child: Column(
                    children: [
                      _buildDropdown(
                        'Follow-up location',
                        viewModel.followUpLocation,
                        viewModel.followUpLocationOptions,
                        viewModel.setFollowUpLocation,
                      ),
                      if (viewModel.followUpLocation == 'Other')
                        _buildTextField(
                          'Other location detail',
                          viewModel.followUpOtherController,
                          hint: 'Specify other location',
                          requiredField: true,
                        ),
                      _buildDateField(
                        context,
                        'Follow-up test date',
                        viewModel.followUpDateController,
                        requiredField: true,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // --- Nurse Details Section ---
              _buildCard(
                title: 'Nurse Details',
                child: Column(
                  children: [
                    _buildTextField(
                      'HIV Testing Nurse',
                      viewModel.hivTestingNurseController,
                      hint: 'Enter nurse name',
                      requiredField: true,
                    ),
                    _buildTextField(
                      'Rank',
                      viewModel.rankController,
                      hint: 'Enter nurse rank',
                      requiredField: true,
                    ),
                    _buildTextField(
                      'SANC No',
                      viewModel.sancNumberController,
                      hint: 'Enter SANC number',
                      requiredField: true,
                    ),
                    _buildDateField(
                      context,
                      'Date',
                      viewModel.nurseDateController,
                      requiredField: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSignatureSection(viewModel),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Navigation Buttons ---
              Row(
                children: [
                  if (onPrevious != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPrevious,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: viewModel.isSubmitting
                          ? null
                          : () => viewModel.submitIntervention(context, onNext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF90C048),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      child: viewModel.isSubmitting
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : const Text(
                              'Next',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.white,
      shadowColor: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF201C58))),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // ------------------ Reusable Widgets ------------------
  Widget _buildSignatureSection(NurseInterventionViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signature:',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF201C58)),
        ),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(8),
            height: 160,
            child: Signature(
              controller: viewModel.signatureController,
              backgroundColor: Colors.grey[100]!,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: viewModel.clearSignature,
            child: const Text('Clear Signature'),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options,
      Function(String?) onChanged,
      {bool requiredField = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: _profileFieldDecoration(label, 'Select $label'),
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: onChanged,
        validator: requiredField
            ? (val) =>
                (val == null || val.isEmpty) ? 'Please select $label' : null
            : null,
      ),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint, bool requiredField = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: _profileFieldDecoration(label, hint),
        validator: requiredField
            ? (val) =>
                (val == null || val.isEmpty) ? 'Please enter $label' : null
            : null,
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController controller,
      {bool requiredField = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            controller.text =
                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
          }
        },
        validator: requiredField
            ? (val) =>
                (val == null || val.isEmpty) ? 'Please select $label' : null
            : null,
      ),
    );
  }

  InputDecoration _profileFieldDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: authOutlineInputBorder,
      enabledBorder: authOutlineInputBorder,
      focusedBorder: authOutlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF7643)),
      ),
    );
  }
}
