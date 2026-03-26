import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/domain/models/hiv_result.dart';
import 'package:kenwell_health_app/domain/usecases/submit_hiv_test_result_usecase.dart';
import 'package:kenwell_health_app/ui/features/hiv_test_results/view_model/hiv_test_result_view_model.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';

class MockSubmitHIVTestResultUseCase extends Mock
    implements SubmitHIVTestResultUseCase {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockSubmitHIVTestResultUseCase mockUseCase;
  late MockAuthService mockAuthService;
  late HIVTestResultViewModel viewModel;

  setUp(() {
    mockUseCase = MockSubmitHIVTestResultUseCase();
    mockAuthService = MockAuthService();
    when(() => mockAuthService.getCurrentUser()).thenAnswer((_) async => null);

    registerFallbackValue(
      HivResult(
        id: 'hr-1',
        createdAt: DateTime(2025, 1, 1),
      ),
    );

    viewModel = HIVTestResultViewModel(
      authService: mockAuthService,
      submitHIVTestResultUseCase: mockUseCase,
    );
  });

  tearDown(() => viewModel.dispose());

  group('HIVTestResultViewModel – initial state', () {
    test('screeningResult defaults to Negative',
        () => expect(viewModel.screeningResult, 'Negative'));
    test('initial assessment questions are null', () {
      expect(viewModel.windowPeriod, isNull);
      expect(viewModel.expectedResult, isNull);
      expect(viewModel.urgentPsychosocial, isNull);
    });
    test('nursingReferralSelection defaults to patientNotReferred', () {
      expect(viewModel.nursingReferralSelection,
          NursingReferralOption.patientNotReferred);
    });
  });

  group('HIVTestResultViewModel – setters', () {
    test('setWindowPeriod updates value', () {
      viewModel.setWindowPeriod('Yes');
      expect(viewModel.windowPeriod, 'Yes');
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
      viewModel.setUrgentPsychosocial('Yes');
      expect(viewModel.urgentPsychosocial, 'Yes');
    });

    test('setCommittedToChange updates value', () {
      viewModel.setCommittedToChange('Yes');
      expect(viewModel.committedToChange, 'Yes');
    });
  });

  group('HIVTestResultViewModel – setMemberAndEventId', () {
    test('stores ids without error', () {
      expect(
          () => viewModel.setMemberAndEventId('m-1', 'e-1'), returnsNormally);
    });
  });

  group('HIVTestResultViewModel – options lists', () {
    test('windowPeriodOptions is non-empty',
        () => expect(viewModel.windowPeriodOptions, isNotEmpty));
  });
}
