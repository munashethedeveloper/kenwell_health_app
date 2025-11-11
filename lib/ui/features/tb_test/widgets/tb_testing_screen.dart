import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/tb_testing_view_model.dart';

class TBTestingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const TBTestingScreen(
      {super.key, required this.onNext, required this.onPrevious});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TBTestingViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
          title: 'TB Test Screening', automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TB Symptom Screening',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    onPressed: viewModel.isFormValid && !viewModel.isSubmitting
                        ? () => viewModel.submitTBTest(context, onNext: onNext)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90C048),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: viewModel.isSubmitting
                        ? const CircularProgressIndicator()
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
    );
  }

  Widget _buildYesNo(BuildContext context, String question, String? value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          RadioGroup<String>(
            groupValue: value,
            onChanged: onChanged,
            child: const Row(
              children: <Widget>[
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
          )
        ],
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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
      ),
    );
  }
}
