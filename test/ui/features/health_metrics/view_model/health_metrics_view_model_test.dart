import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/ui/features/health_metrics/view_model/health_metrics_view_model.dart';
import 'package:kenwell_health_app/utils/health_metric_classification.dart';

void main() {
  late HealthMetricsViewModel viewModel;

  setUp(() {
    viewModel = HealthMetricsViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('HealthMetricsViewModel – initial state', () {
    test('isSubmitting is false',
        () => expect(viewModel.isSubmitting, isFalse));
    test('all controllers are empty', () {
      expect(viewModel.heightController.text, isEmpty);
      expect(viewModel.weightController.text, isEmpty);
      expect(viewModel.bmiController.text, isEmpty);
    });
  });

  group('HealthMetricsViewModel – BMI calculation', () {
    test('calculates BMI for height in meters', () {
      viewModel.heightController.text = '1.75';
      viewModel.weightController.text = '70';
      final bmi = double.tryParse(viewModel.bmiController.text);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(22.86, 0.1));
    });

    test('calculates BMI when height is entered in centimeters', () {
      viewModel.heightController.text = '175';
      viewModel.weightController.text = '70';
      final bmi = double.tryParse(viewModel.bmiController.text);
      expect(bmi, isNotNull);
      expect(bmi!, closeTo(22.86, 0.1));
    });

    test('clears BMI when height is invalid', () {
      viewModel.heightController.text = '175';
      viewModel.weightController.text = '70';
      viewModel.heightController.text = 'abc';
      expect(viewModel.bmiController.text, isEmpty);
    });

    test('clears BMI when weight is empty', () {
      viewModel.heightController.text = '1.75';
      viewModel.weightController.text = '';
      expect(viewModel.bmiController.text, isEmpty);
    });
  });

  group('HealthMetricsViewModel – metric classification', () {
    test('systolicStatus returns null when field is empty', () {
      viewModel.systolicBpController.text = '';
      expect(viewModel.systolicStatus, isNull);
    });

    test('systolicStatus returns green for normal value', () {
      viewModel.systolicBpController.text = '120';
      expect(viewModel.systolicStatus, HealthMetricStatus.green);
    });

    test('diastolicStatus returns null when field is empty', () {
      viewModel.diastolicBpController.text = '';
      expect(viewModel.diastolicStatus, isNull);
    });

    test('bloodSugarStatus returns null when field is empty', () {
      viewModel.bloodSugarController.text = '';
      expect(viewModel.bloodSugarStatus, isNull);
    });

    test('bloodSugarStatus returns green for normal fasting value', () {
      viewModel.bloodSugarController.text = '5.0';
      expect(viewModel.bloodSugarStatus, HealthMetricStatus.green);
    });
  });
}
