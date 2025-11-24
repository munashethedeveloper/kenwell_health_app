import 'package:flutter/material.dart';
import '../../nurse_interventions/view_model/nurse_intervention_form_mixin.dart';

class HIVTestNursingInterventionViewModel extends ChangeNotifier
    with NurseInterventionFormMixin {
  @override
  void dispose() {
    disposeNurseInterventionFields();
    super.dispose();
  }
}
