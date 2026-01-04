import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:kenwell_health_app/data/services/firebase_auth_service.dart';

class HIVTestResultViewModel extends ChangeNotifier {
  HIVTestResultViewModel() {
    _loadCurrentUserProfile();
  }

  final FirebaseAuthService _authService = FirebaseAuthService();

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
  final List<String> windowPeriodOptions = ['N/A', 'Yes', 'No'];

  String? expectedResult; // 'N/A', 'Yes', 'No'
  final List<String> expectedResultOptions = ['N/A', 'Yes', 'No'];

  String? difficultyDealingResult; // 'N/A', 'Yes', 'No'
  final List<String> difficultyOptions = ['N/A', 'Yes', 'No'];

  String? urgentPsychosocial; // 'N/A', 'Yes', 'No'
  final List<String> urgentOptions = ['N/A', 'Yes', 'No'];

  String? committedToChange; // 'N/A', 'Yes', 'No'
  final List<String> committedOptions = ['N/A', 'Yes', 'No'];

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
  final List<String> followUpLocationOptions = [
    'Referred to State clinic',
    'Referred to Private doctor',
    'Other',
    'No follow-up needed',
  ];
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
      final user = await _authService.currentUser();
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

  // --- Pick expiry date ---
  Future<void> pickExpiryDate(BuildContext context,
      {required bool isScreening}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (isScreening) {
        screeningExpiryDateController.text = formattedDate;
      }
      notifyListeners();
    }
  }

  // --- Setters ---
  void setScreeningResult(String value) {
    screeningResult = value;
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

    // Validate referral reason if patient not referred
    if (nursingReferralSelection == NursingReferralOption.patientNotReferred &&
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
  Future<void> submitTestResult(VoidCallback? onNext) async {
    if (!isFormValid) {
      debugPrint("Form validation failed");
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final data = await toMap();
      debugPrint('✅ HIV Test Result Saved:');
      debugPrint(data.toString());

      await Future.delayed(const Duration(milliseconds: 500));

      _isSubmitting = false;
      notifyListeners();

      onNext?.call();
    } catch (e) {
      debugPrint("Error submitting HIV Test Result: $e");
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
