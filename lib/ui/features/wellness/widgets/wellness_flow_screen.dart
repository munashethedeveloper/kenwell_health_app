import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/member/widgets/member_registration_screen.dart';
import 'package:kenwell_health_app/ui/features/wellness/widgets/current_event_home_screen.dart';
import 'package:kenwell_health_app/ui/features/wellness/widgets/member_search_screen.dart';
import 'package:kenwell_health_app/ui/features/wellness/widgets/health_screenings_screen.dart';
import 'package:provider/provider.dart';
import '../../cancer/widgets/cancer_screen.dart';
import '../../event/view_model/event_view_model.dart';
import '../../hiv_test_results/widgets/hiv_test_result_screen.dart';
import '../view_model/wellness_flow_view_model.dart';
import '../../survey/widgets/survey_screen.dart';
import '../../consent_form/widgets/consent_screen.dart';
import '../../health_risk_assessment/widgets/health_risk_assessment_screen.dart';
import '../../hiv_test/widgets/hiv_test_screen.dart';
import '../../tb_test/widgets/tb_testing_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

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

    // Get current screen based on flow step name
    Widget currentScreen = _buildScreenForStep(context, flowVM);

    final flowContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey<String>('flow_step_${flowVM.currentStepName}'),
        child: currentScreen,
      ),
    );

    return Scaffold(
      body: SafeArea(child: flowContent),
    );
  }

  Widget _buildScreenForStep(
      BuildContext context, WellnessFlowViewModel flowVM) {
    final stepName = flowVM.currentStepName;

    switch (stepName) {
      case WellnessFlowViewModel.stepCurrentEventDetails:
        return event != null
            ? CurrentEventHomeScreen(
                event: event!,
                onSectionTap: (section) {
                  flowVM.navigateToSection(section);
                },
                onBackToSearch: () => flowVM.resetToMemberSearch(),
              )
            : const SizedBox();

      case WellnessFlowViewModel.stepMemberRegistration:
        return MemberSearchScreen(
          onGoToMemberDetails: flowVM.navigateToPersonalDetails,
          onMemberFound: (member) {
            // Set the found member, load all completion flags, and navigate to event details
            flowVM.setCurrentMember(member);
            // Only check event for null, member is always non-null
            final eventId = event?.id;
            if (eventId != null) {
              flowVM.loadAllCompletionFlags(member.id, eventId);
            }
            flowVM.navigateToEventDetails();
          },
          onPrevious: flowVM.currentStep > 0 ? flowVM.previousStep : null,
        );

      case WellnessFlowViewModel.stepConsent:
        return event != null
            ? ConsentScreen(
                event: event!,
                onNext: () {
                  flowVM.markConsentCompleted();
                  if (flowVM.consentVM.selectedScreenings.isNotEmpty) {
                    flowVM.markScreeningsInProgress();
                  }
                  flowVM.initializeFlow(flowVM.consentVM.selectedScreenings);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    flowVM.navigateToEventDetails();
                  });
                },
              )
            : const SizedBox();

      case WellnessFlowViewModel.stepHealthScreeningsMenu:
        // Show health screenings menu with enabled/disabled cards based on consent
        return HealthScreeningsScreen(
          hraEnabled: flowVM.hraEnabled,
          hctEnabled: flowVM.hctEnabled,
          tbEnabled: flowVM.tbEnabled,
          cancerEnabled: flowVM.cancerEnabled,
          hraCompleted: flowVM.hraCompleted,
          hctCompleted: flowVM.hctCompleted,
          tbCompleted: flowVM.tbCompleted,
          cancerCompleted: flowVM.cancerCompleted,
          onHraTap: () => flowVM.navigateToHraScreening(),
          onHctTap: () => flowVM.navigateToHctScreening(),
          onTbTap: () => flowVM.navigateToTbScreening(),
          onCancerTap: () => flowVM.navigateToCancerScreening(),
        );

      case WellnessFlowViewModel.stepPersonalDetails:
        // Set event ID before showing the member details screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          flowVM.memberDetailsVM.setEventId(event?.id);
        });
        return MemberDetailsScreen(
          onNext: flowVM.nextStep,
          viewModel: flowVM.memberDetailsVM,
        );

      case WellnessFlowViewModel.stepRiskAssessment:
        // Set member and event IDs before showing the screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          flowVM.riskVM.setMemberAndEventId(
            flowVM.currentMember?.id,
            event?.id,
          );
        });
        return PersonalRiskAssessmentScreen(
          onNext: () {
            // Immediate update: mark HRA as completed in the parent ViewModel
            flowVM.markHraCompleted();
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => _navigateAfterScreeningComplete(flowVM));
          },
          onPrevious: () {
            flowVM.navigateToSection(
                WellnessFlowViewModel.sectionHealthScreenings);
          },
          viewModel: flowVM.riskVM,
          nurseViewModel: flowVM.nurseVM,
          isFemale: flowVM.memberDetailsVM.gender?.toLowerCase() == 'female',
          age: flowVM.memberDetailsVM.userAge,
        );

      /*   case 'health_metrics':
        return HealthMetricsScreen(
          onNext: flowVM.nextStep,
          onPrevious: flowVM.previousStep,
          viewModel: flowVM.healthMetricsVM,
          nurseViewModel: flowVM.nurseVM,
        ); */

      /*  case 'nurse_intervention':
        if (event != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flowVM.nurseVM.initialiseWithEvent(event!);
          });
        }
        return ChangeNotifierProvider.value(
          value: flowVM.nurseVM,
          child: NurseInterventionScreen(
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
          ),
        ); */

      case WellnessFlowViewModel.stepHctTest:
        // Set member and event IDs before showing the screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          flowVM.hctTestVM.setMemberAndEventId(
            flowVM.currentMember?.id ?? '',
            event?.id ?? '',
          );
        });
        return ChangeNotifierProvider.value(
          value: flowVM.hctTestVM,
          child: HIVTestScreen(
            onNext: flowVM.nextStep,
            onPrevious: () {
              // Return to health screenings menu
              flowVM.navigateToSection(
                  WellnessFlowViewModel.sectionHealthScreenings);
            },
          ),
        );

      case WellnessFlowViewModel.stepHctResults:
        if (event != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flowVM.hctResultsVM.initialiseWithEvent(event!);
            flowVM.hctResultsVM.setMemberAndEventId(
              flowVM.currentMember?.id ?? '',
              event!.id,
            );
          });
        }
        return ChangeNotifierProvider.value(
          value: flowVM.hctResultsVM,
          child: HIVTestResultScreen(
            onNext: () {
              // Immediate update: mark HCT as completed in the parent ViewModel
              flowVM.markHctCompleted();
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _navigateAfterScreeningComplete(flowVM));
            },
            onPrevious: flowVM.previousStep,
          ),
        );

      case WellnessFlowViewModel.stepTbTest:
        if (event != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flowVM.tbTestVM.initialiseWithEvent(event!);
            flowVM.tbTestVM.setMemberAndEventId(
              flowVM.currentMember?.id ?? '',
              event!.id,
            );
          });
        }
        return ChangeNotifierProvider.value(
          value: flowVM.tbTestVM,
          child: TBTestingScreen(
            onNext: () {
              // Immediate update: mark TB as completed in the parent ViewModel
              flowVM.markTbCompleted();
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _navigateAfterScreeningComplete(flowVM));
            },
            onPrevious: () {
              flowVM.navigateToSection(
                  WellnessFlowViewModel.sectionHealthScreenings);
            },
          ),
        );

      case WellnessFlowViewModel.stepCancerScreening:
        if (event != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flowVM.cancerVM.setMemberAndEventId(
              flowVM.currentMember?.id ?? '',
              event!.id,
            );
          });
        }
        return ChangeNotifierProvider.value(
          value: flowVM.cancerVM,
          child: CancerScreen(
            onNext: () {
              // Immediate update: mark Cancer as completed in the parent ViewModel
              flowVM.markCancerCompleted();
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _navigateAfterScreeningComplete(flowVM));
            },
            onPrevious: () {
              flowVM.navigateToSection(
                  WellnessFlowViewModel.sectionHealthScreenings);
            },
          ),
        );

      case WellnessFlowViewModel.stepSurvey:
        return ChangeNotifierProvider.value(
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
                // Mark survey as completed and update UI immediately
                flowVM.markSurveyCompleted();
                debugPrint('WellnessFlow: submitAll completed');
              } catch (e, st) {
                debugPrint('WellnessFlow: Error in submitAll: $e\n$st');
                if (context.mounted) {
                  // Close progress dialog if open
                  Navigator.of(context).pop();
                  AppSnackbar.showError(
                      context, 'Failed to submit data: $e');
                }
                return;
              }

              // 2) increment the screened counter for the active event and persist
              final active = flowVM.activeEvent;
              if (active != null && context.mounted) {
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

              // 3) Handle navigation based on whether this is standalone or part of a flow
              if (context.mounted) {
                // Close progress dialog
                Navigator.of(context).pop();

                if (flowVM.isStandaloneSurvey) {
                  // For standalone survey, return to CurrentEventDetailsScreen
                  flowVM.resetFlow();
                } else {
                  // For survey at end of screening flow, pop the entire WellnessFlowPage
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              }

              debugPrint(
                  'WellnessFlow: survey onSubmit finished (isStandalone: ${flowVM.isStandaloneSurvey})');
            },
          ),
        );

      default:
        return Center(
          child: Text('Invalid step: ${flowVM.currentStepName}'),
        );
    }
  }

  /// After a screening completes, navigate to the survey if all consented
  /// screenings are done, or return to the health screenings menu otherwise.
  void _navigateAfterScreeningComplete(WellnessFlowViewModel flowVM) {
    final allDone = (!flowVM.hraEnabled || flowVM.hraCompleted) &&
        (!flowVM.hctEnabled || flowVM.hctCompleted) &&
        (!flowVM.tbEnabled || flowVM.tbCompleted) &&
        (!flowVM.cancerEnabled || flowVM.cancerCompleted);
    if (allDone) {
      flowVM.markScreeningsCompleted();
      flowVM.navigateToSection(WellnessFlowViewModel.sectionSurvey);
    } else {
      flowVM.navigateToSection(WellnessFlowViewModel.sectionHealthScreenings);
    }
  }
}
