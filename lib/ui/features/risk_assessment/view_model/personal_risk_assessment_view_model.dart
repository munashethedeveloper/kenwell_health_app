import 'package:flutter/material.dart';

class PersonalRiskAssessmentViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Add this

  // Dropdown values
  String? smokingStatus;
  final List<String> smokingStatusOptions = ['Yes', 'No'];

  String? drinkingStatus;
  final List<String> drinkingStatusOptions = ['Yes', 'No'];

  String? exerciseStatus;
  final List<String> exerciseStatusOptions = ['Yes', 'No'];

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
    'None': false,
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

  // --- Dropdown setters ---
  void setSmokingStatus(String? value) {
    if (smokingStatus != value) {
      smokingStatus = value;
      notifyListeners();
    }
  }

  void setDrinkingStatus(String? value) {
    if (drinkingStatus != value) {
      drinkingStatus = value;
      notifyListeners();
    }
  }

  void setExerciseStatus(String? value) {
    if (exerciseStatus != value) {
      exerciseStatus = value;
      notifyListeners();
    }
  }

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

  //Show Fields
  bool get showSmokingFields => smokingStatus == 'Yes';
  bool get showDrinkingFields => drinkingStatus == 'Yes';
  bool get showExerciseFields => exerciseStatus == 'Yes';

  bool get isFormValid {
    if (smokingStatus != null &&
        (showSmokingFields
            ? dailySmokeController.text.isNotEmpty
            : smokeType.isNotEmpty)) {
      return true;
    }
    if (drinkingStatus != null &&
        (showDrinkingFields || alcoholFrequency.isNotEmpty)) {
      return true;
    }
    if (exerciseStatus != null &&
        (showExerciseFields || exerciseFrequency.isNotEmpty)) {
      return true;
    }
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
