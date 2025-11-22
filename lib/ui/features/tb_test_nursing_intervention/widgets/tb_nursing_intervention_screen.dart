import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/form/kenwell_signature_field.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/tb_nursing_intervention_view_model.dart';

class TBNursingInterventionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const TBNursingInterventionScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TBNursingInterventionViewModel>(context);

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'TB Test Nursing Intervention',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KenwellSectionHeader(
              title: 'Section J: TB Screening Nursing Interventions',
              uppercase: true,
            ),
            KenwellFormCard(
              title: 'Nursing Referrals',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<TBNursingReferralOption>(
                    title: const Text('Member not referred – reason?'),
                    value: TBNursingReferralOption.memberNotReferred,
                    groupValue: viewModel.selectedReferralOption,
                    onChanged: viewModel.setReferralOption,
                  ),
                  if (viewModel.selectedReferralOption ==
                      TBNursingReferralOption.memberNotReferred)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 12.0),
                      child: KenwellTextField(
                        label: 'Enter reason',
                        controller: viewModel.reasonController,
                        maxLines: 2,
                        decoration: KenwellFormStyles.decoration(
                          label: 'Enter reason',
                          hint: 'Provide additional detail',
                        ),
                      ),
                    ),
                  RadioListTile<TBNursingReferralOption>(
                    title: const Text('Member referred to GP'),
                    value: TBNursingReferralOption.referredToGP,
                    groupValue: viewModel.selectedReferralOption,
                    onChanged: viewModel.setReferralOption,
                  ),
                  RadioListTile<TBNursingReferralOption>(
                    title: const Text('Member referred to state HIV clinic'),
                    value: TBNursingReferralOption.referredToStateHIVClinic,
                    groupValue: viewModel.selectedReferralOption,
                    onChanged: viewModel.setReferralOption,
                  ),
                  RadioListTile<TBNursingReferralOption>(
                    title: const Text('Member referred for OH consultation'),
                    value: TBNursingReferralOption.referredToOHConsultation,
                    groupValue: viewModel.selectedReferralOption,
                    onChanged: viewModel.setReferralOption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            KenwellFormCard(
              title: 'Session Notes',
              child: KenwellTextField(
                label: 'Session notes',
                controller: viewModel.sessionNotesController,
                hintText: 'Enter session notes...',
                maxLines: 5,
                decoration: KenwellFormStyles.decoration(
                  label: 'Session notes',
                  hint: 'Enter session notes...',
                ),
              ),
            ),
            const SizedBox(height: 24),
            KenwellFormCard(
              //  title: 'Signature',
              child: KenwellSignatureField(
                controller: viewModel.signatureController,
                onClear: viewModel.clearSignature,
              ),
            ),
            const SizedBox(height: 24),
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () {
                if (!viewModel.hasSignature) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please capture a signature first.'),
                    ),
                  );
                  return;
                }
                viewModel.saveIntervention(onNext: onNext);
              },
              isNextEnabled: viewModel.hasSignature,
              nextLabel: 'Save and Submit',
            ),
          ],
        ),
      ),
    );
  }
}
