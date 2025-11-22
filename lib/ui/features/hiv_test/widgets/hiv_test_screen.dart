import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_checkbox_group.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/hiv_test_view_model.dart';

class HIVTestScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const HIVTestScreen({super.key, this.onNext, this.onPrevious});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'HIV Test Screening',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KenwellSectionHeader(
                title: 'Section F: HIV Screening',
                uppercase: true,
              ),
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
                  children: [
                    KenwellYesNoQuestion<String>(
                      question:
                          'Have you ever shared used needles or syringes with someone?',
                      value: viewModel.sharedNeedles,
                      onChanged: viewModel.setSharedNeedles,
                      yesValue: 'Yes',
                      noValue: 'No',
                    ),
                    KenwellYesNoQuestion<String>(
                      question:
                          'Have you had unprotected sexual intercourse with more than one partner in the last 12 months?',
                      value: viewModel.unprotectedSex,
                      onChanged: viewModel.setUnprotectedSex,
                      yesValue: 'Yes',
                      noValue: 'No',
                    ),
                    KenwellYesNoQuestion<String>(
                      question:
                          'Have you been diagnosed/treated for a sexually transmitted infection in the last 12 months?',
                      value: viewModel.treatedSTI,
                      onChanged: viewModel.setTreatedSTI,
                      yesValue: 'Yes',
                      noValue: 'No',
                    ),
                    KenwellYesNoQuestion<String>(
                      question:
                          'Have you been diagnosed/treated for TB in the last 12 months?',
                      value: viewModel.treatedTB,
                      onChanged: viewModel.setTreatedTB,
                      yesValue: 'Yes',
                      noValue: 'No',
                    ),
                    KenwellYesNoQuestion<String>(
                      question: 'Do you sometimes not use a condom?',
                      value: viewModel.noCondomUse,
                      onChanged: viewModel.setNoCondomUse,
                      yesValue: 'Yes',
                      noValue: 'No',
                    ),
                    if (viewModel.noCondomUse == 'Yes')
                      KenwellTextField(
                        label: 'Reason for not using a condom',
                        hintText: 'Explain why',
                        controller: viewModel.noCondomReasonController,
                        decoration: KenwellFormStyles.decoration(
                          label: 'Reason for not using a condom',
                          hint: 'Explain why',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
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
                    const Text(
                      'Reasons that may have put you at risk:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF201C58)),
                    ),
                    KenwellCheckboxGroup(
                      separator: const Divider(height: 0),
                      options: _riskReasonOptions(viewModel),
                    ),
                    KenwellTextField(
                      label: 'Other risk reason',
                      hintText: 'Specify if "Other"',
                      controller: viewModel.otherRiskReasonController,
                      decoration: KenwellFormStyles.decoration(
                        label: 'Other risk reason',
                        hint: 'Specify if "Other"',
                      ),
                    ),
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
          ),
        ),
      ),
    );
  }

  List<KenwellCheckboxOption> _riskReasonOptions(HIVTestViewModel vm) {
    const reasons = [
      'Partner has been unfaithful',
      'Exposed to another person’s body fluids while assisting with an injury',
      'A partner who had a sexually transmitted infection',
      'A partner who injects drugs and shares needles with other people',
      'Rape',
      'Other (specify below)',
    ];
    return reasons
        .map(
          (reason) => KenwellCheckboxOption(
            label: reason,
            value: vm.riskReasons.contains(reason),
            onChanged: (_) => vm.toggleRiskReason(reason),
          ),
        )
        .toList();
  }
}
