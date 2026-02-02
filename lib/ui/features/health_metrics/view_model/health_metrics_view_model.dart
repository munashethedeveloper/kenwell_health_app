import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'dart:math';

// ViewModel for managing health metrics input and submission
class HealthMetricsViewModel extends ChangeNotifier {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Controllers for health metric fields
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController systolicBpController = TextEditingController();
  final TextEditingController diastolicBpController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController bloodSugarController = TextEditingController();
  final TextEditingController waistController = TextEditingController();

  // Submission state
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Constructor
  HealthMetricsViewModel() {
    heightController.addListener(_calculateBMI);
    weightController.addListener(_calculateBMI);
  }

  // Calculate BMI based on height and weight inputs
  void _calculateBMI() {
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    // Convert cm to meters if entered > 3
    if (height != null && height > 3) {
      height = height / 100;
    }

    // Calculate BMI
    if (height != null && weight != null && height > 0) {
      final bmi = weight / pow(height, 2);
      bmiController.text = bmi.toStringAsFixed(2);
    } else {
      bmiController.text = '';
    }

    notifyListeners();
  }

  // Check if the form is valid
  bool get isFormValid => formKey.currentState?.validate() ?? false;

  // Convert health metrics to a map
  Map<String, dynamic> toMap() {
    return {
      'height': heightController.text,
      'weight': weightController.text,
      'bmi': bmiController.text,
      'bloodPressureSystolic': systolicBpController.text,
      'bloodPressureDiastolic': diastolicBpController.text,
      'cholesterol': cholesterolController.text,
      'bloodSugar': bloodSugarController.text,
      'waist': waistController.text,
    };
  }

  // Submit health metrics results
  Future<void> submitResults(
    BuildContext context, {
    required VoidCallback onNext,
    // required VoidCallback onError,
  }) async {
    // Validate form before submission
    if (!isFormValid) {
      AppSnackbar.showWarning(
        context,
        'Please complete all required fields',
      );
      return;
    }

    // Set submitting state
    _isSubmitting = true;
    notifyListeners();

    // Simulate submission delay
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) return;

      AppSnackbar.showSuccess(
        context,
        'Health metrics saved successfully',
      );

      // Call onNext callback after successful submission
      onNext();
    } catch (e) {
      // Handle submission error
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          'Error saving health metrics: $e',
        );
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    bmiController.dispose();
    systolicBpController.dispose();
    diastolicBpController.dispose();
    cholesterolController.dispose();
    bloodSugarController.dispose();
    waistController.dispose();
    super.dispose();
  }
}
