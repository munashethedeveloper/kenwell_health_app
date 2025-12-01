import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nurse_interventions/widgets/nurse_intervention_form.dart';
import '../view_model/hiv_test_nursing_intervention_view_model.dart';
import '../../../../domain/models/wellness_event.dart';

class HIVTestNursingInterventionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final WellnessEvent? event;

  const HIVTestNursingInterventionScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestNursingInterventionViewModel>();

    // Initialise date from event if available
    if (event != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.initialiseWithEvent(event!);
      });
    }

    return NurseInterventionForm(
      viewModel: viewModel,
      title: 'HIV Test Nurse Intervention Form',
      sectionTitle: 'Section H: HIV - Nurse Intervention',
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }
}
