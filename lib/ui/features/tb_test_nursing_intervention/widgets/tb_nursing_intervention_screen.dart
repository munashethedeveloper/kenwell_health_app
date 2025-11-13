import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_checkbox_field.dart';
import '../../../shared/ui/form/custom_section_tile.dart';
import '../../../shared/ui/form/custom_text_field.dart';
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
    final vm = context.watch<TBNursingInterventionViewModel>();

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
            const KenwellSectionTitle('Referral Nursing Interventions'),
            const SizedBox(height: 16),

            // Member not referred
            KenwellCheckbox(
              title: 'Member not referred – reason?',
              value: vm.memberNotReferred,
              onChanged: (val) => vm.toggleField('memberNotReferred', val),
            ),
            if (vm.memberNotReferred)
              KenwellTextField(
                label: 'Enter reason',
                controller: vm.reasonController,
                maxLines: 2,
              ),

            // Other referral options
            KenwellCheckbox(
              title: 'Member referred to GP',
              value: vm.referredToGP,
              onChanged: (val) => vm.toggleField('referredToGP', val),
            ),
            KenwellCheckbox(
              title: 'Member referred to state HIV clinic',
              value: vm.referredToStateHIVClinic,
              onChanged: (val) =>
                  vm.toggleField('referredToStateHIVClinic', val),
            ),
            KenwellCheckbox(
              title: 'Member referred for OH consultation',
              value: vm.referredToOHConsultation,
              onChanged: (val) =>
                  vm.toggleField('referredToOHConsultation', val),
            ),

            const SizedBox(height: 20),
            const Text(
              'Please make the relevant notes of your session below:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            KenwellTextField(
              label: 'Enter session notes...',
              controller: vm.sessionNotesController,
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // Navigation Buttons
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () => vm.saveIntervention(onNext: onNext),
              isNextEnabled: !vm.isSubmitting,
              isNextBusy: vm.isSubmitting,
              previousLabel: 'Previous',
              nextLabel: 'Save and Submit',
            ),
          ],
        ),
      ),
    );
  }
}
