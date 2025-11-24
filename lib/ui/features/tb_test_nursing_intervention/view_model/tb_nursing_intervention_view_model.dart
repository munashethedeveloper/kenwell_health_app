import 'package:flutter/material.dart';
import '../../nurse_interventions/view_model/nurse_intervention_form_mixin.dart';

class TBNursingInterventionViewModel extends ChangeNotifier
    with NurseInterventionFormMixin {
  @override
  bool get showInitialAssessment => false;

  @override
  void dispose() {
    disposeNurseInterventionFields();
    super.dispose();
  }
}
