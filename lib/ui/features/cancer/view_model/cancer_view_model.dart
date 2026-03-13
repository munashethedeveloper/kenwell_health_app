import 'package:flutter/material.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
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

  // --- Cancer sub-types from event services ---
  // Empty means "show all" (fallback when no services are specified).
  Set<String> _cancerSubTypes = {};

  void setCancerSubTypes(Set<String> types) {
    _cancerSubTypes = types;
    notifyListeners();
  }

  /// True when Breast Screening is relevant (or no sub-types set → show all).
  bool get showBreastScreening =>
      _cancerSubTypes.isEmpty || _cancerSubTypes.contains('Breast Screening');

  /// True when Pap Smear is relevant (or no sub-types set → show all).
  bool get showPapSmear =>
      _cancerSubTypes.isEmpty || _cancerSubTypes.contains('Pap Smear');

  /// True when PSA is relevant (or no sub-types set → show all).
  bool get showPsa =>
      _cancerSubTypes.isEmpty || _cancerSubTypes.contains('PSA');

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
    _autoApplyReferral();
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
    _autoApplyReferral();
    notifyListeners();
  }

  // --- PSA ---
  String? psaResults;

  void setPsaResults(String? value) {
    if (psaResults == value) return;
    psaResults = value;
    _autoApplyReferral();
    notifyListeners();
  }

  // --- Nursing Referral ---
  NursingReferralOption? nursingReferralSelection;
  final TextEditingController notReferredReasonController =
      TextEditingController();

  void setNursingReferralSelection(NursingReferralOption? value) {
    if (nursingReferralSelection == value) return;
    nursingReferralSelection = value;
    if (value != NursingReferralOption.patientNotReferred) {
      notReferredReasonController.clear();
    }
    notifyListeners();
  }

  // --- Risk classification ---

  /// True when all relevant exam findings are entered and none are abnormal.
  bool get isHealthy {
    // Determine which finding fields are relevant based on the consented sub-types
    final breastRelevant = showBreastScreening;
    final papRelevant = showPapSmear;
    final psaRelevant = showPsa;

    final breastOk = !breastRelevant || breastLightExamFindings == 'Normal';
    final papOk = !papRelevant ||
        (papSmearResults == 'Normal' || papSmearResults == 'Pending');
    final psaOk = !psaRelevant || psaResults == 'Normal';

    // At least one finding type must be present for the "healthy" state
    final anyRelevant = breastRelevant || papRelevant || psaRelevant;
    return anyRelevant && breastOk && papOk && psaOk && !isAtRisk;
  }

  /// Automatically set the nursing referral based on current finding state.
  void _autoApplyReferral() {
    if (isAtRisk) {
      if (nursingReferralSelection == null ||
          nursingReferralSelection ==
              NursingReferralOption.patientNotReferred) {
        nursingReferralSelection = NursingReferralOption.referredToStateClinic;
        notReferredReasonController.clear();
      }
    } else if (isHealthy) {
      nursingReferralSelection = NursingReferralOption.patientNotReferred;
    }
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

  /* // --- Nursing Referral ---
  NursingReferralOption? nursingReferralSelection;
  final TextEditingController notReferredReasonController =
      TextEditingController();

  void setNursingReferralSelection(NursingReferralOption? value) {
    if (nursingReferralSelection == value) return;
    nursingReferralSelection = value;
    if (value != NursingReferralOption.patientNotReferred) {
      notReferredReasonController.clear();
    }
    notifyListeners();
  } */

  /// True when any symptom, exam finding, or medical history flag indicates
  /// that the patient requires follow-up (at risk).
  bool get isAtRisk =>
      previousCancerDiagnosis == 'Yes' ||
      familyHistoryOfCancer == 'Yes' ||
      breastLump == 'Yes' ||
      abnormalBleeding == 'Yes' ||
      urinaryDifficulty == 'Yes' ||
      weightLoss == 'Yes' ||
      persistentPain == 'Yes' ||
      breastLightExamFindings == 'Abnormal' ||
      papSmearResults == 'Abnormal' ||
      psaResults == 'Abnormal';

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isFormValid {
    if (formKey.currentState?.validate() != true) return false;
    // Validate nursing referral only when the patient is at risk
    if (isAtRisk) {
      if (nursingReferralSelection == null) return false;
      if (nursingReferralSelection ==
              NursingReferralOption.patientNotReferred &&
          notReferredReasonController.text.isEmpty) return false;
    }
    return true;
  }

  Future<void> submitCancerScreening({
    VoidCallback? onNext,
    void Function(String)? onValidationFailed,
    void Function(String)? onSuccess,
    void Function(String)? onError,
  }) async {
    if (!isFormValid) {
      onValidationFailed?.call('Please complete all required fields');
      return;
    }

    if (_memberId == null || _eventId == null) {
      onError?.call('Missing member or event information');
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
        nursingReferral: isAtRisk ? nursingReferralSelection?.name : null,
        notReferredReason:
            isAtRisk && notReferredReasonController.text.isNotEmpty
                ? notReferredReasonController.text
                : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addCancerScreening(screening);

      onSuccess?.call('Cancer screening saved successfully');
      onNext?.call();
    } catch (e) {
      onError?.call('Error saving cancer screening: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    otherConditionController.dispose();
    notReferredReasonController.dispose();
    referredFacilityController.dispose();
    followUpDateController.dispose();
    consentObtainedController.dispose();
    clinicianNameController.dispose();
    clinicianSignatureController.dispose();
    clinicianNotesController.dispose();
    super.dispose();
  }
}
