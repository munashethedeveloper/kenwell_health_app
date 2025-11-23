import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
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

    return KenwellFormPage(
      title: 'HIV Test Nursing Intervention',
      sectionTitle: 'Section H: HIV Test Nursing Interventions',
      children: [
        KenwellFormCard(
          title: 'Initial Assessment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                '1. Did the risk assessment indicate window period?',
                _buildRadioOptions(
                  viewModel.windowPeriod,
                  viewModel.setWindowPeriod,
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                '2. Follow-up test location',
                Column(
                  children: [
                    _buildFollowUpRadio(
                      label: 'State Clinic',
                      option: FollowUpLocationOption.stateClinic,
                      viewModel: viewModel,
                    ),
                    _buildFollowUpRadio(
                      label: 'Private Doctor',
                      option: FollowUpLocationOption.privateDoctor,
                      viewModel: viewModel,
                    ),
                    _buildFollowUpRadio(
                      label: 'Other (give detail)',
                      option: FollowUpLocationOption.other,
                      viewModel: viewModel,
                    ),
                    if (viewModel.followUpLocation ==
                        FollowUpLocationOption.other)
                      KenwellTextField(
                        label: 'Specify other location',
                        controller: viewModel.followUpOtherDetailsController,
                        decoration: KenwellFormStyles.decoration(
                          label: 'Specify other location',
                          hint: 'Enter location details',
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                '3. Follow-up test date',
                KenwellDateField(
                  label: 'Follow-up Date',
                  controller: viewModel.followUpDateController,
                  dateFormat: 'yyyy-MM-dd',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KenwellSignatureActions(
          controller: viewModel.signatureController,
          onClear: viewModel.clearSignature,
          navigation: KenwellFormNavigation(
            onPrevious: onPrevious,
            onNext: () => viewModel.submitIntervention(onNext),
            isNextEnabled: viewModel.isFormValid && !viewModel.isSubmitting,
            isNextBusy: viewModel.isSubmitting,
          ),
        ),
      ],
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

  Widget _buildFollowUpRadio({
    required String label,
    required FollowUpLocationOption option,
    required HIVTestNursingInterventionViewModel viewModel,
  }) {
    return RadioListTile<FollowUpLocationOption>(
      title: Text(label),
      value: option,
      groupValue: viewModel.followUpLocation,
      onChanged: viewModel.setFollowUpLocation,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
