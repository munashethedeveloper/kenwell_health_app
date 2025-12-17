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
import '../../../../domain/models/wellness_event.dart';

class WellnessFlowViewModel extends ChangeNotifier {
  WellnessFlowViewModel({this.activeEvent}) {
    // Initialize with consent as the first step
    _flowSteps = ['consent'];
  }

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

  WellnessEvent? activeEvent;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Dynamic flow based on selected checkboxes
  List<String> _flowSteps = ['consent'];
  List<String> get flowSteps => _flowSteps;

  // Initialize flow based on consent selections
  void initializeFlow(List<String> selectedScreenings) {
    _flowSteps = ['consent'];

    // Add HRA screens if selected
    if (selectedScreenings.contains('hra')) {
      _flowSteps.addAll(['personal_details', 'risk_assessment', 'screening_results']);
    }

    // Add general nurse intervention if any screening is selected
    if (selectedScreenings.isNotEmpty) {
      _flowSteps.add('nurse_intervention');
    }

    // Add HIV/VCT screens if selected (VCT and HIV are the same)
    if (selectedScreenings.contains('hiv') || selectedScreenings.contains('vct')) {
      _flowSteps.addAll(['hiv_test', 'hiv_results', 'hiv_nurse_intervention']);
    }

    // Add TB screens if selected
    if (selectedScreenings.contains('tb')) {
      _flowSteps.addAll(['tb_test', 'tb_nurse_intervention']);
    }

    // Survey is always included at the end
    _flowSteps.add('survey');

    // Debug logging for development
    assert(() {
      debugPrint('Initialized flow with steps: $_flowSteps');
      return true;
    }());
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < _flowSteps.length - 1) {
      _currentStep++;
      // Debug logging for development
      assert(() {
        debugPrint('Moving to step $_currentStep: ${_flowSteps[_currentStep]}');
        return true;
      }());
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      // Debug logging for development
      assert(() {
        debugPrint('Moving back to step $_currentStep: ${_flowSteps[_currentStep]}');
        return true;
      }());
      notifyListeners();
    }
  }

  // Helper to check if current step is valid
  bool get _isValidCurrentStep =>
      _flowSteps.isNotEmpty && _currentStep >= 0 && _currentStep < _flowSteps.length;

  String get currentStepName => _isValidCurrentStep ? _flowSteps[_currentStep] : 'unknown';

  void cancelFlow() {
    _currentStep = 0;
    _flowSteps = ['consent']; // Reset flow to initial state
    notifyListeners();
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

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data submitted successfully!')),
    );

    _currentStep = 0;
    _flowSteps = ['consent']; // Reset flow after submission
    notifyListeners();
  }

  void setActiveEvent(WellnessEvent event) {
    activeEvent = event;
    notifyListeners();
  }

  /// Increment the screened count by 1
  void incrementScreenedCount() {
    if (activeEvent != null) {
      activeEvent = activeEvent!.copyWith(
        screenedCount: activeEvent!.screenedCount + 1,
      );
      notifyListeners();
    }
  }

  /// Reset the flow to consent screen (for reuse)
  void resetFlow() {
    _currentStep = 0;
    _flowSteps = ['consent']; // Reset flow to initial state
    notifyListeners();
  }

  /// Call when survey is submitted
  void submitSurvey(BuildContext context) {
    incrementScreenedCount();
    resetFlow();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Survey saved and submitted!')),
    );
  }
}
