import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class NurseInterventionViewModel extends ChangeNotifier {
  // 1. Window period risk assessment
  String? windowPeriod; // 'N/A', 'Yes', 'No'
  final List<String> windowPeriodOptions = ['N/A', 'Yes', 'No'];

  void setWindowPeriod(String? value) {
    if (windowPeriod == value) return;
    windowPeriod = value;
    notifyListeners();
  }

  // 2. Follow-up location
  String? followUpLocation; // 'State clinic', 'Private doctor', 'Other'
  final List<String> followUpLocationOptions = [
    'State clinic',
    'Private doctor',
    'Other'
  ];
  final TextEditingController followUpOtherController = TextEditingController();

  void setFollowUpLocation(String? value) {
    if (followUpLocation == value) return;
    followUpLocation = value;
    if (value != 'Other') {
      followUpOtherController.clear();
    }
    notifyListeners();
  }

  // 3. Follow-up test date
  final TextEditingController followUpDateController = TextEditingController();

  // 4. Expected HIV result
  String? expectedResult; // 'N/A', 'Yes', 'No'
  final List<String> expectedResultOptions = ['N/A', 'Yes', 'No'];

  void setExpectedResult(String? value) {
    if (expectedResult == value) return;
    expectedResult = value;
    notifyListeners();
  }

  // 5. Difficulty in dealing with result
  String? difficultyDealingResult; // 'N/A', 'Yes', 'No'
  final List<String> difficultyOptions = ['N/A', 'Yes', 'No'];

  void setDifficultyDealingResult(String? value) {
    if (difficultyDealingResult == value) return;
    difficultyDealingResult = value;
    notifyListeners();
  }

  // 6. Urgent psychosocial follow-up
  String? urgentPsychosocial; // 'N/A', 'Yes', 'No'
  final List<String> urgentOptions = ['N/A', 'Yes', 'No'];

  void setUrgentPsychosocial(String? value) {
    if (urgentPsychosocial == value) return;
    urgentPsychosocial = value;
    notifyListeners();
  }

  // 7. Commitment to behavior change
  String? committedToChange; // 'N/A', 'Yes', 'No'
  final List<String> committedOptions = ['N/A', 'Yes', 'No'];

  void setCommittedToChange(String? value) {
    if (committedToChange == value) return;
    committedToChange = value;
    notifyListeners();
  }

  // Referral Nursing Interventions
  bool patientNotReferred = false;
  final TextEditingController notReferredReasonController =
      TextEditingController();
  bool referredToGP = false;
  bool referredToStateClinic = false;

  void setPatientNotReferred(bool value) {
    if (patientNotReferred == value) return;
    patientNotReferred = value;
    if (!value) {
      notReferredReasonController.clear();
    }
    notifyListeners();
  }

  void setReferredToGP(bool value) {
    if (referredToGP == value) return;
    referredToGP = value;
    notifyListeners();
  }

  void setReferredToStateClinic(bool value) {
    if (referredToStateClinic == value) return;
    referredToStateClinic = value;
    notifyListeners();
  }

  // Nurse Details
  final TextEditingController hivTestingNurseController =
      TextEditingController();
  final TextEditingController rankController = TextEditingController();
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final TextEditingController sancNumberController = TextEditingController();
  final TextEditingController nurseDateController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isFormValid {
    if (windowPeriod == null ||
        (windowPeriod == 'Yes' && followUpLocation == null) ||
        expectedResult == null ||
        difficultyDealingResult == null ||
        urgentPsychosocial == null ||
        committedToChange == null) {
      return false;
    }
    if (followUpLocation == 'Other' && followUpOtherController.text.isEmpty) {
      return false;
    }
    if (patientNotReferred && notReferredReasonController.text.isEmpty) {
      return false;
    }

    // Nurse details must not be empty
    if (hivTestingNurseController.text.isEmpty ||
        rankController.text.isEmpty ||
        signatureController.isEmpty ||
        sancNumberController.text.isEmpty ||
        nurseDateController.text.isEmpty) {
      return false;
    }

    return true;
  }

  /// ✅ Converts all fields to Map for submission
  Future<Map<String, dynamic>> toMap() async {
    final signatureBytes = await signatureController.toPngBytes();

    return {
      'windowPeriod': windowPeriod,
      'followUpLocation': followUpLocation,
      'followUpOther': followUpOtherController.text,
      'followUpDate': followUpDateController.text,
      'expectedResult': expectedResult,
      'difficultyDealingResult': difficultyDealingResult,
      'urgentPsychosocial': urgentPsychosocial,
      'committedToChange': committedToChange,
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
      await toMap(); // Ensure signature bytes are included
      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) {
        return;
      }

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
