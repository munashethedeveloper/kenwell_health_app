import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hiv_result_repository.dart';
import 'package:kenwell_health_app/domain/models/hiv_result.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:kenwell_health_app/domain/constants/enums.dart';

class HIVTestResultViewModel extends ChangeNotifier {
  HIVTestResultViewModel() {
    _loadCurrentUserProfile();
    // Initialize referral to Healthy since the default screening result is
    // Negative.  setScreeningResult() updates this whenever the nurse changes
    // the result dropdown.
    nursingReferralSelection = NursingReferralOption.patientNotReferred;
  }

  final AuthService _authService = AuthService();
  final FirestoreHivResultRepository _repository =
      FirestoreHivResultRepository();

  String? _memberId;
  String? _eventId;

  void setMemberAndEventId(String memberId, String eventId) {
    _memberId = memberId;
    _eventId = eventId;
  }

  // Note: formKey is defined here
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- Screening Test Controllers ---
  final TextEditingController screeningTestNameController =
      TextEditingController();
  final TextEditingController screeningBatchNoController =
      TextEditingController();
  final TextEditingController screeningExpiryDateController =
      TextEditingController();
  String screeningResult = 'Negative';

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

  /// Load current user profile to pre-populate nurse details
  Future<void> _loadCurrentUserProfile() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        nurseFirstNameController.text = user.firstName;
        nurseLastNameController.text = user.lastName;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading user profile: $e");
    }
  }

  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> pickExpiryDate(
      {required bool isScreening,
      Future<DateTime?> Function()? showPicker}) async {
    DateTime? picked = await showPicker?.call();
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (isScreening) {
        screeningExpiryDateController.text = formattedDate;
      }
      notifyListeners();
    }
  }

  /// True when the screening result indicates the patient is at risk (Positive).
  bool get isAtRisk => screeningResult == 'Positive';

  /// True when the screening result indicates a healthy/negative status.
  bool get isHealthy => screeningResult == 'Negative';

  // --- Setters ---
  void setScreeningResult(String value) {
    screeningResult = value;
    // Auto-set nursing referral based on test result
    if (value == 'Positive') {
      if (nursingReferralSelection == null ||
          nursingReferralSelection ==
              NursingReferralOption.patientNotReferred) {
        nursingReferralSelection = NursingReferralOption.referredToStateClinic;
        notReferredReasonController.clear();
      }
    } else {
      // Negative result → no referral needed
      nursingReferralSelection = NursingReferralOption.patientNotReferred;
    }
    notifyListeners();
  }

  // --- Form validation ---
  bool get isFormValid {
    // Validate form fields
    if (formKey.currentState?.validate() != true) {
      return false;
    }

    // Validate screening test fields
    if (screeningTestNameController.text.isEmpty ||
        screeningBatchNoController.text.isEmpty ||
        screeningExpiryDateController.text.isEmpty) {
      return false;
    }

    // Validate initial assessment fields
    if (windowPeriod == null ||
        urgentPsychosocial == null ||
        committedToChange == null) {
      return false;
    }

    // Validate nursing referral
    if (nursingReferralSelection == null) {
      return false;
    }

    // Validate referral reason only when the referral card is visible (Positive result)
    // and the nurse manually selected "not referred"
    if (isAtRisk &&
        nursingReferralSelection == NursingReferralOption.patientNotReferred &&
        notReferredReasonController.text.isEmpty) {
      return false;
    }

    // Validate nurse details
    if (nurseFirstNameController.text.isEmpty ||
        nurseLastNameController.text.isEmpty ||
        rankController.text.isEmpty ||
        sancNumberController.text.isEmpty ||
        nurseDateController.text.isEmpty) {
      return false;
    }

    // Validate signature
    if (signatureController.isEmpty) {
      return false;
    }

    return true;
  }

  /// Converts all HIV test result data to a Map
  Future<Map<String, dynamic>> toMap() async {
    final signatureBytes = await signatureController.toPngBytes();
    return {
      'screeningTestName': screeningTestNameController.text,
      'screeningBatchNo': screeningBatchNoController.text,
      'screeningExpiryDate': screeningExpiryDateController.text,
      'screeningResult': screeningResult,
      // Nursing intervention data
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

  // --- Save & continue ---
  Future<void> submitTestResult({
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
      // Convert signature to base64
      final signatureBytes = await signatureController.toPngBytes();
      final signatureBase64 =
          signatureBytes != null ? base64Encode(signatureBytes) : null;

      final result = HivResult(
        id: const Uuid().v4(),
        memberId: _memberId!,
        eventId: _eventId!,
        screeningTestName: screeningTestNameController.text,
        screeningBatchNo: screeningBatchNoController.text,
        screeningExpiryDate: screeningExpiryDateController.text,
        screeningResult: screeningResult,
        windowPeriod: windowPeriod,
        expectedResult: expectedResult,
        difficultyDealingResult: difficultyDealingResult,
        urgentPsychosocial: urgentPsychosocial,
        committedToChange: committedToChange,
        followUpLocation: followUpLocation,
        followUpOther: followUpOtherController.text.isEmpty
            ? null
            : followUpOtherController.text,
        followUpDate: followUpDateController.text.isEmpty
            ? null
            : followUpDateController.text,
        nursingReferral: nursingReferralSelection?.name,
        notReferredReason: notReferredReasonController.text.isEmpty
            ? null
            : notReferredReasonController.text,
        nurseFirstName: nurseFirstNameController.text,
        nurseLastName: nurseLastNameController.text,
        rank: rankController.text,
        sancNumber: sancNumberController.text,
        nurseDate: nurseDateController.text,
        signatureData: signatureBase64,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addHivResult(result);

      onSuccess?.call('HIV test result saved successfully');
      onNext?.call();
    } catch (e) {
      onError?.call('Error saving HIV test result: $e');
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
    screeningTestNameController.dispose();
    screeningBatchNoController.dispose();
    screeningExpiryDateController.dispose();
    // Dispose nursing intervention fields
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
