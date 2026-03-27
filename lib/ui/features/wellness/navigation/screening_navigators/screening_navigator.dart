import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/models/member.dart';
import '../../../../../domain/models/wellness_event.dart';
import '../../../../../domain/enums/service_type.dart';
import '../../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../health_risk_assessment/widgets/health_risk_assessment_screen.dart';
import '../../../health_risk_assessment/view_model/health_risk_assessment_view_model.dart';
import '../../../nurse_interventions/view_model/nurse_intervention_view_model.dart';
import '../../../hct_test/widgets/hct_test_screen.dart';
import '../../../hct_test/view_model/hct_test_view_model.dart';
import '../../../hct_test_results/widgets/hct_test_result_screen.dart';
import '../../../hct_test_results/view_model/hct_test_result_view_model.dart';
import '../../../tb_test/widgets/tb_testing_screen.dart';
import '../../../tb_test/view_model/tb_testing_view_model.dart';
import '../../../cancer/widgets/cancer_screen.dart';
import '../../../cancer/view_model/cancer_view_model.dart';
import '../../../survey/widgets/survey_screen.dart';
import '../../../survey/view_model/survey_view_model.dart';
import '../../view_model/wellness_flow_view_model.dart';

/// Contains the individual screening navigation methods extracted from
/// [WellnessNavigator] to keep that class focused on high-level flow control.
///
/// Each method pushes a single screening screen and returns [true] when the
/// user completes and submits the form, or [null]/[false] when they go back.
class ScreeningNavigator {
  ScreeningNavigator({
    required this.context,
    required this.event,
    this.wellnessVM,
  });

  final BuildContext context;
  final WellnessEvent event;

  /// Optional reference to the wellness-flow VM.  When set, SANC number, rank,
  /// and the HP signature from consent are automatically pre-filled into each
  /// health-screening nurse-details section.
  WellnessFlowViewModel? wellnessVM;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Pre-fills nurse controller fields and signature from consent HP data.
  void _applyConsentHpDetails({
    required TextEditingController sancController,
    required TextEditingController rankController,
    required void Function(String?) setPrefilledSignature,
  }) {
    final vm = wellnessVM;
    if (vm == null) return;
    if (vm.consentSancNumber != null && sancController.text.isEmpty) {
      sancController.text = vm.consentSancNumber!;
    }
    if (vm.consentRank != null && rankController.text.isEmpty) {
      rankController.text = vm.consentRank!;
    }
    setPrefilledSignature(vm.consentHpSignatureBase64);
  }

  // ── HRA ───────────────────────────────────────────────────────────────────

  /// Navigate to the HRA (Health Risk Assessment) screen.
  Future<bool?> navigateToHra(Member member) async {
    final riskVM = PersonalRiskAssessmentViewModel();
    final nurseVM = NurseInterventionViewModel();
    riskVM.setMemberAndEventId(member.id, event.id);
    nurseVM.initialiseWithEvent(event);
    _applyConsentHpDetails(
      sancController: nurseVM.sancNumberController,
      rankController: nurseVM.rankController,
      setPrefilledSignature: (v) => nurseVM.prefilledHpSignatureBase64 = v,
    );

    final age = _calculateAge(member.dateOfBirth);

    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: riskVM),
            ChangeNotifierProvider.value(value: nurseVM),
          ],
          child: PersonalRiskAssessmentScreen(
            onNext: () => Navigator.of(context).pop(true),
            onPrevious: () => Navigator.of(context).pop(),
            viewModel: riskVM,
            nurseViewModel: nurseVM,
            isFemale: member.gender?.toLowerCase() == 'female',
            age: age,
            appBar: _buildAppBar('Health Risk Assessment Form'),
          ),
        ),
      ),
    );
  }

  // ── HCT (two-step flow: test → results) ───────────────────────────────────

  /// Navigate to the HCT (HIV Counselling & Testing) two-step flow.
  Future<bool?> navigateToHctFlow(Member member) async {
    final hctTestVM = HCTTestViewModel();
    hctTestVM.setMemberAndEventId(member.id, event.id);

    final testCompleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: hctTestVM,
          child: HCTTestScreen(
            onNext: () => Navigator.of(context).pop(true),
            onPrevious: () => Navigator.of(context).pop(),
            appBar: _buildAppBar('HCT Form'),
          ),
        ),
      ),
    );

    if (testCompleted == true && context.mounted) {
      final hctResultsVM = HCTTestResultViewModel();
      hctResultsVM.initialiseWithEvent(event);
      hctResultsVM.setMemberAndEventId(member.id, event.id);
      _applyConsentHpDetails(
        sancController: hctResultsVM.sancNumberController,
        rankController: hctResultsVM.rankController,
        setPrefilledSignature: (v) =>
            hctResultsVM.prefilledHpSignatureBase64 = v,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: hctResultsVM,
            child: HCTTestResultScreen(
              onNext: () => Navigator.of(context).pop(true),
              onPrevious: () => Navigator.of(context).pop(),
              appBar: _buildAppBar('HCT Results Form'),
            ),
          ),
        ),
      );
      return true;
    }
    return testCompleted;
  }

  // ── TB ────────────────────────────────────────────────────────────────────

  /// Navigate to the TB screening screen.
  Future<bool?> navigateToTb(Member member) async {
    final tbTestVM = TBTestingViewModel();
    tbTestVM.initialiseWithEvent(event);
    tbTestVM.setMemberAndEventId(member.id, event.id);
    _applyConsentHpDetails(
      sancController: tbTestVM.sancNumberController,
      rankController: tbTestVM.rankController,
      setPrefilledSignature: (v) => tbTestVM.prefilledHpSignatureBase64 = v,
    );

    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: tbTestVM,
          child: TBTestingScreen(
            onNext: () => Navigator.of(context).pop(true),
            onPrevious: () => Navigator.of(context).pop(),
            appBar: _buildAppBar('TB Form'),
          ),
        ),
      ),
    );
  }

  // ── Cancer ────────────────────────────────────────────────────────────────

  /// Navigate to the Cancer screening screen.
  Future<bool?> navigateToCancer(Member member) async {
    final cancerVM = CancerScreeningViewModel();
    cancerVM.initialize();
    cancerVM.setMemberAndEventId(member.id, event.id);
    cancerVM.initialiseWithEvent(event);
    _applyConsentHpDetails(
      sancController: cancerVM.sancNumberController,
      rankController: cancerVM.rankController,
      setPrefilledSignature: (v) => cancerVM.prefilledHpSignatureBase64 = v,
    );

    // Determine which cancer sub-types were requested for this event.
    final allServices =
        ServiceTypeConverter.fromStorageString(event.servicesRequested);
    final cancerSubTypes = allServices
        .where((s) =>
            s == ServiceType.breastScreening ||
            s == ServiceType.papSmear ||
            s == ServiceType.psa)
        .map((s) => s.displayName)
        .toSet();
    cancerVM.setCancerSubTypes(cancerSubTypes);

    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: cancerVM,
          child: CancerScreen(
            onNext: () => Navigator.of(context).pop(true),
            onPrevious: () => Navigator.of(context).pop(),
            appBar: _buildAppBar('Cancer Screening Form'),
          ),
        ),
      ),
    );
  }

  // ── Survey ────────────────────────────────────────────────────────────────

  /// Navigate to the post-screening survey.
  Future<bool?> navigateToSurvey(Member member) async {
    final surveyVM = SurveyViewModel();
    surveyVM.setMemberAndEventId(member.id, event.id);

    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: surveyVM,
          child: SurveyScreen(
            onSubmit: () => Navigator.of(context).pop(true),
            onPrevious: () => Navigator.of(context).pop(),
            appBar: _buildAppBar('Survey Form'),
          ),
        ),
      ),
    );
  }

  KenwellAppBar _buildAppBar(String subtitle) {
    return KenwellAppBar(
      title: event.title,
      subtitle: subtitle,
      titleColor: Colors.white,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      backgroundColor: const Color(0xFF201C58),
    );
  }

  /// Calculate age in years from a date-of-birth string (ISO-8601).
  static int _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    final dob = DateTime.tryParse(dateOfBirth);
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
