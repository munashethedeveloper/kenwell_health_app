import 'package:flutter/material.dart';

import '../../nurse_interventions/widgets/nurse_intervention_screen.dart';
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
    return NurseInterventionScreen<HIVTestNursingInterventionViewModel>(
      onNext: onNext,
      onPrevious: onPrevious,
      title: 'HIV Test Nursing Intervention',
      sectionTitle: 'Section H: HIV - Nurse Intervention',
      showInitialAssessment: true,
    );
  }
}
