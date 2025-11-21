import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/form_input_borders.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
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
              Text(
                'SECTION F: HIV SCREENING',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: const Color(0xFF201C58),
                    ),
              ),
              const SizedBox(height: 24),
              _buildCard(
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
                        decoration: _profileFieldDecoration(
                          'Month of last test',
                          'MM',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      KenwellTextField(
                        label: 'Year of last test',
                        hintText: 'YYYY',
                        controller: viewModel.lastTestYearController,
                        decoration: _profileFieldDecoration(
                          'Year of last test',
                          'YYYY',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      KenwellDropdownField<String>(
                        label: 'Result of last test',
                        value: viewModel.lastTestResult,
                        items: const ['Positive', 'Negative'],
                        onChanged: viewModel.setLastTestResult,
                        decoration: _profileFieldDecoration(
                          'Result of last test',
                          'Select result of last test',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
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
                        decoration: _profileFieldDecoration(
                          'Reason for not using a condom',
                          'Explain why',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
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
                    const SizedBox(height: 8),
                    ..._riskReasonList(viewModel),
                    KenwellTextField(
                      label: 'Other risk reason',
                      hintText: 'Specify if "Other"',
                      controller: viewModel.otherRiskReasonController,
                      decoration: _profileFieldDecoration(
                        'Other risk reason',
                        'Specify if "Other"',
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF201C58))),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  List<Widget> _riskReasonList(HIVTestViewModel vm) {
    const reasons = [
      'Partner has been unfaithful',
      'Exposed to another person’s body fluids while assisting with an injury',
      'A partner who had a sexually transmitted infection',
      'A partner who injects drugs and shares needles with other people',
      'Rape',
      'Other (specify below)',
    ];
    return reasons.map((reason) {
      return CheckboxListTile(
        title: Text(reason),
        value: vm.riskReasons.contains(reason),
        onChanged: (_) => vm.toggleRiskReason(reason),
      );
    }).toList();
  }

  InputDecoration _profileFieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: authOutlineInputBorder,
      enabledBorder: authOutlineInputBorder,
      focusedBorder: authOutlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF7643)),
      ),
    );
  }
}
