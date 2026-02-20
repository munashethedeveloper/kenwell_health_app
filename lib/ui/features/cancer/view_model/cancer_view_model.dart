import 'package:flutter/material.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/cancer_screening.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:uuid/uuid.dart';

class CancerScreeningViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirestoreCancerScreeningRepository _repository =
      FirestoreCancerScreeningRepository();

  String? _memberId;
  String? _eventId;

  void setMemberAndEventId(String memberId, String eventId) {
    _memberId = memberId;
    _eventId = eventId;
  }

  // --- Medical History ---
  String? previousCancerDiagnosis;
  String? familyHistoryOfCancer;

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

  void setPreviousCancerDiagnosis(String? value) {
    if (previousCancerDiagnosis == value) return;
    previousCancerDiagnosis = value;
    notifyListeners();
  }

  void setFamilyHistoryOfCancer(String? value) {
    if (familyHistoryOfCancer == value) return;
    familyHistoryOfCancer = value;
    notifyListeners();
  }

  void toggleCondition(String condition, bool? value) {
    chronicConditions[condition] = value ?? false;
    notifyListeners();
  }

  // --- Symptoms ---
  String? breastLump;
  String? abnormalBleeding;
  String? urinaryDifficulty;
  String? weightLoss;
  String? persistentPain;

  void setBreastLump(String? value) {
    if (breastLump == value) return;
    breastLump = value;
    notifyListeners();
  }

  void setAbnormalBleeding(String? value) {
    if (abnormalBleeding == value) return;
    abnormalBleeding = value;
    notifyListeners();
  }

  void setUrinaryDifficulty(String? value) {
    if (urinaryDifficulty == value) return;
    urinaryDifficulty = value;
    notifyListeners();
  }

  void setWeightLoss(String? value) {
    if (weightLoss == value) return;
    weightLoss = value;
    notifyListeners();
  }

  void setPersistentPain(String? value) {
    if (persistentPain == value) return;
    persistentPain = value;
    notifyListeners();
  }

  // --- Breast Light Exam ---
  String? breastLightExamFindings;

  void setBreastLightExamFindings(String? value) {
    if (breastLightExamFindings == value) return;
    breastLightExamFindings = value;
    notifyListeners();
  }

  // --- Liquid Cytology / Pap Smear ---
  String? papSmearSpecimenCollected;
  String? papSmearResults;

  void setPapSmearSpecimenCollected(String? value) {
    if (papSmearSpecimenCollected == value) return;
    papSmearSpecimenCollected = value;
    notifyListeners();
  }

  void setPapSmearResults(String? value) {
    if (papSmearResults == value) return;
    papSmearResults = value;
    notifyListeners();
  }

  // --- PSA ---
  String? psaResults;

  void setPsaResults(String? value) {
    if (psaResults == value) return;
    psaResults = value;
    notifyListeners();
  }

  // --- Outcome & Referral ---
  final TextEditingController referredFacilityController =
      TextEditingController();
  final TextEditingController followUpDateController = TextEditingController();
  final TextEditingController consentObtainedController =
      TextEditingController();
  final TextEditingController clinicianNameController = TextEditingController();
  final TextEditingController clinicianSignatureController =
      TextEditingController();
  final TextEditingController clinicianNotesController =
      TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isFormValid => formKey.currentState?.validate() == true;

  Future<void> submitCancerScreening(
    BuildContext context, {
    VoidCallback? onNext,
  }) async {
    if (!isFormValid) {
      AppSnackbar.showWarning(
        context,
        'Please complete all required fields',
      );
      return;
    }

    if (_memberId == null || _eventId == null) {
      AppSnackbar.showError(
        context,
        'Missing member or event information',
      );
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final screening = CancerScreening(
        id: const Uuid().v4(),
        memberId: _memberId!,
        eventId: _eventId!,
        previousCancerDiagnosis: previousCancerDiagnosis,
        familyHistoryOfCancer: familyHistoryOfCancer,
        chronicConditions: Map.from(chronicConditions),
        otherCondition: otherConditionController.text.isEmpty
            ? null
            : otherConditionController.text,
        breastLump: breastLump,
        abnormalBleeding: abnormalBleeding,
        urinaryDifficulty: urinaryDifficulty,
        weightLoss: weightLoss,
        persistentPain: persistentPain,
        breastLightExamFindings: breastLightExamFindings,
        papSmearSpecimenCollected: papSmearSpecimenCollected,
        papSmearResults: papSmearResults,
        psaResults: psaResults,
        referredFacility: referredFacilityController.text.isEmpty
            ? null
            : referredFacilityController.text,
        followUpDate: followUpDateController.text.isEmpty
            ? null
            : followUpDateController.text,
        consentObtained: consentObtainedController.text.isEmpty
            ? null
            : consentObtainedController.text,
        clinicianName: clinicianNameController.text.isEmpty
            ? null
            : clinicianNameController.text,
        clinicianSignature: clinicianSignatureController.text.isEmpty
            ? null
            : clinicianSignatureController.text,
        clinicianNotes: clinicianNotesController.text.isEmpty
            ? null
            : clinicianNotesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addCancerScreening(screening);

      if (!context.mounted) return;

      AppSnackbar.showSuccess(
        context,
        'Cancer screening saved successfully',
      );

      onNext?.call();
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          'Error saving cancer screening: $e',
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
    referredFacilityController.dispose();
    followUpDateController.dispose();
    consentObtainedController.dispose();
    clinicianNameController.dispose();
    clinicianSignatureController.dispose();
    clinicianNotesController.dispose();
    super.dispose();
  }
}
