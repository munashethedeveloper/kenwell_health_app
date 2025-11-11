import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/forms/kenwell_form_fields.dart';
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
          title: 'HIV Test Screening', automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  label: 'Month of last test (MM)',
                  controller: viewModel.lastTestMonthController,
                ),
                KenwellTextField(
                  label: 'Year of last test (YYYY)',
                  controller: viewModel.lastTestYearController,
                ),
                KenwellDropdownField<String>(
                  label: 'What was the result of your last test?',
                  value: viewModel.lastTestResult,
                  items: const ['Positive', 'Negative'],
                  onChanged: viewModel.setLastTestResult,
                ),
            ],
            const Divider(height: 32),
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
                    'Have you been diagnosed and/or treated for a sexually transmitted infection during the last 12 months?',
                value: viewModel.treatedSTI,
                onChanged: viewModel.setTreatedSTI,
                yesValue: 'Yes',
                noValue: 'No',
              ),
              KenwellYesNoQuestion<String>(
                question:
                    'Have you been diagnosed and/or treated for TB during the last 12 months?',
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
            if (viewModel.noCondomUse == 'Yes') ...[
                KenwellTextField(
                  label: 'If yes, why do you sometimes not use a condom?',
                  controller: viewModel.noCondomReasonController,
                ),
            ],
            const Divider(height: 32),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRiskReason(viewModel, 'Partner has been unfaithful'),
            _buildRiskReason(viewModel,
                'Exposed to another person’s body fluids while assisting with an injury'),
            _buildRiskReason(viewModel,
                'A partner who had a sexually transmitted infection'),
            _buildRiskReason(viewModel,
                'A partner who injects drugs and shares needles with other people'),
            _buildRiskReason(viewModel, 'Rape'),
            _buildRiskReason(viewModel, 'Other (specify below)'),
              KenwellTextField(
                label: 'If other, specify',
                controller: viewModel.otherRiskReasonController,
              ),
            const SizedBox(height: 20),
              KenwellFormNavigation(
                onPrevious: onPrevious,
                onNext: () => viewModel.submitHIVTest(onNext),
                isNextEnabled: viewModel.isFormValid && !viewModel.isSubmitting,
                isNextBusy: viewModel.isSubmitting,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskReason(HIVTestViewModel vm, String label) {
    return CheckboxListTile(
      title: Text(label),
      value: vm.riskReasons.contains(label),
      onChanged: (_) => vm.toggleRiskReason(label),
    );
  }
}
