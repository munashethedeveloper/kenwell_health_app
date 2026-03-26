import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/ui/features/nurse_interventions/view_model/nurse_intervention_view_model.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;
  late NurseInterventionViewModel viewModel;

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.getCurrentUser())
        .thenAnswer((_) async => null);
    viewModel = NurseInterventionViewModel(authService: mockAuthService);
  });

  tearDown(() => viewModel.dispose());

  group('NurseInterventionViewModel – initial state', () {
    test('all assessment questions are null', () {
      expect(viewModel.windowPeriod, isNull);
      expect(viewModel.expectedResult, isNull);
      expect(viewModel.difficultyDealingResult, isNull);
      expect(viewModel.urgentPsychosocial, isNull);
      expect(viewModel.committedToChange, isNull);
    });

    test('nursingReferralSelection is null initially', () {
      expect(viewModel.nursingReferralSelection, isNull);
    });

    test('showInitialAssessment is false', () {
      expect(viewModel.showInitialAssessment, isFalse);
    });
  });

  group('NurseInterventionViewModel – assessment setters', () {
    test('setWindowPeriod updates value and notifies', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setWindowPeriod('Yes');

      expect(viewModel.windowPeriod, 'Yes');
      expect(notified, isTrue);
    });

    test('setExpectedResult updates value', () {
      viewModel.setExpectedResult('No');
      expect(viewModel.expectedResult, 'No');
    });

    test('setDifficultyDealingResult updates value', () {
      viewModel.setDifficultyDealingResult('Yes');
      expect(viewModel.difficultyDealingResult, 'Yes');
    });

    test('setUrgentPsychosocial updates value', () {
      viewModel.setUrgentPsychosocial('No');
      expect(viewModel.urgentPsychosocial, 'No');
    });

    test('setCommittedToChange updates value', () {
      viewModel.setCommittedToChange('Yes');
      expect(viewModel.committedToChange, 'Yes');
    });
  });

  group('NurseInterventionViewModel – setFollowUpLocation', () {
    test('updates followUpLocation', () {
      viewModel.setFollowUpLocation('State clinic');
      expect(viewModel.followUpLocation, 'State clinic');
    });

    test('clears followUpOtherController when not Other', () {
      viewModel.followUpOtherController.text = 'Some clinic';
      viewModel.setFollowUpLocation('State clinic');
      expect(viewModel.followUpOtherController.text, isEmpty);
    });

    test('preserves followUpOtherController when Other', () {
      viewModel.followUpOtherController.text = 'Community clinic';
      viewModel.setFollowUpLocation('Other');
      expect(viewModel.followUpOtherController.text, 'Community clinic');
    });

    test('does not notify for same value', () {
      viewModel.setFollowUpLocation('State clinic');
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setFollowUpLocation('State clinic');

      expect(notified, isFalse);
    });
  });

  group('NurseInterventionViewModel – setNursingReferralSelection', () {
    test('updates selection', () {
      viewModel.setNursingReferralSelection(
          NursingReferralOption.referredToStateClinic);
      expect(viewModel.nursingReferralSelection,
          NursingReferralOption.referredToStateClinic);
    });

    test('clears notReferredReasonController when not patientNotReferred', () {
      viewModel.notReferredReasonController.text = 'Patient refused';
      viewModel.setNursingReferralSelection(
          NursingReferralOption.referredToStateClinic);
      expect(viewModel.notReferredReasonController.text, isEmpty);
    });
  });
}
