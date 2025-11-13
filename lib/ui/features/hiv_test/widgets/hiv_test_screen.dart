import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_checkbox_field.dart';
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
    final vm = context.watch<HIVTestViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'HIV Test Screening',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------
            // FIRST HIV TEST QUESTION
            // -----------------------------
            KenwellYesNoQuestion<String>(
              question: 'Is this your first HIV test?',
              value: vm.firstHIVTest,
              onChanged: vm.setFirstHIVTest,
              yesValue: 'Yes',
              noValue: 'No',
            ),
            if (vm.firstHIVTest == 'No') ...[
              KenwellTextField(
                label: 'Month of last test (MM)',
                controller: vm.lastTestMonthController,
              ),
              KenwellTextField(
                label: 'Year of last test (YYYY)',
                controller: vm.lastTestYearController,
              ),
              KenwellDropdownField<String>(
                label: 'What was the result of your last test?',
                value: vm.lastTestResult,
                items: const ['Positive', 'Negative'],
                onChanged: vm.setLastTestResult,
              ),
            ],

            const Divider(height: 32),

            // -----------------------------
            // RISK BEHAVIOR QUESTIONS
            // -----------------------------
            KenwellYesNoQuestion<String>(
              question:
                  'Have you ever shared used needles or syringes with someone?',
              value: vm.sharedNeedles,
              onChanged: vm.setSharedNeedles,
              yesValue: 'Yes',
              noValue: 'No',
            ),
            KenwellYesNoQuestion<String>(
              question:
                  'Have you had unprotected sexual intercourse with more than one partner in the last 12 months?',
              value: vm.unprotectedSex,
              onChanged: vm.setUnprotectedSex,
              yesValue: 'Yes',
              noValue: 'No',
            ),
            KenwellYesNoQuestion<String>(
              question:
                  'Have you been diagnosed and/or treated for a sexually transmitted infection during the last 12 months?',
              value: vm.treatedSTI,
              onChanged: vm.setTreatedSTI,
              yesValue: 'Yes',
              noValue: 'No',
            ),
            KenwellYesNoQuestion<String>(
              question:
                  'Have you been diagnosed and/or treated for TB during the last 12 months?',
              value: vm.treatedTB,
              onChanged: vm.setTreatedTB,
              yesValue: 'Yes',
              noValue: 'No',
            ),
            KenwellYesNoQuestion<String>(
              question: 'Do you sometimes not use a condom?',
              value: vm.noCondomUse,
              onChanged: vm.setNoCondomUse,
              yesValue: 'Yes',
              noValue: 'No',
            ),
            if (vm.noCondomUse == 'Yes')
              KenwellTextField(
                label: 'If yes, why do you sometimes not use a condom?',
                controller: vm.noCondomReasonController,
              ),

            const Divider(height: 32),

            // -----------------------------
            // PARTNER STATUS
            // -----------------------------
            KenwellYesNoQuestion<String>(
              question:
                  'Do you know the HIV status of your regular sex partner/s?',
              value: vm.knowPartnerStatus,
              onChanged: vm.setKnowPartnerStatus,
              yesValue: 'Yes',
              noValue: 'No',
            ),

            const SizedBox(height: 12),
            const Text(
              'Reasons that may have put you at risk:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // -----------------------------
            // RISK REASONS (CHECKBOXES)
            // -----------------------------
            KenwellCheckbox(
              title: 'Partner has been unfaithful',
              value: vm.riskReasons.contains('Partner has been unfaithful'),
              onChanged: (_) =>
                  vm.toggleRiskReason('Partner has been unfaithful'),
            ),
            KenwellCheckbox(
              title:
                  'Exposed to another person’s body fluids while assisting with an injury',
              value: vm.riskReasons.contains(
                'Exposed to another person’s body fluids while assisting with an injury',
              ),
              onChanged: (_) => vm.toggleRiskReason(
                'Exposed to another person’s body fluids while assisting with an injury',
              ),
            ),
            KenwellCheckbox(
              title: 'A partner who had a sexually transmitted infection',
              value: vm.riskReasons.contains(
                  'A partner who had a sexually transmitted infection'),
              onChanged: (_) => vm.toggleRiskReason(
                'A partner who had a sexually transmitted infection',
              ),
            ),
            KenwellCheckbox(
              title:
                  'A partner who injects drugs and shares needles with other people',
              value: vm.riskReasons.contains(
                'A partner who injects drugs and shares needles with other people',
              ),
              onChanged: (_) => vm.toggleRiskReason(
                'A partner who injects drugs and shares needles with other people',
              ),
            ),
            KenwellCheckbox(
              title: 'Rape',
              value: vm.riskReasons.contains('Rape'),
              onChanged: (_) => vm.toggleRiskReason('Rape'),
            ),
            KenwellCheckbox(
              title: 'Other (specify below)',
              value: vm.riskReasons.contains('Other (specify below)'),
              onChanged: (_) => vm.toggleRiskReason('Other (specify below)'),
            ),

            KenwellTextField(
              label: 'If other, specify',
              controller: vm.otherRiskReasonController,
            ),

            const SizedBox(height: 20),

            // -----------------------------
            // NAVIGATION BUTTONS
            // -----------------------------
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () => vm.submitHIVTest(onNext),
              isNextEnabled: vm.isFormValid && !vm.isSubmitting,
              isNextBusy: vm.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
