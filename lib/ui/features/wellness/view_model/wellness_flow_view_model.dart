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
import '../../../../domain/models/member.dart';

class WellnessFlowViewModel extends ChangeNotifier {
  // Step name constants
  static const String stepMemberRegistration = 'member_registration';
  static const String stepCurrentEventDetails = 'current_event_details';
  static const String stepConsent = 'consent';
  static const String stepPersonalDetails = 'personal_details';
  static const String stepRiskAssessment = 'risk_assessment';
  static const String stepHivTest = 'hiv_test';
  static const String stepHivResults = 'hiv_results';
  static const String stepTbTest = 'tb_test';
  static const String stepSurvey = 'survey';

  // Section identifiers (used by UI cards to identify which section was tapped)
  static const String sectionConsent = 'consent';
  static const String sectionMemberRegistration = 'member_registration';
  static const String sectionHealthScreenings = 'health_screenings';
  static const String sectionSurvey = 'survey';

  // Screening steps (used for detecting screening flows)
  static const List<String> screeningSteps = [
    stepConsent,
    stepRiskAssessment,
    stepHivTest,
    stepHivResults,
    stepTbTest,
  ];

  WellnessFlowViewModel({this.activeEvent}) {
    // Initialize with member registration as the first step
    _flowSteps = [stepMemberRegistration];
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
  Member? currentMember;

  // Track completion status for different sections
  bool consentCompleted = false;
  bool memberRegistrationCompleted = false;
  bool screeningsCompleted = false;
  bool surveyCompleted = false;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Dynamic flow based on selected checkboxes
  List<String> _flowSteps = [stepMemberRegistration];
  List<String> get flowSteps => _flowSteps;

  // Initialize flow based on consent selections
  void initializeFlow(List<String> selectedScreenings) {
    // Preserve member registration and consent as the first steps
    _flowSteps = [stepMemberRegistration, stepConsent];

    // Add the personal details screen as the first screen if any screening is selected
    if (selectedScreenings.isNotEmpty) {
      _flowSteps.add(stepPersonalDetails);
    }

    // Add HRA screens if selected
    if (selectedScreenings.contains('hra')) {
      _flowSteps.addAll([stepRiskAssessment]);
    }

    // Add HIV/VCT screens if selected (VCT and HIV are the same)
    if (selectedScreenings.contains('hiv')) {
      _flowSteps.addAll([stepHivTest, stepHivResults]);
    }

    // Add TB screens if selected
    if (selectedScreenings.contains('tb')) {
      _flowSteps.add(stepTbTest);
    }

    // Survey is always included at the end
    _flowSteps.add(stepSurvey);

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
    _flowSteps = [stepMemberRegistration]; // Reset flow to initial state
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
    _flowSteps = [stepCurrentEventDetails]; // Reset flow after submission
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

  /// Reset the flow to member registration screen (for reuse)
  void resetFlow() {
    _currentStep = 0;
    _flowSteps = [stepMemberRegistration]; // Reset flow to initial state
    currentMember = null;
    consentCompleted = false;
    memberRegistrationCompleted = false;
    screeningsCompleted = false;
    surveyCompleted = false;
    notifyListeners();
  }

  /// Set the current member
  void setCurrentMember(Member member) {
    currentMember = member;
    memberRegistrationCompleted = true;
    notifyListeners();
  }

  /// Navigate to current event details screen after member registration
  void navigateToEventDetails() {
    _flowSteps = [stepMemberRegistration, stepCurrentEventDetails];
    _currentStep = 1;
    notifyListeners();
  }

  /// Navigate to a specific section from the current event details screen
  void navigateToSection(String section) {
    switch (section) {
      case sectionConsent:
        _flowSteps = [stepMemberRegistration, stepCurrentEventDetails, stepConsent];
        _currentStep = 2;
        break;
      case sectionMemberRegistration:
        _flowSteps = [stepMemberRegistration];
        _currentStep = 0;
        break;
      case sectionHealthScreenings:
        // For health screenings, we show consent first to select which screenings
        _flowSteps = [stepMemberRegistration, stepCurrentEventDetails, stepConsent];
        _currentStep = 2;
        break;
      case sectionSurvey:
        _flowSteps = [stepMemberRegistration, stepCurrentEventDetails, stepSurvey];
        _currentStep = 2;
        break;
    }
    notifyListeners();
  }

  /// Navigate from member registration to personal details
  /// This allows users to create a new member or proceed after selecting a member from search
  void navigateToPersonalDetails() {
    _flowSteps = [
      stepMemberRegistration,
      stepPersonalDetails
    ];
    _currentStep = 1;
    notifyListeners();
  }

  /// Check if the current survey is standalone (accessed directly) or part of a screening flow
  /// A survey is standalone if:
  /// 1. The flow only has member_registration, current_event_details and survey (direct access)
  /// 2. The flow doesn't contain screening steps (consent, risk_assessment, hiv_test, tb_test)
  bool get isStandaloneSurvey {
    // Check for direct access: only member_registration, current_event_details and survey
    if (_flowSteps.length == 3 &&
        _flowSteps[0] == stepMemberRegistration &&
        _flowSteps[1] == stepCurrentEventDetails &&
        _flowSteps[2] == stepSurvey) {
      return true;
    }

    // Check if flow contains any screening steps
    final hasScreeningSteps =
        _flowSteps.any((step) => screeningSteps.contains(step));

    // If no screening steps, consider it standalone even if member registration was used
    return !hasScreeningSteps;
  }
}
