import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nurse_intervention_form.dart';
import '../view_model/nurse_intervention_view_model.dart';

class NurseInterventionScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const NurseInterventionScreen({
    super.key,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NurseInterventionViewModel>();

    return NurseInterventionForm(
      viewModel: viewModel,
      title: 'Health Risk Assessment Nurse Intervention',
      sectionTitle: 'Section E: HRA - Nurse Intervention',
      onNext: onNext,
      onPrevious: onPrevious,
    );
  }
}
