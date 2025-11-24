import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nurse_interventions/widgets/nurse_intervention_form.dart';
import '../view_model/hiv_test_nursing_intervention_view_model.dart';

class HIVTestNursingInterventionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const HIVTestNursingInterventionScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestNursingInterventionViewModel>();

    return NurseInterventionForm(
      viewModel: viewModel,
      title: 'HIV Test Nursing Intervention',
      sectionTitle: 'Section H: HIV - Nurse Intervention',
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }
}
