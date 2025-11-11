import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/forms/kenwell_form_fields.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
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
    final viewModel = context.watch<HIVTestNursingInterventionViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
          title: 'HIV Test Nursing Intervention',
          automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HCT Nursing Interventions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Example sections
            _buildSectionTitle(
                '1. Did the risk assessment indicate window period?'),
            _buildRadioOptions(
                viewModel.windowPeriod, viewModel.setWindowPeriod),

            _buildSectionTitle('2. Follow-up test location'),
            _buildCheckbox('State Clinic', viewModel.followUpClinic,
                viewModel.setFollowUpClinic),
            _buildCheckbox('Private Doctor', viewModel.followUpPrivateDoctor,
                viewModel.setFollowUpPrivateDoctor),
            _buildCheckbox('Other (give detail)', viewModel.followUpOther,
                viewModel.setFollowUpOther),
            if (viewModel.followUpOther)
                KenwellTextField(
                  label: 'Specify other location',
                  controller: viewModel.followUpOtherDetailsController,
                ),

            const SizedBox(height: 16),
            _buildSectionTitle('3. Follow-up test date'),
              KenwellTextField(
                label: 'YYYY-MM-DD',
                controller: viewModel.followUpDateController,
                readOnly: true,
                onTap: () => viewModel.pickFollowUpDate(context),
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
  Widget _buildSectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

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
                  if (value != null) {
                    onChanged(value);
                  }
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
    );
  }
}
