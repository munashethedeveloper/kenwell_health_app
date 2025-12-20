import 'package:flutter/material.dart';

// Import all view models
import '../../consent_form/view_model/consent_screen_view_model.dart';
import '../../hiv_test_results/view_model/hiv_test_result_view_model.dart';
import '../../nurse_interventions/view_model/nurse_intervention_view_model.dart';
import '../../member/view_model/member_details_view_model.dart';
import '../../risk_assessment/view_model/personal_risk_assessment_view_model.dart';
import '../../health_metrics/view_model/health_metrics_view_model.dart';
import '../../hiv_test/view_model/hiv_test_view_model.dart';
import '../../survey/view_model/survey_view_model.dart';
import '../../tb_test/view_model/tb_testing_view_model.dart';
import '../../../../domain/models/wellness_event.dart';

class WellnessFlowViewModel extends ChangeNotifier {
  WellnessFlowViewModel({this.activeEvent}) {
    // Initialize with current event details as the first step
    _flowSteps = ['current_event_details'];
  }

  // ViewModels for each step
  final consentVM = ConsentScreenViewModel();
  final memberDetailsVM = MemberDetailsViewModel();
  final riskVM = PersonalRiskAssessmentViewModel();
  final healthMetricsVM = HealthMetricsViewModel();
  final nurseVM = NurseInterventionViewModel();
  final hivTestVM = HIVTestViewModel();
  final hivResultsVM = HIVTestResultViewModel();
  final tbTestVM = TBTestingViewModel();
  final surveyVM = SurveyViewModel();

  WellnessEvent? activeEvent;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Dynamic flow based on selected checkboxes
  List<String> _flowSteps = ['current_event_details'];
  List<String> get flowSteps => _flowSteps;

  // Initialize flow based on consent selections
  void initializeFlow(List<String> selectedScreenings) {
    // Preserve current_event_details and consent as the first steps
    _flowSteps = ['current_event_details', 'consent'];

    // Add the personal details screen as the first screen if any screening is selected
    if (selectedScreenings.isNotEmpty) {
      _flowSteps.add('personal_details');
    }

    // Add HRA screens if selected
    if (selectedScreenings.contains('hra')) {
      _flowSteps.addAll(['risk_assessment']);
    }

    // Add HIV/VCT screens if selected (VCT and HIV are the same)
    if (selectedScreenings.contains('hiv')) {
      _flowSteps.addAll(['hiv_test', 'hiv_results']);
    }

    // Add TB screens if selected
    if (selectedScreenings.contains('tb')) {
      _flowSteps.add('tb_test');
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
        debugPrint(
            'Moving back to step $_currentStep: ${_flowSteps[_currentStep]}');
        return true;
      }());
      notifyListeners();
    }
  }

  // Helper to check if current step is valid
  bool get _isValidCurrentStep =>
      _flowSteps.isNotEmpty &&
      _currentStep >= 0 &&
      _currentStep < _flowSteps.length;

  String get currentStepName =>
      _isValidCurrentStep ? _flowSteps[_currentStep] : 'unknown';

  void cancelFlow() {
    _currentStep = 0;
    _flowSteps = ['current_event_details']; // Reset flow to initial state
    notifyListeners();
  }

  Future<void> submitAll(BuildContext context) async {
    // Collect all data from ViewModels
    final consentData = consentVM.toMap();
    final memberData = memberDetailsVM.toMap();
    final riskData = riskVM.toMap();
    // final healthMetricsData = healthMetricsVM.toMap();
    //final nurseData = nurseVM.toMap();
    final hivTestData = hivTestVM.toMap();
    final hivResultsData = await hivResultsVM.toMap();
    final tbTestData = await tbTestVM.toMap();
    final surveyData = surveyVM.toMap();

    debugPrint('Submitting full wellness flow data...');
    debugPrint('Consent: $consentData');
    debugPrint('Member: $memberData');
    debugPrint('Risk: $riskData');
    //debugPrint('Health Metrics: $healthMetricsData');
    //debugPrint('Nurse Intervention: $nurseData');
    debugPrint('HIV Test: $hivTestData');
    debugPrint('HIV Results: $hivResultsData');
    debugPrint('TB Test: $tbTestData');
    debugPrint('Survey: $surveyData');

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data submitted successfully!')),
    );

    _currentStep = 0;
    _flowSteps = ['current_event_details']; // Reset flow after submission
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

  /// Reset the flow to current event details screen (for reuse)
  void resetFlow() {
    _currentStep = 0;
    _flowSteps = ['current_event_details']; // Reset flow to initial state
    notifyListeners();
  }

  /// Navigate to a specific section from the current event details screen
  void navigateToSection(String section) {
    switch (section) {
      case 'consent':
        _flowSteps = ['current_event_details', 'consent'];
        _currentStep = 1;
        break;
      case 'member_registration':
        _flowSteps = ['current_event_details', 'member_registration'];
        _currentStep = 1;
        break;
      case 'health_screenings':
        // For health screenings, we show consent first to select which screenings
        _flowSteps = ['current_event_details', 'consent'];
        _currentStep = 1;
        break;
      case 'survey':
        _flowSteps = ['current_event_details', 'survey'];
        _currentStep = 1;
        break;
    }
    notifyListeners();
  }

  /// Navigate from member registration to personal details
  /// This allows users to create a new member or proceed after selecting a member from search
  void navigateToPersonalDetails() {
    _flowSteps = ['current_event_details', 'member_registration', 'personal_details'];
    _currentStep = 2;
    notifyListeners();
  }

  /// Check if the current survey is standalone (accessed directly) or part of a screening flow
  /// A survey is standalone if:
  /// 1. The flow only has current_event_details and survey (direct access)
  /// 2. The flow doesn't contain screening steps (consent, risk_assessment, hiv_test, tb_test)
  bool get isStandaloneSurvey {
    // Check for direct access: only current_event_details and survey
    if (_flowSteps.length == 2 && 
        _flowSteps[0] == 'current_event_details' &&
        _flowSteps[1] == 'survey') {
      return true;
    }
    
    // Check if flow contains any screening steps
    const screeningSteps = ['consent', 'risk_assessment', 'hiv_test', 'hiv_results', 'tb_test'];
    final hasScreeningSteps = _flowSteps.any((step) => screeningSteps.contains(step));
    
    // If no screening steps, consider it standalone even if member registration was used
    return !hasScreeningSteps;
  }
}
