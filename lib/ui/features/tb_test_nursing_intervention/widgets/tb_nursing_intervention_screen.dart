import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/form/kenwell_referral_card.dart';
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

    return KenwellFormPage(
      title: 'TB Test Nursing Intervention',
      sectionTitle: 'Section J: TB Screening Nursing Interventions',
      children: [
        KenwellReferralCard<TBNursingReferralOption>(
          title: 'Nursing Referrals',
          selectedValue: viewModel.selectedReferralOption,
          onChanged: viewModel.setReferralOption,
          reasonValidator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter a reason' : null,
          options: [
            KenwellReferralOption(
              value: TBNursingReferralOption.memberNotReferred,
              label: 'Member not referred – reason?',
              requiresReason: true,
              reasonController: viewModel.reasonController,
              reasonLabel: 'Enter reason',
              reasonMaxLines: 2,
            ),
            KenwellReferralOption(
              value: TBNursingReferralOption.referredToGP,
              label: 'Member referred to GP',
            ),
            KenwellReferralOption(
              value: TBNursingReferralOption.referredToStateHIVClinic,
              label: 'Member referred to state HIV clinic',
            ),
            KenwellReferralOption(
              value: TBNursingReferralOption.referredToOHConsultation,
              label: 'Member referred for OH consultation',
            ),
          ],
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
        KenwellSignatureActions(
          controller: viewModel.signatureController,
          onClear: viewModel.clearSignature,
          navigation: KenwellFormNavigation(
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
        ),
      ],
    );
  }
}
