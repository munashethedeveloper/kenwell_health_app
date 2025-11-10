import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../../../shared/widgets/signature_field.dart';
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
    return ChangeNotifierProvider(
      create: (_) => NurseInterventionViewModel(),
      child: Consumer<NurseInterventionViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Personal Health Risk Assessment Nurse Intervention',
                style: TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF90C048),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Window Period & Other Initial Fields ---
                  _buildDropdown(
                    'Window period risk assessment',
                    viewModel.windowPeriod,
                    viewModel.windowPeriodOptions,
                    viewModel.setWindowPeriod,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Did patient expect HIV (+) result?',
                    viewModel.expectedResult,
                    viewModel.expectedResultOptions,
                    viewModel.setExpectedResult,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Difficulty in dealing with result?',
                    viewModel.difficultyDealingResult,
                    viewModel.difficultyOptions,
                    viewModel.setDifficultyDealingResult,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Urgent psychosocial follow-up needed?',
                    viewModel.urgentPsychosocial,
                    viewModel.urgentOptions,
                    viewModel.setUrgentPsychosocial,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Committed to change behavior?',
                    viewModel.committedToChange,
                    viewModel.committedOptions,
                    viewModel.setCommittedToChange,
                  ),
                  const SizedBox(height: 12),

                  // --- Referral Nursing Interventions ---
                  const Text(
                    'Referral Nursing Interventions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Patient not referred'),
                    value: viewModel.patientNotReferred,
                    onChanged: (val) =>
                        viewModel.setPatientNotReferred(val ?? false),
                  ),
                  if (viewModel.patientNotReferred)
                    _buildTextField(
                      'Reason patient not referred',
                      viewModel.notReferredReasonController,
                    ),
                  CheckboxListTile(
                    title: const Text('Patient referred to GP'),
                    value: viewModel.referredToGP,
                    onChanged: (val) => viewModel.setReferredToGP(val ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Patient referred to State HIV clinic'),
                    value: viewModel.referredToStateClinic,
                    onChanged: (val) =>
                        viewModel.setReferredToStateClinic(val ?? false),
                  ),

                  // --- Follow-up Location & Date ---
                  if (viewModel.windowPeriod == 'Yes') ...[
                    const SizedBox(height: 12),
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
                      ),
                    const SizedBox(height: 12),
                    _buildDateField(
                      context,
                      'Follow-up test date',
                      viewModel.followUpDateController,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // --- Nurse Details ---
                  const Text(
                    'Nurse Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                      'HIV Testing Nurse', viewModel.hivTestingNurseController),
                  const SizedBox(height: 12),
                  _buildTextField('Rank', viewModel.rankController),
                  const SizedBox(height: 12),

                  // --- Signature ---
                  SignatureField(
                    controller: viewModel.signatureController,
                    onClear: viewModel.signatureController.clear,
                  ),

                  _buildTextField('SANC No', viewModel.sancNumberController),
                  const SizedBox(height: 12),
                  _buildDateField(
                      context, 'Date', viewModel.nurseDateController),
                  const SizedBox(height: 24),

                  // --- Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (onPrevious != null)
                        ElevatedButton(
                          onPressed: onPrevious,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Back'),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewModel.isSubmitting
                              ? null
                              : () =>
                                  viewModel.submitIntervention(context, onNext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF90C048),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: viewModel.isSubmitting
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text(
                                  'Submit Interventions',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options,
      ValueChanged<String?> onChanged) {
    return LabeledDropdown<String>(
      label: label,
      value: value,
      options: options,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return DatePickerField(
      label: label,
      controller: controller,
    );
  }
}
