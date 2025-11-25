import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

import '../../../../domain/models/wellness_event.dart';

class ConsentScreenViewModel extends ChangeNotifier {
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  final TextEditingController venueController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController practitionerController = TextEditingController();

  // Screening checkboxes
  bool hra = false;
  bool vct = false;
  bool tb = false;
  bool hiv = false;

  // Submission state
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Form validation
  bool get isFormValid =>
      hra &&
      vct &&
      tb &&
      hiv &&
      venueController.text.isNotEmpty &&
      dateController.text.isNotEmpty &&
      practitionerController.text.isNotEmpty &&
      signatureController.isNotEmpty;

  // Toggle screening checkbox
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

  // Clear signature
  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  // Submit consent
  Future<void> submitConsent() async {
    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isSubmitting = false;
    notifyListeners();
  }

  // Convert data to Map
  Map<String, dynamic> toMap() => {
        'venue': venueController.text,
        'date': dateController.text,
        'practitioner': practitionerController.text,
        'hra': hra,
        'vct': vct,
        'tb': tb,
        'hiv': hiv,
        'hasSignature': signatureController.isNotEmpty,
      };

  void prefillFromEvent(WellnessEvent event) {
    venueController.text = event.venue;
    dateController.text =
        DateFormat('yyyy-MM-dd').format(event.date);
    notifyListeners();
  }

  void reset() {
    venueController.clear();
    dateController.clear();
    practitionerController.clear();
    hra = false;
    vct = false;
    tb = false;
    hiv = false;
    signatureController.clear();
    notifyListeners();
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
