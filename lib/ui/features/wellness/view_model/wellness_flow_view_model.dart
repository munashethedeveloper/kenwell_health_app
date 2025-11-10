import 'package:flutter/material.dart';

// Import all view models
import '../../consent_form/view_model/consent_screen_view_model.dart';
import '../../hiv_test_nursing_intervention/view_model/hiv_test_nursing_intervention_view_model.dart';
import '../../hiv_test_results/view_model/hiv_test_result_view_model.dart';
import '../../nurse_interventions/view_model/nurse_intervention_view_model.dart';
import '../../patient/view_model/personal_details_view_model.dart';
import '../../risk_assessment/view_model/personal_risk_assessment_view_model.dart';
import '../../screening_results/view_model/wellness_screening_results_view_model.dart';
import '../../hiv_test/view_model/hiv_test_view_model.dart';
import '../../survey/view_model/survey_view_model.dart';
import '../../tb_test/view_model/tb_testing_view_model.dart';
import '../../tb_test_nursing_intervention/view_model/tb_nursing_intervention_view_model.dart';

class WellnessFlowViewModel extends ChangeNotifier {
  // ViewModels for each step
  final consentVM = ConsentScreenViewModel();
  final personalVM = PersonalDetailsViewModel();
  final riskVM = PersonalRiskAssessmentViewModel();
  final resultsVM = WellnessScreeningResultsViewModel();
  final nurseVM = NurseInterventionViewModel();
  final hivTestVM = HIVTestViewModel();
  final hivResultsVM = HIVTestResultViewModel();
  final hivNurseVM = HIVTestNursingInterventionViewModel();
  final tbTestVM = TBTestingViewModel();
  final tbNurseVM = TBNursingInterventionViewModel();
  final surveyVM = SurveyViewModel();

  int _currentStep = 0;
  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < 10) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void cancelFlow(BuildContext context) {
    _currentStep = 0;
    notifyListeners();
    Navigator.popUntil(context, (route) => route.settings.name == '/calendar');
  }

  Future<void> submitAll(BuildContext context) async {
    // Collect all data from ViewModels
    final consentData = consentVM.toMap();
    final personalData = personalVM.toMap();
    final riskData = riskVM.toMap();
    final resultsData = resultsVM.toMap();
    final nurseData = nurseVM.toMap();
    final hivTestData = hivTestVM.toMap();
    final hivResultsData = hivResultsVM.toMap();
    final hivNurseData = hivNurseVM.toMap();
    final tbTestData = tbTestVM.toMap();
    final tbNurseData = tbNurseVM.toMap();
    final surveyData = surveyVM.toMap();

    // Example: send to repository or print
    debugPrint('Submitting full wellness flow data...');
    debugPrint('Consent: $consentData');
    debugPrint('Personal: $personalData');
    debugPrint('Risk: $riskData');
    debugPrint('Results: $resultsData');
    debugPrint('Nurse Intervention: $nurseData');
    debugPrint('HIV Test: $hivTestData');
    debugPrint('HIV Results: $hivResultsData');
    debugPrint('HIV Nurse: $hivNurseData');
    debugPrint('TB Test: $tbTestData');
    debugPrint('TB Nurse: $tbNurseData');
    debugPrint('Survey: $surveyData');

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data submitted successfully!')),
    );

    _currentStep = 0;
    notifyListeners();
  }
}
