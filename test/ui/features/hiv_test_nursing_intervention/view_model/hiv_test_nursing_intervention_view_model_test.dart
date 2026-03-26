import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/hiv_test_nursing_intervention/view_model/hiv_test_nursing_intervention_view_model.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';

WellnessEvent _buildEvent() => WellnessEvent(
      id: 'ev-1',
      title: 'Health Day',
      date: DateTime(2025, 6, 1),
      venue: 'Hall',
      address: '1 Road',
      townCity: 'City',
      province: 'Gauteng',
      onsiteContactFirstName: 'A',
      onsiteContactLastName: 'B',
      onsiteContactNumber: '000',
      onsiteContactEmail: 'a@b.com',
      aeContactFirstName: 'C',
      aeContactLastName: 'D',
      aeContactNumber: '000',
      aeContactEmail: 'c@d.com',
      servicesRequested: 'HCT',
      expectedParticipation: 50,
      nurses: 2,
      setUpTime: '07:00',
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'None',
    );

void main() {
  late HIVTestNursingInterventionViewModel viewModel;

  setUp(() {
    viewModel = HIVTestNursingInterventionViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('HIVTestNursingInterventionViewModel – initial state', () {
    test('all assessment questions are null', () {
      expect(viewModel.windowPeriod, isNull);
      expect(viewModel.expectedResult, isNull);
      expect(viewModel.difficultyDealingResult, isNull);
      expect(viewModel.urgentPsychosocial, isNull);
      expect(viewModel.committedToChange, isNull);
    });

    test('nursingReferralSelection is null', () {
      expect(viewModel.nursingReferralSelection, isNull);
    });

    test('showInitialAssessment is true', () {
      expect(viewModel.showInitialAssessment, isTrue);
    });
  });

  group('HIVTestNursingInterventionViewModel – setters', () {
    test('setWindowPeriod updates value and notifies', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setWindowPeriod('N/A');

      expect(viewModel.windowPeriod, 'N/A');
      expect(notified, isTrue);
    });

    test('setExpectedResult updates value', () {
      viewModel.setExpectedResult('Yes');
      expect(viewModel.expectedResult, 'Yes');
    });

    test('setDifficultyDealingResult updates value', () {
      viewModel.setDifficultyDealingResult('No');
      expect(viewModel.difficultyDealingResult, 'No');
    });

    test('setUrgentPsychosocial updates value', () {
      viewModel.setUrgentPsychosocial('Yes');
      expect(viewModel.urgentPsychosocial, 'Yes');
    });

    test('setCommittedToChange updates value', () {
      viewModel.setCommittedToChange('No');
      expect(viewModel.committedToChange, 'No');
    });
  });

  group('HIVTestNursingInterventionViewModel – setFollowUpLocation', () {
    test('updates location', () {
      viewModel.setFollowUpLocation('Private doctor');
      expect(viewModel.followUpLocation, 'Private doctor');
    });

    test('clears other controller when not Other', () {
      viewModel.followUpOtherController.text = 'Pharmacy';
      viewModel.setFollowUpLocation('State clinic');
      expect(viewModel.followUpOtherController.text, isEmpty);
    });

    test('does not notify for same value', () {
      viewModel.setFollowUpLocation('State clinic');
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setFollowUpLocation('State clinic');
      expect(notified, isFalse);
    });
  });

  group('HIVTestNursingInterventionViewModel – setNursingReferralSelection', () {
    test('updates selection', () {
      viewModel
          .setNursingReferralSelection(NursingReferralOption.patientNotReferred);
      expect(viewModel.nursingReferralSelection,
          NursingReferralOption.patientNotReferred);
    });

    test('clears notReferredReasonController when not patientNotReferred', () {
      viewModel.notReferredReasonController.text = 'Reason';
      viewModel.setNursingReferralSelection(
          NursingReferralOption.referredToStateClinic);
      expect(viewModel.notReferredReasonController.text, isEmpty);
    });
  });

  group('HIVTestNursingInterventionViewModel – initialiseWithEvent', () {
    test('pre-fills nurseDateController on first call', () {
      viewModel.initialiseWithEvent(_buildEvent());
      expect(viewModel.nurseDateController.text, '2025-06-01');
    });

    test('does not overwrite on second call', () {
      viewModel.initialiseWithEvent(_buildEvent());
      viewModel.nurseDateController.text = 'custom';
      viewModel.initialiseWithEvent(_buildEvent());
      expect(viewModel.nurseDateController.text, 'custom');
    });
  });
}
