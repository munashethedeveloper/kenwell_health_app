import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

enum TBNursingReferralOption {
  memberNotReferred,
  referredToGP,
  referredToStateHIVClinic,
  referredToOHConsultation,
}

class TBNursingInterventionViewModel extends ChangeNotifier {
  TBNursingReferralOption? selectedReferralOption;

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController sessionNotesController = TextEditingController();
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool get hasSignature => signatureController.isNotEmpty;

  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  void setReferralOption(TBNursingReferralOption? option) {
    if (selectedReferralOption == option) return;
    selectedReferralOption = option;
    if (option != TBNursingReferralOption.memberNotReferred) {
      reasonController.clear();
    }
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedReferralOption': selectedReferralOption?.name,
      'reason': reasonController.text,
      'sessionNotes': sessionNotesController.text,
      'hasSignature': signatureController.isNotEmpty,
    };
  }

  Future<void> saveIntervention({VoidCallback? onNext}) async {
    final data = toMap();
    debugPrint('✅ TB Nursing Intervention Saved: $data');
    await Future.delayed(const Duration(milliseconds: 500));
    if (onNext != null) {
      onNext();
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    sessionNotesController.dispose();
    signatureController.dispose();

    super.dispose();
  }
}
