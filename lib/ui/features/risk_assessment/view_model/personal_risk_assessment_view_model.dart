import 'package:flutter/material.dart';

class PersonalRiskAssessmentViewModel extends ChangeNotifier {
  // Section 1: Chronic Health Conditions
  final Map<String, bool> chronicConditions = {
    'Heart Disease': false,
    'T.B': false,
    'High blood pressure': false,
    'Diabetes': false,
    'Cancer': false,
    'High cholesterol': false,
    'Depression': false,
    'Epilepsy': false,
    'Asthma': false,
    'Other': false,
  };

  final TextEditingController otherConditionController =
      TextEditingController();

  // Section 2: Exercise frequency (radio)
  String exerciseFrequency = '';

  void setExerciseFrequency(String value) {
    if (exerciseFrequency == value) return;
    exerciseFrequency = value;
    notifyListeners();
  }

  // Section 3: Smoking
  final TextEditingController dailySmokeController = TextEditingController();
  String smokeType = '';

  void setSmokeType(String value) {
    if (smokeType == value) return;
    smokeType = value;
    notifyListeners();
  }

  // Section 4: Alcohol use (radio)
  String alcoholFrequency = '';

  void setAlcoholFrequency(String value) {
    if (alcoholFrequency == value) return;
    alcoholFrequency = value;
    notifyListeners();
  }

  // Section 5-7: Women only
  bool? papSmear;
  bool? breastExam;
  bool? mammogram;

  void setPapSmear(bool? value) {
    if (papSmear == value) return;
    papSmear = value;
    notifyListeners();
  }

  void setBreastExam(bool? value) {
    if (breastExam == value) return;
    breastExam = value;
    notifyListeners();
  }

  void setMammogram(bool? value) {
    if (mammogram == value) return;
    mammogram = value;
    notifyListeners();
  }

  // Section 8-9: Men only
  bool? prostateCheck;
  bool? prostateTested;

  void setProstateCheck(bool? value) {
    if (prostateCheck == value) return;
    prostateCheck = value;
    notifyListeners();
  }

  void setProstateTested(bool? value) {
    if (prostateTested == value) return;
    prostateTested = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isFormValid {
    if (exerciseFrequency.isEmpty || alcoholFrequency.isEmpty) return false;
    if (chronicConditions['Other'] == true &&
        otherConditionController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void toggleCondition(String condition, bool? value) {
    chronicConditions[condition] = value ?? false;
    notifyListeners();
  }

  /// Returns a Map of all fields for submission
  Map<String, dynamic> toMap() {
    return {
      'chronicConditions': chronicConditions,
      'otherCondition': otherConditionController.text,
      'exerciseFrequency': exerciseFrequency,
      'dailySmoke': dailySmokeController.text,
      'smokeType': smokeType,
      'alcoholFrequency': alcoholFrequency,
      'papSmear': papSmear,
      'breastExam': breastExam,
      'mammogram': mammogram,
      'prostateCheck': prostateCheck,
      'prostateTested': prostateTested,
    };
  }

  Future<void> submitAssessment(BuildContext context) async {
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
      Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: $e')),
        );
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    otherConditionController.dispose();
    dailySmokeController.dispose();
    super.dispose();
  }
}
