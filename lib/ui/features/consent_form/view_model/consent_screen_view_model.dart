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

  ConsentScreenViewModel() {
    // 👇 Rebuild UI whenever user types something
    venueController.addListener(notifyListeners);
    dateController.addListener(notifyListeners);
    practitionerController.addListener(notifyListeners);

    // 👇 Rebuild UI whenever signature changes (draw or clear)
    signatureController.addListener(() => notifyListeners());
  }

  // ✅ Dynamic validation
  bool get isFormValid =>
      venueController.text.isNotEmpty &&
      dateController.text.isNotEmpty &&
      practitionerController.text.isNotEmpty &&
      signatureController.isNotEmpty &&
      (hra || vct || tb || hiv); // only need at least one checkbox

  // ✅ Toggle a checkbox and notify listeners
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

  // ✅ Clear the signature
  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  // ✅ Simulated submit action
  Future<void> submitConsent() async {
    if (!isFormValid) return;

    _isSubmitting = true;
    notifyListeners();

    // Simulate a delay for loading state
    await Future.delayed(const Duration(milliseconds: 600));

    _isSubmitting = false;
    notifyListeners();
  }

  // ✅ Convert form data to Map
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
