import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nurse_interventions/widgets/nurse_intervention_form.dart';
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

    return NurseInterventionForm(
      viewModel: viewModel,
      title: 'TB Test Nursing Intervention',
      sectionTitle: 'Section J: TB - Nurse Intervention',
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }
}
