import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Screens
import '../../consent_form/widgets/consent_screen.dart';
import '../../hiv_test_nursing_intervention/widgets/hiv_test_nursing_intervention_screen.dart';
import '../../hiv_test_results/widgets/hiv_test_result_screen.dart';
import '../../nurse_interventions/widgets/nurse_intervention_screen.dart';
import '../../patient/widgets/personal_details_screen.dart';
import '../../risk_assessment/widgets/personal_risk_assessment_screen.dart';
import '../../screening_results/widgets/wellness_screening_results_screen.dart';
import '../../hiv_test/widgets/hiv_test_screen.dart';
import '../../survey/widgets/survey_screen.dart';
import '../../tb_test/widgets/tb_testing_screen.dart';

// ViewModel
import '../../tb_test_nursing_intervention/widgets/tb_nursing_intervention_screen.dart';
import '../view_model/wellness_flow_view_model.dart';
import '../../../../domain/models/wellness_event.dart';

class WellnessFlowScreen extends StatelessWidget {
  final VoidCallback onExitFlow;
  final VoidCallback? onFlowCompleted;
  final WellnessEvent? event;
  const WellnessFlowScreen({
    super.key,
    required this.onExitFlow,
    this.onFlowCompleted,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final flowVM = context.watch<WellnessFlowViewModel>();

    Widget currentScreen;

    switch (flowVM.currentStep) {
      case 0:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.consentVM,
          child: ConsentScreen(
            onNext: flowVM.nextStep,
            onCancel: () {
              flowVM.cancelFlow();
              onExitFlow();
            },
          ),
        );
        break;
      case 1:
        currentScreen = PersonalDetailsScreen(
          onNext: flowVM.nextStep,
          onPrevious: flowVM.previousStep,
          viewModel: flowVM.personalVM,
        );
        break;
      case 2:
        currentScreen = PersonalRiskAssessmentScreen(
          onNext: flowVM.nextStep,
          onPrevious: flowVM.previousStep,
          viewModel: flowVM.riskVM,
          isFemale: flowVM.personalVM.gender?.toLowerCase() == 'female',
        );
        break;
      case 3:
        currentScreen = WellnessScreeningResultsScreen(
          onNext: flowVM.nextStep,
          onPrevious: flowVM.previousStep,
          viewModel: flowVM.resultsVM,
        );
        break;
      case 4:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.nurseVM,
          child: NurseInterventionScreen(
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
          ),
        );
        break;
      case 5:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.hivTestVM,
          child: HIVTestScreen(
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
          ),
        );
        break;
      case 6:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.hivResultsVM,
          child: HIVTestResultScreen(
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
          ),
        );
        break;
      case 7:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.hivNurseVM,
          child: HIVTestNursingInterventionScreen(
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
          ),
        );
        break;
      case 8:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.tbTestVM,
          child: TBTestingScreen(
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
          ),
        );
        break;
      case 9:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.tbNurseVM,
          child: TBNursingInterventionScreen(
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
          ),
        );
        break;
      case 10:
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.surveyVM,
          child: SurveyScreen(
            onPrevious: flowVM.previousStep,
            onSubmit: () async {
              await flowVM.submitAll(context);
              onFlowCompleted?.call();
            },
          ),
        );
        break;
      default:
        currentScreen = const Center(child: Text('Invalid step'));
    }
    final flowContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey<int>(flowVM.currentStep),
        child: currentScreen,
      ),
    );
    return Column(
      children: [
        if (event != null)
          _ActiveEventBanner(
            title: event!.title,
            date: event!.date,
            startTime: event!.startTime,
            venue: event!.venue,
          ),
        Expanded(child: flowContent),
      ],
    );
  }
}

class _ActiveEventBanner extends StatelessWidget {
  final String title;
  final DateTime date;
  final String startTime;
  final String venue;

  const _ActiveEventBanner({
    required this.title,
    required this.date,
    required this.startTime,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      DateFormat.yMMMMd().format(date),
      if (startTime.isNotEmpty) startTime,
      if (venue.isNotEmpty) venue,
    ].where((element) => element.isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201C58),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
