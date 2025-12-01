import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

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

  // Event for pre-filling fields
  WellnessEvent? event;

  // Initialise with event and pre-fill fields safely
  void initialise(WellnessEvent e) {
    if (event != null) return; // prevent multiple initializations
    event = e;

    // Schedule updates after build to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      venueController.text = e.venue;
      dateController.text = DateFormat('yyyy-MM-dd').format(e.date);
      notifyListeners();
    });
  }

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

  @override
  void dispose() {
    signatureController.dispose();
    venueController.dispose();
    dateController.dispose();
    practitionerController.dispose();
    super.dispose();
  }
}
