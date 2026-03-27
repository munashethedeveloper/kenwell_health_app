import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/domain/usecases/submit_tb_screening_usecase.dart';
import 'package:kenwell_health_app/ui/features/tb_test/view_model/tb_testing_view_model.dart';

class MockSubmitTBScreeningUseCase extends Mock
    implements SubmitTBScreeningUseCase {}

void main() {
  late MockSubmitTBScreeningUseCase mockUseCase;
  late TBTestingViewModel viewModel;

  setUp(() {
    mockUseCase = MockSubmitTBScreeningUseCase();
    viewModel = TBTestingViewModel(submitTBScreeningUseCase: mockUseCase);

    registerFallbackValue(
      TbScreening(
        id: 'tb-1',
        memberId: 'm-1',
        eventId: 'e-1',
        nurseFirstName: 'Nurse',
        nurseLastName: 'Test',
        rank: 'RN',
        sancNumber: '12345',
        nurseDate: '2025-01-01',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ),
    );
  });

  tearDown(() => viewModel.dispose());

  group('TBTestingViewModel – initial state', () {
    test('all symptom questions are null', () {
      expect(viewModel.coughTwoWeeks, isNull);
      expect(viewModel.bloodInSputum, isNull);
      expect(viewModel.weightLoss, isNull);
      expect(viewModel.nightSweats, isNull);
    });

    test('risk flags are false when no answers set', () {
      expect(viewModel.isAtRisk, isFalse);
      expect(viewModel.isCaution, isFalse);
      expect(viewModel.isHighRisk, isFalse);
      expect(viewModel.isHealthy, isFalse);
    });
  });

  group('TBTestingViewModel – setters', () {
    test('setCoughTwoWeeks updates value and notifies', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setCoughTwoWeeks('Yes');

      expect(viewModel.coughTwoWeeks, 'Yes');
      expect(notified, isTrue);
    });

    test('setCoughTwoWeeks does not notify for same value', () {
      viewModel.setCoughTwoWeeks('No');
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setCoughTwoWeeks('No');

      expect(notified, isFalse);
    });

    test('setBloodInSputum updates value', () {
      viewModel.setBloodInSputum('Yes');
      expect(viewModel.bloodInSputum, 'Yes');
    });

    test('setWeightLoss updates value', () {
      viewModel.setWeightLoss('No');
      expect(viewModel.weightLoss, 'No');
    });

    test('setNightSweats updates value', () {
      viewModel.setNightSweats('Yes');
      expect(viewModel.nightSweats, 'Yes');
    });
  });

  group('TBTestingViewModel – risk classification', () {
    test('isAtRisk is true when any symptom is Yes', () {
      viewModel.setCoughTwoWeeks('Yes');
      expect(viewModel.isAtRisk, isTrue);
    });

    test('isCaution is true when 1 or 2 symptoms are Yes', () {
      viewModel.setCoughTwoWeeks('Yes');
      viewModel.setBloodInSputum('No');
      viewModel.setWeightLoss('No');
      viewModel.setNightSweats('No');

      expect(viewModel.isCaution, isTrue);
      expect(viewModel.isHighRisk, isFalse);
    });

    test('isHighRisk is true when 3 or more symptoms are Yes', () {
      viewModel.setCoughTwoWeeks('Yes');
      viewModel.setBloodInSputum('Yes');
      viewModel.setWeightLoss('Yes');

      expect(viewModel.isHighRisk, isTrue);
      expect(viewModel.isAtRisk, isTrue);
    });

    test('isHealthy when all answered No', () {
      viewModel.setCoughTwoWeeks('No');
      viewModel.setBloodInSputum('No');
      viewModel.setWeightLoss('No');
      viewModel.setNightSweats('No');

      expect(viewModel.isHealthy, isTrue);
      expect(viewModel.isAtRisk, isFalse);
    });
  });

  group('TBTestingViewModel – setMemberAndEventId', () {
    test('stores ids without error', () {
      expect(
          () => viewModel.setMemberAndEventId('m-1', 'e-1'), returnsNormally);
    });
  });
}
