import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/widgets/question_radio_group.dart';
import '../view_model/tb_testing_view_model.dart';

class TBTestingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const TBTestingScreen(
      {super.key, required this.onNext, required this.onPrevious});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TBTestingViewModel(),
      child: Consumer<TBTestingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'TB Test Screening',
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
                  const Text('TB Symptom Screening',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildYesNo(
                    context,
                    'Have you been coughing for two weeks or more?',
                    viewModel.coughTwoWeeks,
                    viewModel.setCoughTwoWeeks,
                  ),
                  _buildYesNo(
                    context,
                    'Is your sputum coloured when coughing?',
                    viewModel.sputumColour,
                    viewModel.setSputumColour,
                  ),
                  _buildYesNo(
                    context,
                    'Is there blood in your sputum when you cough?',
                    viewModel.bloodInSputum,
                    viewModel.setBloodInSputum,
                  ),
                  _buildYesNo(
                    context,
                    'Have you lost more than 3kg in the past 4 weeks?',
                    viewModel.weightLoss,
                    viewModel.setWeightLoss,
                  ),
                  _buildYesNo(
                    context,
                    'Are you sweating unusually at night?',
                    viewModel.nightSweats,
                    viewModel.setNightSweats,
                  ),
                  _buildYesNo(
                    context,
                    'Have you had recurrent fever/chills lasting more than three days?',
                    viewModel.feverChills,
                    viewModel.setFeverChills,
                  ),
                  _buildYesNo(
                    context,
                    'Have you experienced chest pains or difficulty breathing?',
                    viewModel.chestPain,
                    viewModel.setChestPain,
                  ),
                  _buildYesNo(
                    context,
                    'Do you have swellings in the neck or armpits?',
                    viewModel.swellings,
                    viewModel.setSwellings,
                  ),
                  const Divider(height: 32),
                  const Text('History of TB Treatment',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildYesNo(
                    context,
                    'Were you ever treated for Tuberculosis?',
                    viewModel.treatedBefore,
                    viewModel.setTreatedBefore,
                  ),
                  if (viewModel.treatedBefore == 'Yes')
                    _buildDateField(context, 'When were you treated?',
                        viewModel.treatedDateController),
                  _buildYesNo(
                    context,
                    'Did you complete the treatment?',
                    viewModel.completedTreatment,
                    viewModel.setCompletedTreatment,
                  ),
                  _buildYesNo(
                    context,
                    'Were you in contact with someone diagnosed with Tuberculosis in the past year?',
                    viewModel.contactWithTB,
                    viewModel.setContactWithTB,
                  ),
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
                                  ? () => viewModel.submitTBTest(context,
                                      onNext: onNext)
                                  : null,
                          child: viewModel.isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text('Submit & Continue'),
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

  Widget _buildYesNo(BuildContext context, String question, String? value,
      ValueChanged<String?> onChanged) {
    return QuestionRadioGroup<String>(
      question: question,
      value: value,
      onChanged: onChanged,
      padding: const EdgeInsets.only(bottom: 10),
      options: const [
        RadioOption(value: 'Yes', label: 'Yes'),
        RadioOption(value: 'No', label: 'No'),
      ],
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
