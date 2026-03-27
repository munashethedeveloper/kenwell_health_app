import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nurse_interventions/widgets/nurse_intervention_form.dart';
import '../view_model/hct_test_nursing_intervention_view_model.dart';
import '../../../../domain/models/wellness_event.dart';

class HCTTestNursingInterventionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final WellnessEvent? event;

  const HCTTestNursingInterventionScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HCTTestNursingInterventionViewModel>();

    // Initialise date from event if available
    if (event != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.initialiseWithEvent(event!);
      });
    }

    return NurseInterventionForm(
      viewModel: viewModel,
      title: 'HCT Test Nurse Intervention Form',
      sectionTitle: 'Section H: HCT - Nurse Intervention',
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }
}
