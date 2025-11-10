import 'package:flutter/material.dart';

class HIVTestViewModel extends ChangeNotifier {
  // --- 1. Questions ---
  String? firstHIVTest; // Yes/No
  TextEditingController lastTestMonthController = TextEditingController();
  TextEditingController lastTestYearController = TextEditingController();
  String? lastTestResult; // Positive/Negative
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

  String? sharedNeedles; // Yes/No
  String? unprotectedSex; // Yes/No
  String? treatedSTI; // Yes/No
  String? treatedTB; // Yes/No
  String? noCondomUse; // Yes/No
  TextEditingController noCondomReasonController = TextEditingController();
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
    if (value != 'Yes') {
      noCondomReasonController.clear();
    }
    notifyListeners();
  }

  String? knowPartnerStatus; // Yes/No
  void setKnowPartnerStatus(String? value) {
    if (knowPartnerStatus == value) return;
    knowPartnerStatus = value;
    notifyListeners();
  }

  List<String> riskReasons = [];
  TextEditingController otherRiskReasonController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Methods ---
  void toggleRiskReason(String reason) {
    if (riskReasons.contains(reason)) {
      riskReasons.remove(reason);
    } else {
      riskReasons.add(reason);
    }
    notifyListeners();
  }

  bool get isFormValid {
    if (firstHIVTest == null) return false;
    if (firstHIVTest == "No") {
      if (lastTestMonthController.text.isEmpty ||
          lastTestYearController.text.isEmpty ||
          lastTestResult == null) {
        return false;
      }
    }
    if (sharedNeedles == null ||
        unprotectedSex == null ||
        treatedSTI == null ||
        treatedTB == null ||
        noCondomUse == null ||
        knowPartnerStatus == null) {
      return false;
    }
    if (noCondomUse == "Yes" && noCondomReasonController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  /// ✅ Converts all HIV test data to Map
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
      'riskReasons': List<String>.from(riskReasons),
      'otherRiskReason': otherRiskReasonController.text,
    };
  }

  Future<void> submitHIVTest(VoidCallback? onNext) async {
    if (!isFormValid) return;

    _isSubmitting = true;
    notifyListeners();

    // Simulate save operation
    debugPrint("✅ HIV Test Submitted:");
    debugPrint(toMap().toString());

    await Future.delayed(const Duration(seconds: 1));

    _isSubmitting = false;
    notifyListeners();

    // Move to next step
    onNext?.call();
  }

  @override
  void dispose() {
    lastTestMonthController.dispose();
    lastTestYearController.dispose();
    noCondomReasonController.dispose();
    otherRiskReasonController.dispose();
    super.dispose();
  }
}
