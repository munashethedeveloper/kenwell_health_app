import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/consent_form/view_model/consent_view_model.dart';

// Import all view models
import '../../hct_test_results/view_model/hct_test_result_view_model.dart';
import '../../nurse_interventions/view_model/nurse_intervention_view_model.dart';
import '../../member/view_model/member_registration_view_model.dart';
import '../../health_risk_assessment/view_model/health_risk_assessment_view_model.dart';
import '../../health_metrics/view_model/health_metrics_view_model.dart';
import '../../hct_test/view_model/hct_test_view_model.dart';
import '../../survey/view_model/survey_view_model.dart';
import '../../tb_test/view_model/tb_testing_view_model.dart';
import '../../cancer/view_model/cancer_view_model.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/constants/enums.dart';
import '../../../../data/repositories_dcl/firestore_consent_repository.dart';
import '../../../../data/repositories_dcl/firestore_hra_repository.dart';
import '../../../../data/repositories_dcl/firestore_hct_screening_repository.dart';
import '../../../../data/repositories_dcl/firestore_tb_screening_repository.dart';
import '../../../../data/repositories_dcl/firestore_cancer_screening_repository.dart';
import '../../../../data/repositories_dcl/firestore_survey_repository.dart';
import '../../../../domain/usecases/load_wellness_completion_status_usecase.dart';

class WellnessFlowViewModel extends ChangeNotifier {
  WellnessFlowViewModel({
    this.activeEvent,
    FirestoreConsentRepository? consentRepository,
    FirestoreHraRepository? hraRepository,
    FirestoreHctScreeningRepository? hctRepository,
    FirestoreTbScreeningRepository? tbRepository,
    FirestoreCancerScreeningRepository? cancerRepository,
    FirestoreSurveyRepository? surveyRepository,
    LoadWellnessCompletionStatusUseCase? completionStatusUseCase,
  })  : _consentRepo = consentRepository ?? FirestoreConsentRepository(),
        _hraRepo = hraRepository ?? FirestoreHraRepository(),
        _hctRepo = hctRepository ?? FirestoreHctScreeningRepository(),
        _tbRepo = tbRepository ?? FirestoreTbScreeningRepository(),
        _cancerRepo = cancerRepository ?? FirestoreCancerScreeningRepository(),
        _surveyRepo = surveyRepository ?? const FirestoreSurveyRepository() {
    _flowSteps = [stepMemberRegistration];
    _completionStatusUseCase = completionStatusUseCase ??
        LoadWellnessCompletionStatusUseCase(
          consentRepository: _consentRepo,
          hraRepository: _hraRepo,
          hctRepository: _hctRepo,
          tbRepository: _tbRepo,
          cancerRepository: _cancerRepo,
          surveyRepository: _surveyRepo,
        );
  }

  // ── Repository dependencies ────────────────────────────────────────────────
  final FirestoreConsentRepository _consentRepo;
  final FirestoreHraRepository _hraRepo;
  final FirestoreHctScreeningRepository _hctRepo;
  final FirestoreTbScreeningRepository _tbRepo;
  final FirestoreCancerScreeningRepository _cancerRepo;
  final FirestoreSurveyRepository _surveyRepo;
  late final LoadWellnessCompletionStatusUseCase _completionStatusUseCase;

  // Consent flags for screenings
  bool hraEnabled = false;
  bool hctEnabled = false;
  bool tbEnabled = false;
  bool cancerEnabled = false;

  // Healthcare-practitioner details from the consent form.
  // These are stored here after consent submission so that health-screening
  // navigators can pre-fill SANC, rank, and the HP signature automatically.
  String? consentSancNumber;
  String? consentRank;
  String? consentHpSignatureBase64;

  /// Loads all completion flags (consent, HRA, HCT, TB, Cancer, survey) for
  /// the given member and event from Firestore.
  ///
  /// ## Sequencing
  /// 1. **Consent** — determines which screenings were enabled (HRA/HCT/TB/Cancer).
  ///    The enabled flags are restored from the persisted consent record so that
  ///    a screen refresh and a first load both show the same state.
  /// 2. **Individual screenings** — each queried independently; a failure in
  ///    one does not prevent the others from loading.
  /// 3. **screeningsCompleted/screeningsInProgress** — derived from whether
  ///    *all consented* screenings have data.  Screenings not covered by
  ///    consent are ignored.
  /// 4. **Survey** — loaded last; independent of screening status.
  ///
  /// All flags are reset at the start of every call so stale values from a
  /// previous member never leak when the same [WellnessFlowViewModel] is
  /// reused across members.
  Future<void> loadAllCompletionFlags(String? memberId, String? eventId) async {
    if (memberId == null || eventId == null) return;

    // Reset all flags (including enabled flags so stale values from a previous
    // member don't leak when the same WellnessFlowViewModel is reused)
    consentCompleted = false;
    hraEnabled = false;
    hctEnabled = false;
    tbEnabled = false;
    cancerEnabled = false;
    hraCompleted = false;
    hctCompleted = false;
    tbCompleted = false;
    cancerCompleted = false;
    screeningsCompleted = false;
    screeningsInProgress = false;
    surveyCompleted = false;
    consentSancNumber = null;
    consentRank = null;
    consentHpSignatureBase64 = null;

    // Delegate all Firestore status-checking to the use case, which runs
    // the remaining 5 collections in parallel for better performance.
    final status = await _completionStatusUseCase(
      memberId: memberId,
      eventId: eventId,
    );

    // Apply the result to instance state.
    consentCompleted = status.consentCompleted;
    hraEnabled = status.hraEnabled;
    hctEnabled = status.hctEnabled;
    tbEnabled = status.tbEnabled;
    cancerEnabled = status.cancerEnabled;
    hraCompleted = status.hraCompleted;
    hctCompleted = status.hctCompleted;
    tbCompleted = status.tbCompleted;
    cancerCompleted = status.cancerCompleted;
    surveyCompleted = status.surveyCompleted;
    consentSancNumber = status.consentSancNumber;
    consentRank = status.consentRank;
    consentHpSignatureBase64 = status.consentHpSignatureBase64;

    // Determine screeningsCompleted / screeningsInProgress based on which
    // screenings were consented to (now correctly loaded from Firestore above).
    final anyEnabled = hraEnabled || hctEnabled || tbEnabled || cancerEnabled;
    final anyCompleted =
        hraCompleted || hctCompleted || tbCompleted || cancerCompleted;
    if (anyEnabled) {
      final allConsentedScreeningsCompleted = (!hraEnabled || hraCompleted) &&
          (!hctEnabled || hctCompleted) &&
          (!tbEnabled || tbCompleted) &&
          (!cancerEnabled || cancerCompleted);
      if (allConsentedScreeningsCompleted) {
        screeningsCompleted = true;
        screeningsInProgress = false;
      } else if (anyCompleted) {
        // At least one screening done but not all — show as "In Progress"
        screeningsCompleted = false;
        screeningsInProgress = true;
      } else {
        // Consent done, screenings enabled, but none started yet
        screeningsCompleted = false;
        screeningsInProgress = false;
      }
    } else {
      // No consent found (or no screenings selected): leave as Not Completed.
      screeningsCompleted = false;
      screeningsInProgress = false;
    }

    notifyListeners();
  }

  // Step name constants
  static const String stepMemberRegistration = 'member_registration';
  static const String stepCurrentEventDetails = 'current_event_details';
  static const String stepConsent = 'consent';
  static const String stepHealthScreeningsMenu = 'health_screenings_menu';
  static const String stepPersonalDetails = 'personal_details';
  static const String stepRiskAssessment = 'risk_assessment';
  static const String stepHctTest = 'hct_test';
  static const String stepHctResults = 'hct_results';
  static const String stepTbTest = 'tb_test';
  static const String stepCancerScreening = 'cancer_screening';
  static const String stepSurvey = 'survey';

  // Section identifiers (used by UI cards to identify which section was tapped)
  static const String sectionConsent = 'consent';
  static const String sectionMemberRegistration = 'member_registration';
  static const String sectionHealthScreenings = 'health_screenings';
  static const String sectionSurvey = 'survey';

  // ── Wellness flow progress ─────────────────────────────────────────────────

  /// Total number of sections in the wellness flow.
  static const int totalWellnessSections = 4;

  /// Number of completed sections for the current member.
  int get completedSectionsCount => [
        memberRegistrationCompleted,
        consentCompleted,
        screeningsCompleted,
        surveyCompleted,
      ].where((c) => c).length;

  /// Progress value in [0.0, 1.0] for the current member's wellness flow.
  double get wellnessProgressValue =>
      completedSectionsCount / totalWellnessSections;

  // Screening steps (used for detecting screening flows)
  // Derived from ScreeningType enum to ensure consistency with screening type definitions
  static List<String> get screeningSteps => ScreeningType.values.labels;

  // ViewModels for each step
  final consentVM = ConsentScreenViewModel();
  final memberDetailsVM = MemberDetailsViewModel();
  final riskVM = PersonalRiskAssessmentViewModel();
  final healthMetricsVM = HealthMetricsViewModel();
  final nurseVM = NurseInterventionViewModel();
  final hctTestVM = HCTTestViewModel();
  final hctResultsVM = HCTTestResultViewModel();
  final tbTestVM = TBTestingViewModel();
  final cancerVM = CancerScreeningViewModel();
  final surveyVM = SurveyViewModel();

  WellnessEvent? activeEvent;
  Member? currentMember;

  // Track completion status for different sections
  bool consentCompleted = false;
  bool memberRegistrationCompleted = false;
  bool screeningsCompleted = false;
  bool screeningsInProgress = false;
  bool surveyCompleted = false;

  // Track individual screening completions
  bool hraCompleted = false;
  bool hctCompleted = false;
  bool tbCompleted = false;
  bool cancerCompleted = false;

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

    // Add HCT screens if selected (VCT and HCT are the same)
    if (selectedScreenings.contains('hct')) {
      _flowSteps.addAll([stepHctTest, stepHctResults]);
    }

    // Add TB screens if selected
    if (selectedScreenings.contains('tb')) {
      _flowSteps.add(stepTbTest);
    }

    // Add Cancer screening if selected
    if (selectedScreenings.contains('cancer')) {
      _flowSteps.add(stepCancerScreening);
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

  /// Cancels the current flow and returns to the member registration step.
  ///
  /// This is a lightweight cancel that does not clear completion flags.
  /// For a full reset (e.g. when moving to a new member), use [resetFlow].
  void cancelFlow() {
    _currentStep = 0;
    _flowSteps = [stepMemberRegistration];
    notifyListeners();
  }

  /// Resets the flow to member search and clears the current member.
  ///
  /// Also clears the enabled-screening flags so a stale consent from a
  /// previous member does not leak to the next one.  Delegates full state
  /// reset to [resetFlow].
  void resetToMemberSearch() => resetFlow();

  Future<void> submitAll({void Function(String)? onSuccess}) async {
    // Collect all data from ViewModels for debug logging
    final consentData = consentVM.toMap();
    final memberData = memberDetailsVM.toMap();
    final riskData = riskVM.toMap();
    final hctTestData = hctTestVM.toMap();
    final hctResultsData = await hctResultsVM.toMap();
    final tbTestData = await tbTestVM.toMap();
    final surveyData = surveyVM.toMap();

    debugPrint('Submitting full wellness flow data...');
    debugPrint('Consent: $consentData');
    debugPrint('Member: $memberData');
    debugPrint('Risk: $riskData');
    debugPrint('HCT Test: $hctTestData');
    debugPrint('HCT Results: $hctResultsData');
    debugPrint('TB Test: $tbTestData');
    debugPrint('Survey: $surveyData');

    await Future.delayed(const Duration(seconds: 2));

    onSuccess?.call('All data submitted successfully!');

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
    screeningsInProgress = false;
    surveyCompleted = false;
    hraEnabled = false;
    hctEnabled = false;
    tbEnabled = false;
    cancerEnabled = false;
    hraCompleted = false;
    hctCompleted = false;
    tbCompleted = false;
    cancerCompleted = false;
    notifyListeners();
  }

  /// Set the current member
  void setCurrentMember(Member member) {
    currentMember = member;
    memberRegistrationCompleted = true;
    notifyListeners();
  }

  /// Mark consent as completed
  void markConsentCompleted() {
    consentCompleted = true;
    notifyListeners();
  }

  /// Mark screenings as in progress
  void markScreeningsInProgress() {
    screeningsInProgress = true;
    notifyListeners();
  }

  /// Mark screenings as completed
  void markScreeningsCompleted() {
    screeningsCompleted = true;
    screeningsInProgress = false;
    notifyListeners();
  }

  /// Mark survey as completed
  void markSurveyCompleted() {
    surveyCompleted = true;
    notifyListeners();
  }

  /// Mark HRA screening as completed
  void markHraCompleted() {
    hraCompleted = true;
    notifyListeners();
  }

  /// Mark HCT screening as completed
  void markHctCompleted() {
    hctCompleted = true;
    notifyListeners();
  }

  /// Mark TB screening as completed
  void markTbCompleted() {
    tbCompleted = true;
    notifyListeners();
  }

  /// Mark Cancer screening as completed
  void markCancerCompleted() {
    cancerCompleted = true;
    notifyListeners();
  }

  /// Navigate to current event details screen after member registration
  void navigateToEventDetails() {
    _flowSteps = [stepMemberRegistration, stepCurrentEventDetails];
    _currentStep = 1;
    notifyListeners();
  }

  /// Navigate to a specific section from the current event details screen.
  ///
  /// The flow steps are rebuilt from scratch each time so the "back" button
  /// always returns to the correct previous screen.
  ///
  /// | section                  | Navigates to                                     |
  /// |--------------------------|--------------------------------------------------|
  /// | sectionConsent           | Consent screen                                   |
  /// | sectionMemberRegistration| Back to member search (step 0)                   |
  /// | sectionHealthScreenings  | Health screenings menu *if* consent done, else   |
  /// |                          | consent screen (to complete consent first)        |
  /// | sectionSurvey            | Survey screen                                    |
  void navigateToSection(String section) {
    switch (section) {
      case sectionConsent:
        _flowSteps = [
          stepMemberRegistration,
          stepCurrentEventDetails,
          stepConsent
        ];
        _currentStep = 2;
        break;
      case sectionMemberRegistration:
        _flowSteps = [stepMemberRegistration];
        _currentStep = 0;
        break;
      case sectionHealthScreenings:
        // Navigate to health screenings menu if consent is completed
        if (consentCompleted &&
            (hraEnabled || hctEnabled || tbEnabled || cancerEnabled)) {
          _flowSteps = [
            stepMemberRegistration,
            stepCurrentEventDetails,
            stepHealthScreeningsMenu
          ];
          _currentStep = 2;
        } else {
          // If no consent yet, go to consent screen first
          _flowSteps = [
            stepMemberRegistration,
            stepCurrentEventDetails,
            stepConsent
          ];
          _currentStep = 2;
        }
        break;
      case sectionSurvey:
        _flowSteps = [
          stepMemberRegistration,
          stepCurrentEventDetails,
          stepSurvey
        ];
        _currentStep = 2;
        break;
    }
    notifyListeners();
  }

  /// Navigate from member registration to personal details
  /// This allows users to create a new member or proceed after selecting a member from search
  void navigateToPersonalDetails(String searchQuery) {
    // Pre-populate ID/Passport field if search query exists
    if (searchQuery.isNotEmpty) {
      if (searchQuery.length == 13 && int.tryParse(searchQuery) != null) {
        // SA ID Number
        memberDetailsVM.setIdDocumentChoice('ID');
        memberDetailsVM.idNumberController.text = searchQuery;
      } else {
        // Passport
        memberDetailsVM.setIdDocumentChoice('Passport');
        memberDetailsVM.passportNumberController.text = searchQuery;
      }
    }

    _flowSteps = [stepMemberRegistration, stepPersonalDetails];
    _currentStep = 1;
    notifyListeners();
  }

  /// Navigate to HRA screening from health screenings menu
  void navigateToHraScreening() {
    _flowSteps = [
      stepMemberRegistration,
      stepCurrentEventDetails,
      stepHealthScreeningsMenu,
      stepRiskAssessment,
    ];
    _currentStep = 3; // Go directly to risk assessment
    notifyListeners();
  }

  /// Navigate to HCT screening from health screenings menu
  void navigateToHctScreening() {
    _flowSteps = [
      stepMemberRegistration,
      stepCurrentEventDetails,
      stepHealthScreeningsMenu,
      stepHctTest,
      stepHctResults,
    ];
    _currentStep = 3; // Go directly to HCT test
    notifyListeners();
  }

  /// Navigate to TB screening from health screenings menu
  void navigateToTbScreening() {
    _flowSteps = [
      stepMemberRegistration,
      stepCurrentEventDetails,
      stepHealthScreeningsMenu,
      stepTbTest,
    ];
    _currentStep = 3; // Go directly to TB test
    notifyListeners();
  }

  /// Navigate to Cancer screening from health screenings menu
  void navigateToCancerScreening() {
    _flowSteps = [
      stepMemberRegistration,
      stepCurrentEventDetails,
      stepHealthScreeningsMenu,
      stepCancerScreening,
    ];
    _currentStep = 3; // Go directly to cancer screening
    notifyListeners();
  }

  /// Check if the current survey is standalone (accessed directly) or part of a screening flow
  /// A survey is standalone if:
  /// 1. The flow only has member_registration, current_event_details and survey (direct access)
  /// 2. The flow doesn't contain any screening steps: stepRiskAssessment, stepHctTest,
  ///    stepHctResults, stepTbTest, or stepCancerScreening
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

  /// Check if consent exists for this member and event
  Future<void> checkConsentCompletion(String? memberId, String? eventId) async {
    if (memberId == null || eventId == null) return;

    try {
      final consents = await _consentRepo.getConsentsByMember(memberId);

      // Check if any consent exists for this event
      final hasConsent = consents.any((consent) => consent.eventId == eventId);

      if (hasConsent) {
        consentCompleted = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking consent completion: $e');
    }
  }
}
