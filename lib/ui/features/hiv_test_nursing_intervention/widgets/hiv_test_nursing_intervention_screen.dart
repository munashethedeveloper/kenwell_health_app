import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/hiv_test_nursing_intervention_view_model.dart';

class HIVTestNursingInterventionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const HIVTestNursingInterventionScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HIVTestNursingInterventionViewModel(),
      child: Consumer<HIVTestNursingInterventionViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'HIV Test Nursing Intervention',
                style: TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF90C048),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HCT Nursing Interventions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Example sections
                  _buildSectionTitle(
                      '1. Did the risk assessment indicate window period?'),
                  _buildRadioOptions(
                      viewModel.windowPeriod, viewModel.setWindowPeriod),

                  _buildSectionTitle('2. Follow-up test location'),
                  _buildCheckbox('State Clinic', viewModel.followUpClinic,
                      viewModel.setFollowUpClinic),
                  _buildCheckbox(
                      'Private Doctor',
                      viewModel.followUpPrivateDoctor,
                      viewModel.setFollowUpPrivateDoctor),
                  _buildCheckbox('Other (give detail)', viewModel.followUpOther,
                      viewModel.setFollowUpOther),
                  if (viewModel.followUpOther)
                    _buildTextField('Specify other location',
                        viewModel.followUpOtherDetailsController),

                  const SizedBox(height: 16),
                  _buildSectionTitle('3. Follow-up test date'),
                  _buildTextField(
                      'YYYY-MM-DD', viewModel.followUpDateController,
                      readOnly: true,
                      onTap: () => viewModel.pickFollowUpDate(context)),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: onPrevious,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text('Back'),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              viewModel.isFormValid && !viewModel.isSubmitting
                                  ? () => viewModel.submitIntervention(onNext)
                                  : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF201C58),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                          child: viewModel.isSubmitting
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text('Save & Continue',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
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

  // --- Helpers ---
  Widget _buildSectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildRadioOptions(String groupValue, Function(String) onChanged) {
    return RadioGroup<String>(
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      child: const Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: Text('N/A'),
              value: 'N/A',
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: Text('Yes'),
              value: 'Yes',
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: Text('No'),
              value: 'No',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (val) => onChanged(val!),
      title: Text(label),
    );
  }
}
