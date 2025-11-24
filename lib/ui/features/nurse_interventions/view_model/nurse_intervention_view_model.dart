import 'package:flutter/material.dart';
import 'nurse_intervention_form_mixin.dart';

class NurseInterventionViewModel extends ChangeNotifier
    with NurseInterventionFormMixin {
  @override
  bool get showInitialAssessment => false;

  @override
  void dispose() {
    disposeNurseInterventionFields();
    super.dispose();
  }
}
