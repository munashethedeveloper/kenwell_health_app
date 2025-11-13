import 'package:flutter/material.dart';

class TBNursingInterventionViewModel extends ChangeNotifier {
  bool memberNotReferred = false;
  bool referredToGP = false;
  bool referredToStateHIVClinic = false;
  bool referredToOHConsultation = false;

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController sessionNotesController = TextEditingController();

  bool isSubmitting = false;

  /// Unified toggle method
  void toggleField(String key, bool? value) {
    final val = value ?? false;
    switch (key) {
      case 'memberNotReferred':
        memberNotReferred = val;
        if (!val) reasonController.clear();
        break;
      case 'referredToGP':
        referredToGP = val;
        break;
      case 'referredToStateHIVClinic':
        referredToStateHIVClinic = val;
        break;
      case 'referredToOHConsultation':
        referredToOHConsultation = val;
        break;
    }
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
    };
  }

  Future<void> saveIntervention({VoidCallback? onNext}) async {
    isSubmitting = true;
    notifyListeners();

    final data = toMap();
    debugPrint('✅ TB Nursing Intervention Saved: $data');

    await Future.delayed(const Duration(milliseconds: 500));

    isSubmitting = false;
    notifyListeners();

    if (onNext != null) onNext();
  }

  @override
  void dispose() {
    reasonController.dispose();
    sessionNotesController.dispose();
    super.dispose();
  }
}
