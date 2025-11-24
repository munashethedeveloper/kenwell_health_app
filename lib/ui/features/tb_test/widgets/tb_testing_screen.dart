import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_yes_no_list.dart';
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

    return KenwellFormPage(
      title: 'TB Test Screening Form',
      sectionTitle: 'Section I: TB Screening',
      children: [
        KenwellFormCard(
          title: 'TB Symptom Screening',
          child: KenwellYesNoList<String>(
            items: [
              KenwellYesNoItem(
                question: 'Have you been coughing for two weeks or more?',
                value: viewModel.coughTwoWeeks,
                onChanged: viewModel.setCoughTwoWeeks,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Is your sputum coloured when coughing?',
                value: viewModel.sputumColour,
                onChanged: viewModel.setSputumColour,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Is there blood in your sputum when you cough?',
                value: viewModel.bloodInSputum,
                onChanged: viewModel.setBloodInSputum,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Have you lost more than 3kg in the past 4 weeks?',
                value: viewModel.weightLoss,
                onChanged: viewModel.setWeightLoss,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Are you sweating unusually at night?',
                value: viewModel.nightSweats,
                onChanged: viewModel.setNightSweats,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question:
                    'Have you had recurrent fever/chills lasting more than three days?',
                value: viewModel.feverChills,
                onChanged: viewModel.setFeverChills,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question:
                    'Have you experienced chest pains or difficulty breathing?',
                value: viewModel.chestPain,
                onChanged: viewModel.setChestPain,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoItem(
                question: 'Do you have swellings in the neck or armpits?',
                value: viewModel.swellings,
                onChanged: viewModel.setSwellings,
                yesValue: 'Yes',
                noValue: 'No',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: 'History of TB Treatment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellYesNoList<String>(
                items: [
                  KenwellYesNoItem(
                    question: 'Were you ever treated for Tuberculosis?',
                    value: viewModel.treatedBefore,
                    onChanged: viewModel.setTreatedBefore,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question: 'Did you complete the treatment?',
                    value: viewModel.completedTreatment,
                    onChanged: viewModel.setCompletedTreatment,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question:
                        'Were you in contact with someone diagnosed with Tuberculosis in the past year?',
                    value: viewModel.contactWithTB,
                    onChanged: viewModel.setContactWithTB,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                ],
              ),
              if (viewModel.treatedBefore == 'Yes')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: KenwellDateField(
                    label: 'When were you treated?',
                    controller: viewModel.treatedDateController,
                    hint: 'Select treatment date',
                  ),
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
    );
  }
}
