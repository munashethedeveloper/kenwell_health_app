import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

enum FollowUpLocationOption {
  stateClinic,
  privateDoctor,
  other,
}

class HIVTestNursingInterventionViewModel extends ChangeNotifier {
  // --- 1. Window period ---
  String windowPeriod = 'N/A';

  // --- 2. Follow-up location ---
  FollowUpLocationOption? followUpLocation;
  final TextEditingController followUpOtherDetailsController =
      TextEditingController();

  // --- 3. Follow-up date ---
  final TextEditingController followUpDateController = TextEditingController();

  // --- 4. Expected result ---
  String expectedResult = 'N/A';

  // --- 5. Difficulty dealing with result ---
  String difficultyResult = 'N/A';

  // --- 6. Psychosocial follow-up ---
  String psychosocialFollowUp = 'N/A';

  // --- 7. Behavior change commitment ---
  String behaviorChange = 'N/A';

  // --- Section F: Referrals ---
  bool notReferred = false;
  final TextEditingController notReferredReasonController =
      TextEditingController();
  bool referredGP = false;
  bool referredHIVClinic = false;

  // --- Notes ---
  final TextEditingController sessionNotesController = TextEditingController();
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  HIVTestNursingInterventionViewModel() {
    signatureController.addListener(_onSignatureChanged);
  }

  // --- Submitting ---
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  void clearSignature() {
    signatureController.clear();
  }

  // --- Setters ---
  void setWindowPeriod(String value) {
    windowPeriod = value;
    notifyListeners();
  }

  void setFollowUpLocation(FollowUpLocationOption? value) {
    followUpLocation = value;
    if (value != FollowUpLocationOption.other) {
      followUpOtherDetailsController.clear();
    }
    notifyListeners();
  }

  Future<void> pickFollowUpDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      followUpDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      notifyListeners();
    }
  }

  void setExpectedResult(String value) {
    expectedResult = value;
    notifyListeners();
  }

  void setDifficultyResult(String value) {
    difficultyResult = value;
    notifyListeners();
  }

  void setPsychosocialFollowUp(String value) {
    psychosocialFollowUp = value;
    notifyListeners();
  }

  void setBehaviorChange(String value) {
    behaviorChange = value;
    notifyListeners();
  }

  void setNotReferred(bool value) {
    notReferred = value;
    if (!value) notReferredReasonController.clear();
    notifyListeners();
  }

  void setReferredGP(bool value) {
    referredGP = value;
    notifyListeners();
  }

  void setReferredHIVClinic(bool value) {
    referredHIVClinic = value;
    notifyListeners();
  }

  // --- Form validation ---
  bool get isFormValid {
    if (windowPeriod.isEmpty) return false;
      if (followUpLocation == null) return false;
      if (followUpLocation == FollowUpLocationOption.other &&
          followUpOtherDetailsController.text.trim().isEmpty) {
      return false;
    }
    if (notReferred && notReferredReasonController.text.trim().isEmpty) {
      return false;
    }
    if (signatureController.isEmpty) return false;

    return true;
  }

  /// ✅ Converts all HIV Test Nursing Intervention data to a Map
  Map<String, dynamic> toMap() {
    return {
      'windowPeriod': windowPeriod,
        'followUpLocation': followUpLocation?.name,
      'followUpOtherDetails': followUpOtherDetailsController.text,
      'followUpDate': followUpDateController.text,
      'expectedResult': expectedResult,
      'difficultyResult': difficultyResult,
      'psychosocialFollowUp': psychosocialFollowUp,
      'behaviorChange': behaviorChange,
      'notReferred': notReferred,
      'notReferredReason': notReferredReasonController.text,
      'referredGP': referredGP,
      'referredHIVClinic': referredHIVClinic,
      'sessionNotes': sessionNotesController.text,
      'hasSignature': signatureController.isNotEmpty,
    };
  }

  // --- Submit & continue ---
  Future<void> submitIntervention(VoidCallback? onNext) async {
    if (!isFormValid) return;

    _isSubmitting = true;
    notifyListeners();

    debugPrint('--- HIV Test Nursing Intervention Saved ---');
    debugPrint(toMap().toString());

    await Future.delayed(const Duration(milliseconds: 500));

    _isSubmitting = false;
    notifyListeners();

    onNext?.call();
  }

  void _onSignatureChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    followUpOtherDetailsController.dispose();
    followUpDateController.dispose();
    notReferredReasonController.dispose();
    sessionNotesController.dispose();
    super.dispose();
  }
}
