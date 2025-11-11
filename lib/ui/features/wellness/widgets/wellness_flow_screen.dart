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
import '../../tb_test/widgets/tb_testing_screen.dart';
import '../../tb_test_nursing_intervention/widgets/tb_nursing_intervention_screen.dart';

// ViewModel
import '../view_model/wellness_flow_view_model.dart';

class WellnessFlowScreen extends StatelessWidget {
  final VoidCallback onExitFlow;
  const WellnessFlowScreen({super.key, required this.onExitFlow});

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
            onSubmit: () => flowVM.submitAll(context),
          ),
        );
        break;
      default:
        currentScreen = const Center(child: Text('Invalid step'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey<int>(flowVM.currentStep),
        child: currentScreen,
      ),
    );
  }
}
