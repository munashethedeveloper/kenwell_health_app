import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/hct_screening.dart';
import 'package:kenwell_health_app/domain/usecases/submit_hct_screening_usecase.dart';
import 'package:uuid/uuid.dart';

// ViewModel for managing HIV Test form state and submission
class HIVTestViewModel extends ChangeNotifier {
  HIVTestViewModel({SubmitHCTScreeningUseCase? submitHCTScreeningUseCase})
      : _submitHCTScreeningUseCase =
            submitHCTScreeningUseCase ?? SubmitHCTScreeningUseCase();

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final SubmitHCTScreeningUseCase _submitHCTScreeningUseCase;

  // Member and Event IDs
  String? _memberId;
  String? _eventId;

  // Set memberId and eventId
  void setMemberAndEventId(String memberId, String eventId) {
    _memberId = memberId;
    _eventId = eventId;
  }

  // --- 1. Questions ---
  String? firstHIVTest; // Yes/No
  TextEditingController lastTestMonthController = TextEditingController();
  TextEditingController lastTestYearController = TextEditingController();
  String? lastTestResult; // Positive/Negative

  String? sharedNeedles; // Yes/No
  String? unprotectedSex; // Yes/No
  String? treatedSTI; // Yes/No
  String? treatedTB; // Yes/No
  String? noCondomUse; // Yes/No
  TextEditingController noCondomReasonController = TextEditingController();

  String? knowPartnerStatus; // Yes/No

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Setters ---
  void setFirstHIVTest(String? value) {
    if (firstHIVTest == value) return;
    firstHIVTest = value;
    notifyListeners();
  }

  void setLastTestResult(String? value) {
    if (lastTestResult == value) return;
    lastTestResult = value;
    notifyListeners();
  }

  void setSharedNeedles(String? value) {
    if (sharedNeedles == value) return;
    sharedNeedles = value;
    notifyListeners();
  }

  void setUnprotectedSex(String? value) {
    if (unprotectedSex == value) return;
    unprotectedSex = value;
    notifyListeners();
  }

  void setTreatedSTI(String? value) {
    if (treatedSTI == value) return;
    treatedSTI = value;
    notifyListeners();
  }

  void setTreatedTB(String? value) {
    if (treatedTB == value) return;
    treatedTB = value;
    notifyListeners();
  }

  void setNoCondomUse(String? value) {
    if (noCondomUse == value) return;
    noCondomUse = value;
    if (value != 'Yes') noCondomReasonController.clear();
    notifyListeners();
  }

  void setKnowPartnerStatus(String? value) {
    if (knowPartnerStatus == value) return;
    knowPartnerStatus = value;
    notifyListeners();
  }

  // Check if form is valid
  bool get isFormValid {
    return formKey.currentState?.validate() == true;
  }

  // Convert form data to map
  Map<String, dynamic> toMap() {
    return {
      'firstHIVTest': firstHIVTest,
      'lastTestMonth': lastTestMonthController.text,
      'lastTestYear': lastTestYearController.text,
      'lastTestResult': lastTestResult,
      'sharedNeedles': sharedNeedles,
      'unprotectedSex': unprotectedSex,
      'treatedSTI': treatedSTI,
      'treatedTB': treatedTB,
      'noCondomUse': noCondomUse,
      'noCondomReason': noCondomReasonController.text,
      'knowPartnerStatus': knowPartnerStatus,
    };
  }

  // Submit HIV Test form
  Future<void> submitHIVTest({
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
      final screening = HctScreening(
        id: const Uuid().v4(),
        memberId: _memberId!,
        eventId: _eventId!,
        firstHctTest: firstHIVTest,
        lastTestMonth: lastTestMonthController.text.isEmpty
            ? null
            : lastTestMonthController.text,
        lastTestYear: lastTestYearController.text.isEmpty
            ? null
            : lastTestYearController.text,
        lastTestResult: lastTestResult,
        sharedNeedles: sharedNeedles,
        unprotectedSex: unprotectedSex,
        treatedSTI: treatedSTI,
        knowPartnerStatus: knowPartnerStatus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _submitHCTScreeningUseCase(screening);

      onSuccess?.call('HCT screening saved successfully');
      onNext?.call();
    } catch (e) {
      onError?.call('Error saving HCT screening: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    lastTestMonthController.dispose();
    lastTestYearController.dispose();
    noCondomReasonController.dispose();
    super.dispose();
  }
}
