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
import '../../tb_test_nursing_intervention/widgets/tb_nursing_intervention_screen.dart';

// ViewModel
import '../view_model/wellness_flow_view_model.dart';
import '../../event/view_model/event_view_model.dart';
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
          child: event != null
              ? ConsentScreen(
                  event: event!,
                  onNext: flowVM.nextStep,
                  onCancel: () {
                    flowVM.cancelFlow();
                    onExitFlow();
                  },
                )
              : const SizedBox(),
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
        if (event != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flowVM.nurseVM.initialiseWithEvent(event!);
          });
        }
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
        if (event != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flowVM.hivNurseVM.initialiseWithEvent(event!);
          });
        }
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
        if (event != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flowVM.tbNurseVM.initialiseWithEvent(event!);
          });
        }
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
              final active = flowVM.activeEvent;
              if (active != null) {
                await context.read<EventViewModel>().incrementScreened(active.id);
              }
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
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
            endTime: event!.endTime,
            expectedCount: event!.expectedParticipation,
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
  final String? endTime;
  final int? expectedCount;
  final String venue;

  const _ActiveEventBanner({
    required this.title,
    required this.date,
    required this.startTime,
    required this.venue,
    required this.endTime,
    required this.expectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(date);

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
            "Current Stats for $title event:",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Date: $formattedDate",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
              Expanded(
                child: Text(
                  "Start-Time: $startTime",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: endTime != null && endTime!.isNotEmpty
                    ? Text(
                        "End-Time: $endTime",
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9)),
                        textAlign: TextAlign.right,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (expectedCount != null)
            Text(
              "Expected: $expectedCount participants",
              style: const TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
