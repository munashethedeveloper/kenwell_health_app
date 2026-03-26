import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/tb_test_nursing_intervention/view_model/tb_nursing_intervention_view_model.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';

WellnessEvent _buildEvent() => WellnessEvent(
      id: 'ev-1',
      title: 'Health Day',
      date: DateTime(2025, 6, 15),
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
      servicesRequested: 'TB',
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
  late TBNursingInterventionViewModel viewModel;

  setUp(() {
    viewModel = TBNursingInterventionViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('TBNursingInterventionViewModel – initial state', () {
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

    test('showInitialAssessment is false', () {
      expect(viewModel.showInitialAssessment, isFalse);
    });
  });

  group('TBNursingInterventionViewModel – setters', () {
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

    test('setUrgentPsychosocial updates value', () {
      viewModel.setUrgentPsychosocial('Yes');
      expect(viewModel.urgentPsychosocial, 'Yes');
    });

    test('setCommittedToChange updates value', () {
      viewModel.setCommittedToChange('No');
      expect(viewModel.committedToChange, 'No');
    });
  });

  group('TBNursingInterventionViewModel – setFollowUpLocation', () {
    test('updates location', () {
      viewModel.setFollowUpLocation('State clinic');
      expect(viewModel.followUpLocation, 'State clinic');
    });

    test('clears followUpOtherController when not Other', () {
      viewModel.followUpOtherController.text = 'Somewhere';
      viewModel.setFollowUpLocation('Private doctor');
      expect(viewModel.followUpOtherController.text, isEmpty);
    });
  });

  group('TBNursingInterventionViewModel – setNursingReferralSelection', () {
    test('updates selection', () {
      viewModel.setNursingReferralSelection(
          NursingReferralOption.referredToStateClinic);
      expect(viewModel.nursingReferralSelection,
          NursingReferralOption.referredToStateClinic);
    });

    test('clears notReferredReasonController when not patientNotReferred', () {
      viewModel.notReferredReasonController.text = 'Reason';
      viewModel.setNursingReferralSelection(
          NursingReferralOption.referredToStateClinic);
      expect(viewModel.notReferredReasonController.text, isEmpty);
    });
  });

  group('TBNursingInterventionViewModel – initialiseWithEvent', () {
    test('pre-fills nurseDateController on first call', () {
      viewModel.initialiseWithEvent(_buildEvent());
      expect(viewModel.nurseDateController.text, '2025-06-15');
    });

    test('double init is blocked', () {
      viewModel.initialiseWithEvent(_buildEvent());
      viewModel.nurseDateController.text = 'custom';
      viewModel.initialiseWithEvent(_buildEvent());
      expect(viewModel.nurseDateController.text, 'custom');
    });
  });
}
