import 'package:flutter/material.dart';
import 'dart:math';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hra_repository.dart';
import 'package:kenwell_health_app/utils/logger.dart';
import 'package:kenwell_health_app/domain/constants/enums.dart';

class PersonalRiskAssessmentViewModel extends ChangeNotifier {
  final FirestoreHraRepository _hraRepository = FirestoreHraRepository();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Add this

  String? _memberId;
  String? _eventId;

  // Dropdown values
  String? smokingStatus;
  final List<String> smokingStatusOptions = YesNo.values.labels;

  String? drinkingStatus;
  final List<String> drinkingStatusOptions = YesNo.values.labels;

  String? exerciseStatus;
  final List<String> exerciseStatusOptions = YesNo.values.labels;

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

  // Health Metrics fields (merged from HealthMetricsViewModel)
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController systolicBpController = TextEditingController();
  final TextEditingController diastolicBpController = TextEditingController();
  final TextEditingController cholesterolController = TextEditingController();
  final TextEditingController bloodSugarController = TextEditingController();
  final TextEditingController waistController = TextEditingController();

  // Section 2: Exercise frequency (radio)
  String exerciseFrequency = '';

  // Constructor to set up BMI calculation listener
  PersonalRiskAssessmentViewModel() {
    heightController.addListener(_calculateBMI);
    weightController.addListener(_calculateBMI);
  }

  // Height threshold to determine if input is in centimeters (> 3) or meters
  static const double _heightCmThreshold = 3.0;

  void _calculateBMI() {
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    // Convert cm to meters if entered > threshold
    if (height != null && height > _heightCmThreshold) {
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

  //NEW
  // New fields to store personal details
  String? gender; // 'Male' or 'Female'
  int? age;

  void setPersonalDetails({required String gender, required int age}) {
    this.gender = gender;
    this.age = age;
    notifyListeners();
  }

  void setMemberAndEventId(String? memberId, String? eventId) {
    _memberId = memberId;
    _eventId = eventId;
  }

  bool get isFemale => gender == 'Female';
  bool get isMale => gender == 'Male';

  bool get showFemaleQuestions => isFemale;
  bool get showMaleQuestions => isMale;
  bool get showMammogramQuestion => isFemale && (age ?? 0) >= 40;
  bool get showProstateCheckQuestion => isMale && (age ?? 0) >= 40;

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

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  //Show Fields
  bool get showSmokingFields => smokingStatus == 'Yes';
  bool get showDrinkingFields => drinkingStatus == 'Yes';
  bool get showExerciseFields => exerciseStatus == 'Yes';

  bool get isFormValid {
    // Check form field validation
    if (formKey.currentState?.validate() != true) return false;

    // Check smoking status and related fields
    if (smokingStatus == null) return false;
    if (showSmokingFields) {
      if (smokeType.isEmpty) return false;
      if (dailySmokeController.text.isEmpty) return false;
    }

    // Check drinking status and related fields
    if (drinkingStatus == null) return false;
    if (showDrinkingFields && alcoholFrequency.isEmpty) return false;

    // Check exercise status and related fields
    if (exerciseStatus == null) return false;
    if (showExerciseFields && exerciseFrequency.isEmpty) return false;

    // Check female-specific questions if applicable
    if (showFemaleQuestions) {
      if (papSmear == null) return false;
      if (breastExam == null) return false;
      if (showMammogramQuestion && mammogram == null) return false;
    }

    // Check male-specific questions if applicable
    if (showProstateCheckQuestion && prostateCheck == null) return false;

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
      // Health metrics data (merged from HealthMetricsViewModel)
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

  Future<void> submitResults(
    BuildContext context, {
    required VoidCallback onNext,
  }) async {
    if (!isFormValid || !formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      // Create HRA screening object
      final hraScreening = HraScreening(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        memberId: _memberId,
        eventId: _eventId,
        chronicConditions: chronicConditions,
        otherCondition: otherConditionController.text.isNotEmpty
            ? otherConditionController.text
            : null,
        exerciseFrequency:
            exerciseFrequency.isNotEmpty ? exerciseFrequency : null,
        dailySmoke: dailySmokeController.text.isNotEmpty
            ? dailySmokeController.text
            : null,
        smokeType: smokeType.isNotEmpty ? smokeType : null,
        alcoholFrequency: alcoholFrequency.isNotEmpty ? alcoholFrequency : null,
        papSmear: papSmear?.toString(),
        breastExam: breastExam?.toString(),
        mammogram: mammogram?.toString(),
        prostateCheck: prostateCheck?.toString(),
        prostateTested: prostateTested?.toString(),
        height: heightController.text.isNotEmpty ? heightController.text : null,
        weight: weightController.text.isNotEmpty ? weightController.text : null,
        bmi: bmiController.text.isNotEmpty ? bmiController.text : null,
        bloodPressureSystolic: systolicBpController.text.isNotEmpty
            ? systolicBpController.text
            : null,
        bloodPressureDiastolic: diastolicBpController.text.isNotEmpty
            ? diastolicBpController.text
            : null,
        cholesterol: cholesterolController.text.isNotEmpty
            ? cholesterolController.text
            : null,
        bloodSugar: bloodSugarController.text.isNotEmpty
            ? bloodSugarController.text
            : null,
        waist: waistController.text.isNotEmpty ? waistController.text : null,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _hraRepository.addHraScreening(hraScreening);
      AppLogger.info('HRA screening saved successfully');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screening Results Saved!')),
      );

      onNext();
    } catch (e) {
      AppLogger.error('Failed to save HRA screening', e);
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
    otherConditionController.dispose();
    dailySmokeController.dispose();
    // Dispose health metrics controllers
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
