import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/domain/models/hct_result.dart';
import 'package:kenwell_health_app/domain/usecases/submit_hct_test_result_usecase.dart';
import 'package:kenwell_health_app/ui/features/hct_test_results/view_model/hct_test_result_view_model.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';

class MockSubmitHCTTestResultUseCase extends Mock
    implements SubmitHCTTestResultUseCase {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockSubmitHCTTestResultUseCase mockUseCase;
  late MockAuthService mockAuthService;
  late HCTTestResultViewModel viewModel;

  setUp(() {
    mockUseCase = MockSubmitHCTTestResultUseCase();
    mockAuthService = MockAuthService();
    when(() => mockAuthService.getCurrentUser()).thenAnswer((_) async => null);

    registerFallbackValue(
      HctResult(
        id: 'hr-1',
        createdAt: DateTime(2025, 1, 1),
      ),
    );

    viewModel = HCTTestResultViewModel(
      authService: mockAuthService,
      submitHctTestResultUseCase: mockUseCase,
    );
  });

  tearDown(() => viewModel.dispose());

  group('HCTTestResultViewModel – initial state', () {
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

  group('HCTTestResultViewModel – setters', () {
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

  group('HCTTestResultViewModel – setMemberAndEventId', () {
    test('stores ids without error', () {
      expect(
          () => viewModel.setMemberAndEventId('m-1', 'e-1'), returnsNormally);
    });
  });

  group('HCTTestResultViewModel – options lists', () {
    test('windowPeriodOptions is non-empty',
        () => expect(viewModel.windowPeriodOptions, isNotEmpty));
  });
}
