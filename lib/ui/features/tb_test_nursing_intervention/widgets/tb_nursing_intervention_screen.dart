import 'package:flutter/material.dart';

import '../../nurse_interventions/widgets/nurse_intervention_screen.dart';

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
    return NurseInterventionScreen(
      onNext: onNext,
      onPrevious: onPrevious,
      title: 'TB Test Nursing Intervention',
      sectionTitle: 'Section J: TB - Nurse Intervention',
    );
  }
}
