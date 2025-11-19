import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/tb_testing_view_model.dart';

class TBTestingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const TBTestingScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TBTestingViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'TB Test Screening',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section I: TB Screening',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF201C58),
                  ),
            ),
            _buildCard(
              title: 'TB Symptom Screening',
              child: Column(
                children: [
                  _buildYesNo(
                    'Have you been coughing for two weeks or more?',
                    viewModel.coughTwoWeeks,
                    viewModel.setCoughTwoWeeks,
                  ),
                  _buildYesNo(
                    'Is your sputum coloured when coughing?',
                    viewModel.sputumColour,
                    viewModel.setSputumColour,
                  ),
                  _buildYesNo(
                    'Is there blood in your sputum when you cough?',
                    viewModel.bloodInSputum,
                    viewModel.setBloodInSputum,
                  ),
                  _buildYesNo(
                    'Have you lost more than 3kg in the past 4 weeks?',
                    viewModel.weightLoss,
                    viewModel.setWeightLoss,
                  ),
                  _buildYesNo(
                    'Are you sweating unusually at night?',
                    viewModel.nightSweats,
                    viewModel.setNightSweats,
                  ),
                  _buildYesNo(
                    'Have you had recurrent fever/chills lasting more than three days?',
                    viewModel.feverChills,
                    viewModel.setFeverChills,
                  ),
                  _buildYesNo(
                    'Have you experienced chest pains or difficulty breathing?',
                    viewModel.chestPain,
                    viewModel.setChestPain,
                  ),
                  _buildYesNo(
                    'Do you have swellings in the neck or armpits?',
                    viewModel.swellings,
                    viewModel.setSwellings,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'History of TB Treatment',
              child: Column(
                children: [
                  _buildYesNo(
                    'Were you ever treated for Tuberculosis?',
                    viewModel.treatedBefore,
                    viewModel.setTreatedBefore,
                  ),
                  if (viewModel.treatedBefore == 'Yes')
                    KenwellTextField(
                      label: 'When were you treated?',
                      controller: viewModel.treatedDateController,
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
                          viewModel.treatedDateController.text =
                              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                        }
                      },
                    ),
                  _buildYesNo(
                    'Did you complete the treatment?',
                    viewModel.completedTreatment,
                    viewModel.setCompletedTreatment,
                  ),
                  _buildYesNo(
                    'Were you in contact with someone diagnosed with Tuberculosis in the past year?',
                    viewModel.contactWithTB,
                    viewModel.setContactWithTB,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () => viewModel.submitTBTest(context, onNext: onNext),
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

  Widget _buildYesNo(
      String question, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: KenwellYesNoQuestion<String>(
        question: question,
        value: value,
        onChanged: onChanged,
        yesValue: 'Yes',
        noValue: 'No',
      ),
    );
  }
}
