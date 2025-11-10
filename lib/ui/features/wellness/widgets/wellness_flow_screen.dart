import 'package:flutter/material.dart';
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

// ViewModel
import '../../tb_test/widgets/tb_testing_screen.dart';
import '../../tb_test_nursing_intervention/widgets/tb_nursing_intervention_screen.dart';
import '../view_model/wellness_flow_view_model.dart';

class WellnessFlowScreen extends StatelessWidget {
  const WellnessFlowScreen(
      {super.key,
      required WellnessFlowViewModel viewModel,
      required void Function() onNext,
      required void Function() onPrevious,
      required void Function() onCancel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WellnessFlowViewModel(),
      child: Consumer<WellnessFlowViewModel>(
        builder: (context, flowVM, _) {
          Widget currentScreen;

          switch (flowVM.currentStep) {
            case 0:
              currentScreen = ConsentScreen(
                onNext: flowVM.nextStep,
                onCancel: flowVM.cancelFlow,
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
              currentScreen = NurseInterventionScreen(
                onNext: flowVM.nextStep,
                onPrevious: flowVM.previousStep,
              );
              break;
            case 5:
              currentScreen = HIVTestScreen(
                onNext: flowVM.nextStep,
                onPrevious: flowVM.previousStep,
              );
              break;
            case 6:
              currentScreen = HIVTestResultScreen(
                onNext: flowVM.nextStep,
                onPrevious: flowVM.previousStep,
              );
              break;
            case 7:
              currentScreen = HIVTestNursingInterventionScreen(
                onNext: flowVM.nextStep,
                onPrevious: flowVM.previousStep,
              );
              break;
            case 8:
              currentScreen = TBTestingScreen(
                onNext: flowVM.nextStep,
                onPrevious: flowVM.previousStep,
              );
              break;
            case 9:
              currentScreen = TBNursingInterventionScreen(
                onNext: flowVM.nextStep,
                onPrevious: flowVM.previousStep,
              );
              break;
            case 10:
              currentScreen = SurveyScreen(
                onPrevious: flowVM.previousStep,
                onSubmit: () => flowVM.submitAll(context),
              );
              break;
            default:
              currentScreen = const Center(child: Text('Invalid step'));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Wellness Screening Flow',
                style: TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF90C048),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: currentScreen,
            ),
          );
        },
      ),
    );
  }
}
