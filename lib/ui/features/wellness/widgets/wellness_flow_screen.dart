// SAFER submit handler: shows modal progress indicator, logs steps, avoids awaiting potentially
// slow persistence when closing the flow so the UI doesn't freeze.
// Replace the existing file at this path with the contents below (or merge the onSubmit part).

import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/patient/widgets/personal_details_screen.dart';
import 'package:provider/provider.dart';
import '../../event/view_model/event_view_model.dart';
import '../../hiv_test_nursing_intervention/widgets/hiv_test_nursing_intervention_screen.dart';
import '../../hiv_test_results/widgets/hiv_test_result_screen.dart';
import '../../nurse_interventions/widgets/nurse_intervention_screen.dart';
import '../../tb_test_nursing_intervention/widgets/tb_nursing_intervention_screen.dart';
import '../view_model/wellness_flow_view_model.dart';
import '../../survey/widgets/survey_screen.dart';
import '../../consent_form/widgets/consent_screen.dart';
import '../../risk_assessment/widgets/personal_risk_assessment_screen.dart';
import '../../screening_results/widgets/wellness_screening_results_screen.dart';
import '../../hiv_test/widgets/hiv_test_screen.dart';
import '../../tb_test/widgets/tb_testing_screen.dart';

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
          age: flowVM.personalVM.userAge,
        );
        break;

      case 3:
        currentScreen = WellnessScreeningResultsScreen(
          onNext: flowVM.nextStep,
          onPrevious: flowVM.previousStep,
          viewModel: flowVM.resultsVM,
          nurseViewModel: flowVM.nurseVM,
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
            nurseViewModel: flowVM.nurseVM,
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
        // SURVEY STEP: submitAll -> increment screened -> POP flow (do NOT call onFlowCompleted)
        currentScreen = ChangeNotifierProvider.value(
          value: flowVM.surveyVM,
          child: SurveyScreen(
            onPrevious: flowVM.previousStep,
            onSubmit: () async {
              debugPrint('WellnessFlow: survey onSubmit started');

              // Show a modal progress indicator to prevent UI interactions while submitting.
              if (context.mounted) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // 1) submit all flow data (existing behavior) — protect with try/catch
              try {
                debugPrint('WellnessFlow: calling flowVM.submitAll');
                await flowVM.submitAll(context);
                debugPrint('WellnessFlow: submitAll completed');
              } catch (e, st) {
                debugPrint('WellnessFlow: Error in submitAll: $e\n$st');
                if (context.mounted) {
                  // Close progress dialog if open
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit data: $e')),
                  );
                }
                return;
              }

              // 2) increment the screened counter for the active event and persist
              final active = flowVM.activeEvent;
              if (active != null) {
                try {
                  // Fire-and-forget the increment so the UI can return immediately.
                  // We do it in an unawaited microtask so any heavy persistence won't block the pop.
                  final eventVM =
                      Provider.of<EventViewModel>(context, listen: false);
                  Future.microtask(() async {
                    try {
                      debugPrint(
                          'WellnessFlow: incrementScreened (background) for ${active.id}');
                      await eventVM.incrementScreened(active.id);
                      debugPrint(
                          'WellnessFlow: incrementScreened done for ${active.id}');
                    } catch (e, st) {
                      debugPrint(
                          'WellnessFlow: incrementScreened failed: $e\n$st');
                    }
                  });
                } catch (e, st) {
                  debugPrint(
                      'WellnessFlow: Failed triggering incrementScreened: $e\n$st');
                }
              } else {
                debugPrint(
                    'WellnessFlow: activeEvent is null; skipping incrementScreened');
              }

              // 3) Pop the progress dialog (if still open) and then pop the flow page
              if (context.mounted) {
                // Close progress dialog
                Navigator.of(context).pop();
                // Pop the WellnessFlowPage to return to ConductEventScreen
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }

              debugPrint(
                  'WellnessFlow: survey onSubmit finished (page popped)');
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

    return Scaffold(
      body: SafeArea(child: flowContent),
    );
  }
}
