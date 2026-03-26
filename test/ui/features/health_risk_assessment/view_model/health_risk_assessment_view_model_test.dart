import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/domain/usecases/submit_hra_usecase.dart';
import 'package:kenwell_health_app/ui/features/health_risk_assessment/view_model/health_risk_assessment_view_model.dart';

class MockSubmitHRAUseCase extends Mock implements SubmitHRAUseCase {}

void main() {
  late MockSubmitHRAUseCase mockUseCase;
  late PersonalRiskAssessmentViewModel viewModel;

  setUp(() {
    mockUseCase = MockSubmitHRAUseCase();
    viewModel = PersonalRiskAssessmentViewModel(submitHRAUseCase: mockUseCase);

    registerFallbackValue(
      HraScreening(
        id: 'hra-1',
        chronicConditions: const {},
        createdAt: DateTime(2025, 1, 1),
      ),
    );
  });

  tearDown(() => viewModel.dispose());

  group('PersonalRiskAssessmentViewModel – initial state', () {
    test('dropdown values are null', () {
      expect(viewModel.smokingStatus, isNull);
      expect(viewModel.drinkingStatus, isNull);
      expect(viewModel.exerciseStatus, isNull);
    });

    test('exerciseFrequency is empty string', () {
      expect(viewModel.exerciseFrequency, isEmpty);
    });

    test('bmiController is empty', () {
      expect(viewModel.bmiController.text, isEmpty);
    });
  });

  group('PersonalRiskAssessmentViewModel – BMI calculation', () {
    test('calculates BMI correctly for height in meters', () {
      viewModel.heightController.text = '1.75';
      viewModel.weightController.text = '70';
      // Listener triggers calculation automatically.
      final bmi = double.tryParse(viewModel.bmiController.text);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(22.86, 0.1));
    });

    test('calculates BMI correctly for height in centimeters', () {
      viewModel.heightController.text = '175';
      viewModel.weightController.text = '70';
      final bmi = double.tryParse(viewModel.bmiController.text);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(22.86, 0.1));
    });

    test('clears BMI when height is empty', () {
      viewModel.heightController.text = '175';
      viewModel.weightController.text = '70';
      viewModel.heightController.text = '';
      expect(viewModel.bmiController.text, isEmpty);
    });

    test('clears BMI when weight is empty', () {
      viewModel.heightController.text = '175';
      viewModel.weightController.text = '70';
      viewModel.weightController.text = '';
      expect(viewModel.bmiController.text, isEmpty);
    });
  });

  group('PersonalRiskAssessmentViewModel – setExerciseFrequency', () {
    test('updates exerciseFrequency and notifies', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setExerciseFrequency('3-4 times a week');

      expect(viewModel.exerciseFrequency, '3-4 times a week');
      expect(notified, isTrue);
    });

    test('does not notify for same value', () {
      viewModel.setExerciseFrequency('Daily');
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setExerciseFrequency('Daily');

      expect(notified, isFalse);
    });
  });

  group('PersonalRiskAssessmentViewModel – setMemberAndEventId', () {
    test('stores ids without error', () {
      expect(() => viewModel.setMemberAndEventId('m-1', 'e-1'),
          returnsNormally);
    });
  });

  group('PersonalRiskAssessmentViewModel – options lists', () {
    test('smoking status options are non-empty', () {
      expect(viewModel.smokingStatusOptions, isNotEmpty);
    });
    test('drinking status options are non-empty', () {
      expect(viewModel.drinkingStatusOptions, isNotEmpty);
    });
    test('exercise status options are non-empty', () {
      expect(viewModel.exerciseStatusOptions, isNotEmpty);
    });
  });
}
