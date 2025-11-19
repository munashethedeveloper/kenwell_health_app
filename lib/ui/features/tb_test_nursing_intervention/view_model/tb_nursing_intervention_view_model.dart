import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class TBNursingInterventionViewModel extends ChangeNotifier {
  bool memberNotReferred = false;
  bool referredToGP = false;
  bool referredToStateHIVClinic = false;
  bool referredToOHConsultation = false;

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

  void toggleMemberNotReferred(bool? value) {
    memberNotReferred = value ?? false;
    if (!memberNotReferred) reasonController.clear();
    notifyListeners();
  }

  void toggleReferredToGP(bool? value) {
    referredToGP = value ?? false;
    notifyListeners();
  }

  void toggleReferredToStateHIVClinic(bool? value) {
    referredToStateHIVClinic = value ?? false;
    notifyListeners();
  }

  void toggleReferredToOHConsultation(bool? value) {
    referredToOHConsultation = value ?? false;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'memberNotReferred': memberNotReferred,
      'reason': reasonController.text,
      'referredToGP': referredToGP,
      'referredToStateHIVClinic': referredToStateHIVClinic,
      'referredToOHConsultation': referredToOHConsultation,
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
