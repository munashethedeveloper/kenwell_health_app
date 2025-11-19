import 'package:flutter/material.dart';

class PersonalRiskAssessmentViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Add this

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

  final bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isFormValid {
    if (!formKey.currentState!.validate()) return false;
    if (exerciseFrequency.isEmpty || alcoholFrequency.isEmpty) return false;
    return true;
  }

  void toggleCondition(String condition, bool? value) {
    chronicConditions[condition] = value ?? false;
    notifyListeners();
  }

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

  @override
  void dispose() {
    otherConditionController.dispose();
    dailySmokeController.dispose();
    super.dispose();
  }
}
