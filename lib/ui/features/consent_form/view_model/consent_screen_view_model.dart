import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';

class ConsentScreenViewModel extends ChangeNotifier {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  final TextEditingController venueController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController practitionerController = TextEditingController();

  // Checkbox states
  bool hra = false;
  bool vct = false;
  bool tb = false;
  bool hiv = false;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  WellnessEvent? event;

  // Profile names (passed in from ProfileViewModel)
  String? userFirstName;
  String? userLastName;

  bool get isFormValid =>
      hra &&
      vct &&
      tb &&
      hiv &&
      venueController.text.isNotEmpty &&
      dateController.text.isNotEmpty &&
      practitionerController.text.isNotEmpty &&
      signatureController.isNotEmpty;

  // Initialise and pre-fill fields
  void initialise(
    WellnessEvent e, {
    String? firstName,
    String? lastName,
  }) {
    if (event != null) return; // prevent double init

    event = e;
    userFirstName = firstName;
    userLastName = lastName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      venueController.text = e.venue;
      dateController.text = DateFormat('yyyy-MM-dd').format(e.date);

      // Fill practitioner name from profile
      practitionerController.text =
          '${userFirstName ?? ''} ${userLastName ?? ''}'.trim();

      notifyListeners();
    });
  }

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
