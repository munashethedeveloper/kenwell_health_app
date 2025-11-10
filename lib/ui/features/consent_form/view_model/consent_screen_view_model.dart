import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class ConsentScreenViewModel extends ChangeNotifier {
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  final TextEditingController venueController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController practitionerController = TextEditingController();

  bool hra = false;
  bool vct = false;
  bool tb = false;
  bool hiv = false;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isFormValid =>
      hra &&
      vct &&
      tb &&
      hiv &&
      venueController.text.isNotEmpty &&
      dateController.text.isNotEmpty &&
      practitionerController.text.isNotEmpty &&
      signatureController.isNotEmpty;

  void toggleCheckbox(String field, bool? value) {
    switch (field) {
      case 'hra':
        hra = value ?? false;
        break;
      case 'vct':
        vct = value ?? false;
        break;
      case 'tb':
        tb = value ?? false;
        break;
      case 'hiv':
        hiv = value ?? false;
        break;
    }
    notifyListeners();
  }

  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  Future<void> submitConsent() async {
    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isSubmitting = false;
    notifyListeners();
  }

  /// Converts the consent data to a Map for submission
  Map<String, dynamic> toMap() {
    return {
      'venue': venueController.text,
      'date': dateController.text,
      'practitioner': practitionerController.text,
      'hra': hra,
      'vct': vct,
      'tb': tb,
      'hiv': hiv,
      'hasSignature': signatureController.isNotEmpty,
    };
  }

  @override
  void dispose() {
    signatureController.dispose();
    venueController.dispose();
    dateController.dispose();
    practitionerController.dispose();
    super.dispose();
  }
}
