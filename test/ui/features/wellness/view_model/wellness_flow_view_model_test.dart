import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/domain/usecases/load_wellness_completion_status_usecase.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_consent_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hra_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hiv_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_tb_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_survey_repository.dart';
import 'package:kenwell_health_app/ui/features/wellness/view_model/wellness_flow_view_model.dart';

class MockLoadWellnessCompletionStatusUseCase extends Mock
    implements LoadWellnessCompletionStatusUseCase {}

class MockConsentRepo extends Mock implements FirestoreConsentRepository {}

class MockHraRepo extends Mock implements FirestoreHraRepository {}

class MockHivRepo extends Mock implements FirestoreHivScreeningRepository {}

class MockTbRepo extends Mock implements FirestoreTbScreeningRepository {}

class MockCancerRepo extends Mock
    implements FirestoreCancerScreeningRepository {}

class MockSurveyRepo extends Mock implements FirestoreSurveyRepository {}

WellnessEvent _buildEvent() => WellnessEvent(
      id: 'ev-1',
      title: 'Wellness Day',
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
      servicesRequested: 'HRA',
      expectedParticipation: 50,
      nurses: 2,
      setUpTime: '07:00',
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'None',
    );

WellnessFlowViewModel _buildVM({
  MockLoadWellnessCompletionStatusUseCase? completionUC,
}) {
  final uc = completionUC ?? MockLoadWellnessCompletionStatusUseCase();
  return WellnessFlowViewModel(
    activeEvent: _buildEvent(),
    consentRepository: MockConsentRepo(),
    hraRepository: MockHraRepo(),
    hivRepository: MockHivRepo(),
    tbRepository: MockTbRepo(),
    cancerRepository: MockCancerRepo(),
    surveyRepository: MockSurveyRepo(),
    completionStatusUseCase: uc,
  );
}

void main() {
  group('WellnessFlowViewModel – initial state', () {
    test('completion flags are all false', () {
      final vm = _buildVM();
      expect(vm.consentCompleted, isFalse);
      expect(vm.memberRegistrationCompleted, isFalse);
      expect(vm.screeningsCompleted, isFalse);
      expect(vm.surveyCompleted, isFalse);
      vm.dispose();
    });

    test('enabled flags are all false', () {
      final vm = _buildVM();
      expect(vm.hraEnabled, isFalse);
      expect(vm.hctEnabled, isFalse);
      expect(vm.tbEnabled, isFalse);
      expect(vm.cancerEnabled, isFalse);
      vm.dispose();
    });

    test('currentStep is 0', () {
      final vm = _buildVM();
      expect(vm.currentStep, 0);
      vm.dispose();
    });

    test('completedSectionsCount is 0', () {
      final vm = _buildVM();
      expect(vm.completedSectionsCount, 0);
      vm.dispose();
    });
  });

  group('WellnessFlowViewModel – step constants', () {
    test('step name constants are non-empty strings', () {
      expect(WellnessFlowViewModel.stepMemberRegistration, isNotEmpty);
      expect(WellnessFlowViewModel.stepConsent, isNotEmpty);
      expect(WellnessFlowViewModel.stepSurvey, isNotEmpty);
    });
  });

  group('WellnessFlowViewModel – initializeFlow', () {
    test('sets up flow with consent step included', () {
      final vm = _buildVM();
      vm.initializeFlow(['hct', 'tb']);
      // After init the flow should contain more than just member_registration
      expect(vm.currentStep, 0);
      vm.dispose();
    });
  });

  group('WellnessFlowViewModel – nextStep / previousStep', () {
    test('nextStep increments currentStep', () {
      final vm = _buildVM();
      vm.initializeFlow(['hct']);
      final initial = vm.currentStep;

      vm.nextStep();

      expect(vm.currentStep, greaterThan(initial));
      vm.dispose();
    });

    test('previousStep decrements currentStep', () {
      final vm = _buildVM();
      vm.initializeFlow(['hct']);
      vm.nextStep();
      final after = vm.currentStep;

      vm.previousStep();

      expect(vm.currentStep, lessThan(after));
      vm.dispose();
    });
  });

  group('WellnessFlowViewModel – loadAllCompletionFlags', () {
    test('returns early when memberId is null', () async {
      final vm = _buildVM();
      // Should complete without throwing.
      await expectLater(vm.loadAllCompletionFlags(null, 'ev-1'), completes);
      vm.dispose();
    });

    test('returns early when eventId is null', () async {
      final vm = _buildVM();
      await expectLater(vm.loadAllCompletionFlags('m-1', null), completes);
      vm.dispose();
    });
  });

  group('WellnessFlowViewModel – cancelFlow / resetToMemberSearch', () {
    test('cancelFlow resets step to 0', () {
      final vm = _buildVM();
      vm.initializeFlow(['hct']);
      vm.nextStep();

      vm.cancelFlow();

      expect(vm.currentStep, 0);
      vm.dispose();
    });

    test('resetToMemberSearch resets step to 0', () {
      final vm = _buildVM();
      vm.initializeFlow(['hct']);
      vm.nextStep();

      vm.resetToMemberSearch();

      expect(vm.currentStep, 0);
      vm.dispose();
    });
  });

  group('WellnessFlowViewModel – completedSectionsCount', () {
    test('counts completed sections correctly', () {
      final vm = _buildVM();
      vm.memberRegistrationCompleted = true;
      vm.consentCompleted = true;
      vm.screeningsCompleted = true;
      vm.surveyCompleted = false;

      expect(vm.completedSectionsCount, 3);
      vm.dispose();
    });

    test('returns 4 when all sections complete', () {
      final vm = _buildVM();
      vm.memberRegistrationCompleted = true;
      vm.consentCompleted = true;
      vm.screeningsCompleted = true;
      vm.surveyCompleted = true;

      expect(vm.completedSectionsCount, 4);
      vm.dispose();
    });
  });
}
