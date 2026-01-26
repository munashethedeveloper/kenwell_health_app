import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_tb_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:kenwell_health_app/domain/constants/enums.dart';

class TBTestingViewModel extends ChangeNotifier {
  // Note: formKey is now defined here
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirestoreTbScreeningRepository _repository =
      FirestoreTbScreeningRepository();

  String? _memberId;
  String? _eventId;

  void setMemberAndEventId(String memberId, String eventId) {
    _memberId = memberId;
    _eventId = eventId;
  }

  /// Controls whether the Initial Assessment card (and related validations) show.
  bool get showInitialAssessment => false;

  // --- TB screening questions ---
  String? coughTwoWeeks;
  //String? sputumColour;
  String? bloodInSputum;
  String? weightLoss;
  String? nightSweats;
  //String? feverChills;
  // String? chestPain;
  // String? swellings;

  void setCoughTwoWeeks(String? value) {
    if (coughTwoWeeks == value) return;
    coughTwoWeeks = value;
    notifyListeners();
  }

  //void setSputumColour(String? value) {
  //  if (sputumColour == value) return;
  //  sputumColour = value;
  //  notifyListeners();
  // }

  void setBloodInSputum(String? value) {
    if (bloodInSputum == value) return;
    bloodInSputum = value;
    notifyListeners();
  }

  void setWeightLoss(String? value) {
    if (weightLoss == value) return;
    weightLoss = value;
    notifyListeners();
  }

  void setNightSweats(String? value) {
    if (nightSweats == value) return;
    nightSweats = value;
    notifyListeners();
  }

  //void setFeverChills(String? value) {
  // if (feverChills == value) return;
  //  feverChills = value;
  //  notifyListeners();
  //}

  //void setChestPain(String? value) {
  // if (chestPain == value) return;
  // chestPain = value;
  // notifyListeners();
  //}

  //void setSwellings(String? value) {
  // if (swellings == value) return;
  //  swellings = value;
  //  notifyListeners();
  //}

  // --- TB history ---
  String? treatedBefore;
  TextEditingController treatedDateController = TextEditingController();
  String? completedTreatment;
  String? contactWithTB;

  void setTreatedBefore(String? value) {
    if (treatedBefore == value) return;
    treatedBefore = value;
    if (value != 'Yes') {
      treatedDateController.clear();
      completedTreatment = null;
      contactWithTB = null;
    }
    notifyListeners();
  }

  void setCompletedTreatment(String? value) {
    if (completedTreatment == value) return;
    completedTreatment = value;
    notifyListeners();
  }

  void setContactWithTB(String? value) {
    if (contactWithTB == value) return;
    contactWithTB = value;
    notifyListeners();
  }

  // --- Nursing Intervention Fields (previously from mixin) ---

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

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Form validation ---
  bool get isFormValid {
    // Validate both TB test fields and nurse intervention fields
    final baseTBValid = coughTwoWeeks != null &&
        //sputumColour != null &&
        bloodInSputum != null &&
        weightLoss != null &&
        nightSweats != null &&
        // feverChills != null &&
        // chestPain != null &&
        // swellings != null &&
        treatedBefore != null &&
        (treatedBefore == 'Yes'
            ? (completedTreatment != null &&
                contactWithTB != null &&
                treatedDateController.text.isNotEmpty)
            : true);

    // Nurse intervention validation
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

    final nurseInterventionValid = initialAssessmentValid &&
        followUpValid &&
        nursingReferralSelection != null &&
        (nursingReferralSelection != NursingReferralOption.patientNotReferred ||
            notReferredReasonController.text.isNotEmpty) &&
        signatureController.isNotEmpty;

    return baseTBValid && nurseInterventionValid;
  }

  /// ✅ Converts all TB Test data to a Map
  Future<Map<String, dynamic>> toMap() async {
    // Get signature bytes
    final signatureBytes = await signatureController.toPngBytes();

    // Combine TB test data with nurse intervention data
    return {
      'coughTwoWeeks': coughTwoWeeks,
      //  'sputumColour': sputumColour,
      'bloodInSputum': bloodInSputum,
      'weightLoss': weightLoss,
      'nightSweats': nightSweats,
      // 'feverChills': feverChills,
      // 'chestPain': chestPain,
      // 'swellings': swellings,
      'treatedBefore': treatedBefore,
      'treatedDate': treatedDateController.text,
      'completedTreatment': completedTreatment,
      'contactWithTB': contactWithTB,
      // Merge nurse intervention data
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

  // --- Submit & continue ---
  Future<void> submitTBTest(BuildContext context,
      {VoidCallback? onNext}) async {
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
      // Convert signature to base64
      final signatureBytes = await signatureController.toPngBytes();
      final signatureBase64 =
          signatureBytes != null ? base64Encode(signatureBytes) : null;

      final screening = TbScreening(
        id: const Uuid().v4(),
        memberId: _memberId!,
        eventId: _eventId!,
        coughTwoWeeks: coughTwoWeeks,
        bloodInSputum: bloodInSputum,
        weightLoss: weightLoss,
        nightSweats: nightSweats,
        treatedBefore: treatedBefore,
        treatedDate: treatedDateController.text.isEmpty
            ? null
            : treatedDateController.text,
        completedTreatment: completedTreatment,
        contactWithTB: contactWithTB,
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

      await _repository.addTbScreening(screening);

      if (!context.mounted) return;

      AppSnackbar.showSuccess(
        context,
        'TB screening saved successfully',
      );

      onNext?.call();
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          'Error saving TB screening: $e',
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
    treatedDateController.dispose();
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
