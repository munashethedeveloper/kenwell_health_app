import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/hiv_test_nursing_intervention_view_model.dart';
import 'package:signature/signature.dart';

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
    final viewModel = context.watch<HIVTestNursingInterventionViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'HIV Test Nursing Intervention',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECTION H: HIV TEST NURSING INTERVENTIONS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF201C58),
                  ),
            ),
            _buildCard(
              title: 'Initial Assessment',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '1. Did the risk assessment indicate window period?',
                    _buildRadioOptions(
                        viewModel.windowPeriod, viewModel.setWindowPeriod),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    '2. Follow-up test location',
                    Column(
                      children: [
                        _buildCheckbox('State Clinic', viewModel.followUpClinic,
                            viewModel.setFollowUpClinic),
                        _buildCheckbox(
                            'Private Doctor',
                            viewModel.followUpPrivateDoctor,
                            viewModel.setFollowUpPrivateDoctor),
                        _buildCheckbox(
                            'Other (give detail)',
                            viewModel.followUpOther,
                            viewModel.setFollowUpOther),
                        if (viewModel.followUpOther)
                          KenwellTextField(
                            label: 'Specify other location',
                            controller:
                                viewModel.followUpOtherDetailsController,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    '3. Follow-up test date',
                    KenwellTextField(
                      label: 'YYYY-MM-DD',
                      controller: viewModel.followUpDateController,
                      readOnly: true,
                      onTap: () => viewModel.pickFollowUpDate(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Signature:',
              child: _buildSignatureSection(viewModel),
            ),
            const SizedBox(height: 24),
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () => viewModel.submitIntervention(onNext),
              isNextEnabled: viewModel.isFormValid && !viewModel.isSubmitting,
              isNextBusy: viewModel.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.grey.shade300,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF201C58))),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildRadioOptions(String groupValue, ValueChanged<String> onChanged) {
    const options = ['N/A', 'Yes', 'No'];
    return Row(
      children: options
          .map(
            (option) => Expanded(
              child: RadioListTile<String>(
                title: Text(option),
                value: option,
                dense: true,
                groupValue: groupValue,
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (val) => onChanged(val!),
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildSignatureSection(HIVTestNursingInterventionViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
}
