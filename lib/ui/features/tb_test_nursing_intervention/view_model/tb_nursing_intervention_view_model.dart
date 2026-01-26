import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:kenwell_health_app/domain/constants/enums.dart';

class TBNursingInterventionViewModel extends ChangeNotifier {
  /// Controls whether the Initial Assessment card (and related validations) show.
  bool get showInitialAssessment => false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- Initial Assessment ---
  String? windowPeriod; // 'N/A', 'Yes', 'No'
  final List<String> windowPeriodOptions = YesNoNA.values.labels;

  String? expectedResult; // 'N/A', 'Yes', 'No'
  final List<String> expectedResultOptions = YesNoNA.values.labels;

  String? difficultyDealingResult; // 'N/A', 'Yes', 'No'
  final List<String> difficultyOptions = YesNoNA.values.labels;

  String? urgentPsychosocial; // 'N/A', 'Yes', 'No'
  final List<String> urgentOptions = YesNoNA.values.labels;

  String? committedToChange; // 'N/A', 'Yes', 'No'
  final List<String> committedOptions = YesNoNA.values.labels;

  void setWindowPeriod(String? value) => _setValue(() => windowPeriod = value);
  void setExpectedResult(String? value) =>
      _setValue(() => expectedResult = value);
  void setDifficultyDealingResult(String? value) =>
      _setValue(() => difficultyDealingResult = value);
  void setUrgentPsychosocial(String? value) =>
      _setValue(() => urgentPsychosocial = value);
  void setCommittedToChange(String? value) =>
      _setValue(() => committedToChange = value);

  // --- Follow-up ---
  String? followUpLocation; // 'State clinic', 'Private doctor', 'Other'
  final List<String> followUpLocationOptions = FollowUpLocation.values.labels;
  final TextEditingController followUpOtherController = TextEditingController();
  final TextEditingController followUpDateController = TextEditingController();

  void setFollowUpLocation(String? value) {
    if (followUpLocation == value) return;
    followUpLocation = value;
    if (value != 'Other') followUpOtherController.clear();
    notifyListeners();
  }

  // --- Referral Nursing Interventions ---
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

  // --- Nurse Details ---
  final TextEditingController nurseFirstNameController =
      TextEditingController();
  final TextEditingController nurseLastNameController = TextEditingController();
  final TextEditingController rankController = TextEditingController();
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final TextEditingController sancNumberController = TextEditingController();
  final TextEditingController nurseDateController = TextEditingController();

  // --- New: initialise nurse date from event ---
  WellnessEvent? event;
  void initialiseWithEvent(WellnessEvent e) {
    if (event != null) return; // prevent multiple initializations
    event = e;
    if (nurseDateController.text.isEmpty) {
      nurseDateController.text = DateFormat('yyyy-MM-dd').format(e.date);
      notifyListeners();
    }
  }

  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  // --- Submission ---
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Validation ---
  bool get isFormValid {
    final requiresInitialAssessment = showInitialAssessment;
    final requiresFollowUp =
        showInitialAssessment && windowPeriod != null && windowPeriod == 'Yes';

    final initialAssessmentValid = !requiresInitialAssessment ||
        (windowPeriod != null &&
            expectedResult != null &&
            difficultyDealingResult != null &&
            urgentPsychosocial != null &&
            committedToChange != null);

    final followUpValid = !requiresFollowUp ||
        (followUpLocation != null &&
            (followUpLocation != 'Other' ||
                followUpOtherController.text.isNotEmpty));

    return formKey.currentState?.validate() == true &&
        initialAssessmentValid &&
        followUpValid &&
        (nursingReferralSelection != NursingReferralOption.patientNotReferred ||
            notReferredReasonController.text.isNotEmpty) &&
        nurseFirstNameController.text.isNotEmpty &&
        nurseLastNameController.text.isNotEmpty &&
        rankController.text.isNotEmpty &&
        sancNumberController.text.isNotEmpty &&
        nurseDateController.text.isNotEmpty &&
        signatureController.isNotEmpty;
  }

  /// Converts all fields to a Map
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
      'nursingReferralSelection': nursingReferralSelection?.name,
      'notReferredReason': notReferredReasonController.text,
      'hivTestingNurseFirstName': nurseFirstNameController.text,
      'hivTestingNurseLastName': nurseLastNameController.text,
      'hivTestingNurse':
          '${nurseFirstNameController.text} ${nurseLastNameController.text}'
              .trim(),
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

  void _setValue(VoidCallback setter) {
    setter();
    notifyListeners();
  }

  @override
  void dispose() {
    followUpOtherController.dispose();
    followUpDateController.dispose();
    notReferredReasonController.dispose();
    nurseFirstNameController.dispose();
    nurseLastNameController.dispose();
    rankController.dispose();
    signatureController.dispose();
    sancNumberController.dispose();
    nurseDateController.dispose();
    super.dispose();
  }
}
