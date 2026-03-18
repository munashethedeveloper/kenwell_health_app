import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';

class CancerScreeningViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirestoreCancerScreeningRepository _repository =
      FirestoreCancerScreeningRepository();
  final AuthService _authService = AuthService();

  String? _memberId;
  String? _eventId;

  CancerScreeningViewModel() {
    _loadCurrentUserProfile();
  }

  /// Pre-populate nurse first/last name from the authenticated user profile.
  Future<void> _loadCurrentUserProfile() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        nurseFirstNameController.text = user.firstName;
        nurseLastNameController.text = user.lastName;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('CancerScreeningViewModel: failed to load profile: $e');
    }
  }

  void setMemberAndEventId(String memberId, String eventId) {
    _memberId = memberId;
    _eventId = eventId;
  }

  // --- Nurse / event initialisation ---
  WellnessEvent? _event;
  void initialiseWithEvent(WellnessEvent e) {
    if (_event != null) return;
    _event = e;
    if (nurseDateController.text.isEmpty) {
      nurseDateController.text = DateFormat('yyyy-MM-dd').format(e.date);
      notifyListeners();
    }
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
    _autoApplyReferral();
    notifyListeners();
  }

  void setFamilyHistoryOfCancer(String? value) {
    if (familyHistoryOfCancer == value) return;
    familyHistoryOfCancer = value;
    _autoApplyReferral();
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
    _autoApplyReferral();
    notifyListeners();
  }

  void setAbnormalBleeding(String? value) {
    if (abnormalBleeding == value) return;
    abnormalBleeding = value;
    _autoApplyReferral();
    notifyListeners();
  }

  void setUrinaryDifficulty(String? value) {
    if (urinaryDifficulty == value) return;
    urinaryDifficulty = value;
    _autoApplyReferral();
    notifyListeners();
  }

  void setWeightLoss(String? value) {
    if (weightLoss == value) return;
    weightLoss = value;
    _autoApplyReferral();
    notifyListeners();
  }

  void setPersistentPain(String? value) {
    if (persistentPain == value) return;
    persistentPain = value;
    _autoApplyReferral();
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

  /// Number of symptom questions answered 'Yes'.
  int get _symptomYesCount =>
      [breastLump, abnormalBleeding, urinaryDifficulty, weightLoss, persistentPain]
          .where((v) => v == 'Yes')
          .length;

  /// True when any medical history flag is set.
  bool get _hasMedicalHistory =>
      previousCancerDiagnosis == 'Yes' || familyHistoryOfCancer == 'Yes';

  /// True when any chronic condition (excluding 'None') is selected.
  bool get _hasChronicConditions =>
      chronicConditions.entries.any((e) => e.key != 'None' && e.value);

  /// True when exam findings indicate an abnormal result.
  bool get _hasAbnormalExam =>
      breastLightExamFindings == 'Abnormal' ||
      papSmearResults == 'Abnormal' ||
      psaResults == 'Abnormal';

  /// True when the patient is at high risk and should be auto-referred:
  /// - More than 3 symptom yeses, OR
  /// - Any exam finding is abnormal.
  bool get isHighRisk => _symptomYesCount > 3 || _hasAbnormalExam;

  /// True when any at-risk indicator is present (kept for submit logic).
  bool get isAtRisk => isHighRisk || isCaution;

  /// True when caution flags are present but the patient is not high risk.
  /// Nurse uses clinical discretion to classify as Healthy or At Risk.
  bool get isCaution =>
      !isHighRisk &&
      (_hasMedicalHistory || _hasChronicConditions || _symptomYesCount >= 1);

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
  /// - High risk (4+ symptom yeses or abnormal exam): auto-referred.
  /// - Healthy (all normal): auto-set to not referred.
  /// - Caution: leave selection unchanged so nurse can decide.
  void _autoApplyReferral() {
    if (isHighRisk) {
      if (nursingReferralSelection == null ||
          nursingReferralSelection ==
              NursingReferralOption.patientNotReferred) {
        nursingReferralSelection = NursingReferralOption.referredToStateClinic;
        notReferredReasonController.clear();
      }
    } else if (isHealthy) {
      nursingReferralSelection = NursingReferralOption.patientNotReferred;
    }
    // isCaution: no auto-change, nurse decides.
  }

  // --- Nurse / healthcare-practitioner details ---
  final TextEditingController nurseFirstNameController =
      TextEditingController();
  final TextEditingController nurseLastNameController = TextEditingController();
  final TextEditingController rankController = TextEditingController();

  /// Sets the nurse rank from the dropdown and syncs to [rankController].
  void setRank(String? value) {
    if (rankController.text == (value ?? '')) return;
    rankController.text = value ?? '';
    notifyListeners();
  }
  final TextEditingController sancNumberController = TextEditingController();
  final TextEditingController nurseDateController = TextEditingController();
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  /// Base64-encoded HP signature carried over from the consent form.
  /// When set, the signature pad is replaced by a read-only image.
  String? prefilledHpSignatureBase64;

  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

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
          notReferredReasonController.text.isEmpty) {
        return false;
      }
    }
    // Nurse details are always required.
    if (nurseFirstNameController.text.isEmpty ||
        nurseLastNameController.text.isEmpty ||
        rankController.text.isEmpty ||
        sancNumberController.text.isEmpty) {
      return false;
    }
    // Signature required — either drawn or pre-filled from consent.
    if (signatureController.isEmpty && prefilledHpSignatureBase64 == null) {
      return false;
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
      // Use drawn signature; fall back to consent HP signature if pad is empty.
      String? signatureBase64;
      if (signatureController.isNotEmpty) {
        final signatureBytes = await signatureController.toPngBytes();
        if (signatureBytes != null) signatureBase64 = base64Encode(signatureBytes);
      }
      signatureBase64 ??= prefilledHpSignatureBase64;

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
        referredFacility: null,
        followUpDate: null,
        consentObtained: null,
        clinicianName: null,
        clinicianSignature: null,
        clinicianNotes: null,
        nursingReferral: nursingReferralSelection?.name,
        notReferredReason: notReferredReasonController.text.isEmpty
            ? null
            : notReferredReasonController.text,
        nurseFirstName: nurseFirstNameController.text.isEmpty
            ? null
            : nurseFirstNameController.text,
        nurseLastName: nurseLastNameController.text.isEmpty
            ? null
            : nurseLastNameController.text,
        rank: rankController.text.isEmpty ? null : rankController.text,
        sancNumber:
            sancNumberController.text.isEmpty ? null : sancNumberController.text,
        nurseDate: nurseDateController.text.isEmpty
            ? null
            : nurseDateController.text,
        signatureData: signatureBase64,
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
    nurseFirstNameController.dispose();
    nurseLastNameController.dispose();
    rankController.dispose();
    sancNumberController.dispose();
    nurseDateController.dispose();
    signatureController.dispose();
    super.dispose();
  }
}
