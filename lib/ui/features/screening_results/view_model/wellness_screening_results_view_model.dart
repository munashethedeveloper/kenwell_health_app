import 'package:flutter/material.dart';
import 'dart:math';

class WellnessScreeningResultsViewModel extends ChangeNotifier {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController bloodSugarController = TextEditingController();
  final TextEditingController waistController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  WellnessScreeningResultsViewModel() {
    heightController.addListener(_calculateBMI);
    weightController.addListener(_calculateBMI);
  }

  // ✅ Automatically calculate BMI when height or weight changes
  void _calculateBMI() {
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    // Convert cm to meters if user enters cm
    if (height != null && height > 3) {
      height = height / 100;
    }

    if (height != null && weight != null && height > 0) {
      final bmi = weight / pow(height, 2);
      bmiController.text = bmi.toStringAsFixed(2);
    } else {
      bmiController.text = '';
    }

    notifyListeners();
  }

  bool get isFormValid =>
      heightController.text.isNotEmpty &&
      weightController.text.isNotEmpty &&
      bloodPressureController.text.isNotEmpty &&
      cholesterolController.text.isNotEmpty &&
      bloodSugarController.text.isNotEmpty &&
      waistController.text.isNotEmpty;

  /// ✅ Converts all screening results to Map for submission
  Map<String, dynamic> toMap() {
    return {
      'height': heightController.text,
      'weight': weightController.text,
      'bmi': bmiController.text,
      'bloodPressure': bloodPressureController.text,
      'cholesterol': cholesterolController.text,
      'bloodSugar': bloodSugarController.text,
      'waist': waistController.text,
    };
  }

  Future<void> submitResults(
    BuildContext context, {
    required VoidCallback onNext,
  }) async {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screening Results Saved!')),
      );

      onNext(); // ✅ Move to Nurse Intervention Screen
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving results: $e')),
        );
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    bmiController.dispose();
    bloodPressureController.dispose();
    cholesterolController.dispose();
    bloodSugarController.dispose();
    waistController.dispose();
    super.dispose();
  }
}
