import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HIVTestNursingInterventionViewModel extends ChangeNotifier {
  // --- 1. Window period ---
  String windowPeriod = 'N/A';

  // --- 2. Follow-up location ---
  bool followUpClinic = false;
  bool followUpPrivateDoctor = false;
  bool followUpOther = false;
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

  // --- Submitting ---
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Setters for Yes/No Questions ---
  void setWindowPeriod(String value) {
    windowPeriod = value;
    notifyListeners();
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

  // --- Setters for Checkboxes ---
  void setFollowUpClinic(bool value) {
    followUpClinic = value;
    notifyListeners();
  }

  void setFollowUpPrivateDoctor(bool value) {
    followUpPrivateDoctor = value;
    notifyListeners();
  }

  void setFollowUpOther(bool value) {
    followUpOther = value;
    if (!value) followUpOtherDetailsController.clear();
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

  // --- Follow-up date handler ---
  void handleFollowUpDate(DateTime? date) {
    if (date == null) return; // ignore if no date selected
    followUpDateController.text = DateFormat('yyyy-MM-dd').format(date);
    notifyListeners();
  }

  // --- Form validation ---
  bool get isFormValid {
    if (windowPeriod.isEmpty) return false;
    if (followUpOther && followUpOtherDetailsController.text.trim().isEmpty) {
      return false;
    }
    if (notReferred && notReferredReasonController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  /// Converts all HIV Test Nursing Intervention data to a Map
  Map<String, dynamic> toMap() {
    return {
      'windowPeriod': windowPeriod,
      'followUpClinic': followUpClinic,
      'followUpPrivateDoctor': followUpPrivateDoctor,
      'followUpOther': followUpOther,
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

  @override
  void dispose() {
    followUpOtherDetailsController.dispose();
    followUpDateController.dispose();
    notReferredReasonController.dispose();
    sessionNotesController.dispose();
    super.dispose();
  }
}
