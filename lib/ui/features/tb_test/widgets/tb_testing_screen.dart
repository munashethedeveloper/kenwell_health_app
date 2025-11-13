import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/custom_date_picker.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
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
            const Text(
              'TB Symptom Screening',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            KenwellYesNoQuestion<String>(
              question: 'Have you been coughing for two weeks or more?',
              value: viewModel.coughTwoWeeks,
              onChanged: viewModel.setCoughTwoWeeks,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question: 'Is your sputum coloured when coughing?',
              value: viewModel.sputumColour,
              onChanged: viewModel.setSputumColour,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question: 'Is there blood in your sputum when you cough?',
              value: viewModel.bloodInSputum,
              onChanged: viewModel.setBloodInSputum,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question: 'Have you lost more than 3kg in the past 4 weeks?',
              value: viewModel.weightLoss,
              onChanged: viewModel.setWeightLoss,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question: 'Are you sweating unusually at night?',
              value: viewModel.nightSweats,
              onChanged: viewModel.setNightSweats,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question:
                  'Have you had recurrent fever/chills lasting more than three days?',
              value: viewModel.feverChills,
              onChanged: viewModel.setFeverChills,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question:
                  'Have you experienced chest pains or difficulty breathing?',
              value: viewModel.chestPain,
              onChanged: viewModel.setChestPain,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question: 'Do you have swellings in the neck or armpits?',
              value: viewModel.swellings,
              onChanged: viewModel.setSwellings,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            const Divider(height: 32),
            const Text(
              'History of TB Treatment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            KenwellYesNoQuestion<String>(
              question: 'Were you ever treated for Tuberculosis?',
              value: viewModel.treatedBefore,
              onChanged: viewModel.setTreatedBefore,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            if (viewModel.treatedBefore == 'Yes')
              KenwellDatePickerField(
                controller: viewModel.treatedDateController,
                label: 'When were you treated?',
                displayFormat: DateFormat('dd/MM/yyyy'),
              ),
            KenwellYesNoQuestion<String>(
              question: 'Did you complete the treatment?',
              value: viewModel.completedTreatment,
              onChanged: viewModel.setCompletedTreatment,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
            ),
            KenwellYesNoQuestion<String>(
              question:
                  'Were you in contact with someone diagnosed with Tuberculosis in the past year?',
              value: viewModel.contactWithTB,
              onChanged: viewModel.setContactWithTB,
              yesValue: 'Yes',
              noValue: 'No',
              padding: const EdgeInsets.only(bottom: 10),
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
}
