import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

enum WindowPeriod { NA, Yes, No }

enum FollowUpLocation { StateClinic, PrivateDoctor, Other }

enum ExpectedResult { NA, Yes, No }

enum DifficultyDealingResult { NA, Yes, No }

enum UrgentPsychosocial { NA, Yes, No }

enum CommittedToChange { NA, Yes, No }

class NurseInterventionViewModel extends ChangeNotifier {
  // =======================
  // Enum fields
  // =======================
  WindowPeriod? windowPeriod;
  FollowUpLocation? followUpLocation;
  ExpectedResult? expectedResult;
  DifficultyDealingResult? difficultyDealingResult;
  UrgentPsychosocial? urgentPsychosocial;
  CommittedToChange? committedToChange;

  // =======================
  // Checkbox fields
  // =======================
  bool patientNotReferred = false;
  bool referredToGP = false;
  bool referredToStateClinic = false;

  // =======================
  // Text controllers
  // =======================
  final TextEditingController followUpOtherController = TextEditingController();
  final TextEditingController followUpDateController = TextEditingController();
  final TextEditingController notReferredReasonController =
      TextEditingController();
  final TextEditingController hivTestingNurseController =
      TextEditingController();
  final TextEditingController rankController = TextEditingController();
  final TextEditingController sancNumberController = TextEditingController();
  final TextEditingController nurseDateController = TextEditingController();

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // =======================
  // Form state
  // =======================
  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // =======================
  // Constructor
  // =======================
  NurseInterventionViewModel() {
    [
      followUpOtherController,
      followUpDateController,
      notReferredReasonController,
      hivTestingNurseController,
      rankController,
      sancNumberController,
      nurseDateController,
    ].forEach((c) => c.addListener(_updateFormValidity));

    signatureController.addListener(_updateFormValidity);
  }

  // =======================
  // Reactive setters
  // =======================
  void toggleField(String field, dynamic value) {
    switch (field) {
      // Checkboxes
      case 'patientNotReferred':
        patientNotReferred = value ?? false;
        if (!patientNotReferred) notReferredReasonController.clear();
        break;
      case 'referredToGP':
        referredToGP = value ?? false;
        break;
      case 'referredToStateClinic':
        referredToStateClinic = value ?? false;
        break;

      // Enums
      case 'windowPeriod':
        windowPeriod = value;
        if (windowPeriod != WindowPeriod.Yes) {
          followUpOtherController.clear();
          followUpLocation = null;
        }
        break;
      case 'followUpLocation':
        followUpLocation = value;
        if (followUpLocation != FollowUpLocation.Other) {
          followUpOtherController.clear();
        }
        break;
      case 'expectedResult':
        expectedResult = value;
        break;
      case 'difficultyDealingResult':
        difficultyDealingResult = value;
        break;
      case 'urgentPsychosocial':
        urgentPsychosocial = value;
        break;
      case 'committedToChange':
        committedToChange = value;
        break;
    }

    _updateFormValidity();
    notifyListeners();
  }

  bool get isFollowUpOtherSelected =>
      followUpLocation == FollowUpLocation.Other;

  // =======================
  // Form validation
  // =======================
  void _updateFormValidity() {
    bool valid = true;

    // Enums required
    if (windowPeriod == null ||
        followUpLocation == null ||
        expectedResult == null ||
        difficultyDealingResult == null ||
        urgentPsychosocial == null ||
        committedToChange == null) {
      valid = false;
    }

    // Follow-up "Other" field
    if (isFollowUpOtherSelected && followUpOtherController.text.isEmpty) {
      valid = false;
    }

    // At least one checkbox
    if (!patientNotReferred && !referredToGP && !referredToStateClinic) {
      valid = false;
    }

    // Reason if patient not referred
    if (patientNotReferred && notReferredReasonController.text.isEmpty) {
      valid = false;
    }

    // Nurse details
    if (hivTestingNurseController.text.isEmpty ||
        rankController.text.isEmpty ||
        signatureController.isEmpty ||
        sancNumberController.text.isEmpty ||
        nurseDateController.text.isEmpty) {
      valid = false;
    }

    if (_isFormValid != valid) {
      _isFormValid = valid;
      notifyListeners();
    }
  }

  void clearSignature() {
    signatureController.clear();
    _updateFormValidity();
  }

  // =======================
  // Convert to Map
  // =======================
  Future<Map<String, dynamic>> toMap() async {
    final signatureBytes = await signatureController.toPngBytes();

    return {
      'windowPeriod': windowPeriod?.name,
      'followUpLocation': followUpLocation?.name,
      'followUpOther': followUpOtherController.text,
      'followUpDate': followUpDateController.text,
      'expectedResult': expectedResult?.name,
      'difficultyDealingResult': difficultyDealingResult?.name,
      'urgentPsychosocial': urgentPsychosocial?.name,
      'committedToChange': committedToChange?.name,
      'patientNotReferred': patientNotReferred,
      'notReferredReason': notReferredReasonController.text,
      'referredToGP': referredToGP,
      'referredToStateClinic': referredToStateClinic,
      'hivTestingNurse': hivTestingNurseController.text,
      'rank': rankController.text,
      'signature': signatureBytes,
      'sancNumber': sancNumberController.text,
      'nurseDate': nurseDateController.text,
    };
  }

  // =======================
  // Submit
  // =======================
  Future<void> submitIntervention(
      BuildContext context, VoidCallback? onNext) async {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await toMap();
      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intervention saved successfully!')),
      );

      onNext?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving interventions: $e')),
        );
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    followUpOtherController.dispose();
    followUpDateController.dispose();
    notReferredReasonController.dispose();
    hivTestingNurseController.dispose();
    rankController.dispose();
    signatureController.dispose();
    sancNumberController.dispose();
    nurseDateController.dispose();
    super.dispose();
  }
}
