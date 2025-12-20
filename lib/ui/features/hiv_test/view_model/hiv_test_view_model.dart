import 'package:flutter/material.dart';

class HIVTestViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
  // List<String> riskReasons = [];
  // TextEditingController otherRiskReasonController = TextEditingController();

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

  //void toggleRiskReason(String reason) {
  //if (riskReasons.contains(reason)) {
  //riskReasons.remove(reason);
  //} else {
  //riskReasons.add(reason);
  // }
  //notifyListeners();
  // }

  bool get isFormValid {
    return formKey.currentState?.validate() == true;
  }

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
      //'riskReasons': List<String>.from(riskReasons),
      //'otherRiskReason': otherRiskReasonController.text,
    };
  }

  Future<void> submitHIVTest(VoidCallback? onNext) async {
    if (!isFormValid) return;

    _isSubmitting = true;
    notifyListeners();

    debugPrint("✅ HIV Test Submitted:");
    debugPrint(toMap().toString());

    await Future.delayed(const Duration(seconds: 1));

    _isSubmitting = false;
    notifyListeners();

    onNext?.call();
  }

  @override
  void dispose() {
    lastTestMonthController.dispose();
    lastTestYearController.dispose();
    noCondomReasonController.dispose();
    //otherRiskReasonController.dispose();
    super.dispose();
  }
}
