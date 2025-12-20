import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_yes_no_list.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/hiv_test_view_model.dart';

class HIVTestScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const HIVTestScreen({super.key, this.onNext, this.onPrevious});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestViewModel>();

    return KenwellFormPage(
      title: 'HIV Test Screening Form',
      sectionTitle: 'Section F: HIV Screening',
      formKey: viewModel.formKey,
      children: [
        KenwellFormCard(
          title: 'HIV Testing History',
          child: Column(
            children: [
              KenwellYesNoQuestion<String>(
                question: 'Is this your first HIV test?',
                value: viewModel.firstHIVTest,
                onChanged: viewModel.setFirstHIVTest,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              if (viewModel.firstHIVTest == 'No') ...[
                KenwellTextField(
                  label: 'Month of last test',
                  hintText: 'MM',
                  controller: viewModel.lastTestMonthController,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Month of last test',
                    hint: 'MM',
                  ),
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                KenwellTextField(
                  label: 'Year of last test',
                  hintText: 'YYYY',
                  controller: viewModel.lastTestYearController,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Year of last test',
                    hint: 'YYYY',
                  ),
                  inputFormatters: AppTextInputFormatters.numbersOnly(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                KenwellDropdownField<String>(
                  label: 'Result of last test',
                  value: viewModel.lastTestResult,
                  items: const ['Positive', 'Negative'],
                  onChanged: viewModel.setLastTestResult,
                  decoration: KenwellFormStyles.decoration(
                    label: 'Result of last test',
                    hint: 'Select result of last test',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: 'Risk Behaviors (last 12 months)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellYesNoList<String>(
                items: [
                  KenwellYesNoItem(
                    question:
                        'Have you ever shared used needles or syringes with someone?',
                    value: viewModel.sharedNeedles,
                    onChanged: viewModel.setSharedNeedles,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question:
                        'Have you had unprotected sexual intercourse with more than one partner in the last 12 months?',
                    value: viewModel.unprotectedSex,
                    onChanged: viewModel.setUnprotectedSex,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                  KenwellYesNoItem(
                    question:
                        'Have you been diagnosed/treated for a sexually transmitted infection in the last 12 months?',
                    value: viewModel.treatedSTI,
                    onChanged: viewModel.setTreatedSTI,
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: 'Partner HIV Status & Risk Reasons',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KenwellYesNoQuestion<String>(
                question:
                    'Do you know the HIV status of your regular sex partner/s?',
                value: viewModel.knowPartnerStatus,
                onChanged: viewModel.setKnowPartnerStatus,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormNavigation(
          onPrevious: onPrevious,
          onNext: () => viewModel.submitHIVTest(onNext),
          isNextEnabled: viewModel.isFormValid && !viewModel.isSubmitting,
          isNextBusy: viewModel.isSubmitting,
        ),
      ],
    );
  }
}
