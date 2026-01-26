import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/domain/models/consent.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_consent_repository.dart';
import 'package:kenwell_health_app/utils/logger.dart';
import 'dart:convert';
import 'dart:typed_data';

class ConsentScreenViewModel extends ChangeNotifier {
  final FirestoreConsentRepository _consentRepository =
      FirestoreConsentRepository();

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
  //bool vct = false;
  bool hiv = false;
  bool tb = false;
  //bool hiv = false;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  WellnessEvent? event;
  String? _memberId;
  String? _eventId;

  // Profile names (passed in from ProfileViewModel)
  String? userFirstName;
  String? userLastName;

  bool get isFormValid =>
      //(hra || vct || tb || hiv) && // At least one checkbox must be selected
      (hra || hiv || tb) && // At least one checkbox must be selected
      venueController.text.isNotEmpty &&
      dateController.text.isNotEmpty &&
      practitionerController.text.isNotEmpty &&
      signatureController.isNotEmpty;

  // Helper to check if at least one screening is selected
  //bool get hasAtLeastOneScreening => hra || vct || tb || hiv;

  // Helper to check if at least one screening is selected
  bool get hasAtLeastOneScreening => hra || hiv || tb;

  // Get list of selected screenings
  List<String> get selectedScreenings {
    final List<String> selected = [];
    if (hra) selected.add('hra');
    if (hiv) selected.add('hiv');
    //if (vct) selected.add('vct');
    if (tb) selected.add('tb');
    //if (hiv) selected.add('hiv');
    return selected;
  }

  // Initialise and pre-fill fields
  void initialise(
    WellnessEvent e, {
    String? firstName,
    String? lastName,
    String? memberId,
    String? eventId,
  }) {
    if (event != null) return; // prevent double init

    event = e;
    userFirstName = firstName;
    userLastName = lastName;
    _memberId = memberId;
    _eventId = eventId ?? e.id;

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
      //case 'vct':
      //vct = value ?? false;
      // break;
      case 'hiv':
        hiv = value ?? false;
        break;
      case 'tb':
        tb = value ?? false;
        break;
      //case 'hiv':
      // hiv = value ?? false;
      //break;
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

    try {
      // Convert signature to base64 if available
      String? signatureBase64;
      if (signatureController.isNotEmpty) {
        final Uint8List? signatureBytes =
            await signatureController.toPngBytes();
        if (signatureBytes != null) {
          signatureBase64 = base64Encode(signatureBytes);
        }
      }

      // Create consent object
      final consent = Consent(
        id: '${DateTime.now().millisecondsSinceEpoch}', // Simple timestamp-based ID
        memberId: _memberId,
        eventId: _eventId,
        venue: venueController.text,
        date: DateFormat('yyyy-MM-dd').parse(dateController.text),
        practitioner: practitionerController.text,
        hra: hra,
        hiv: hiv,
        tb: tb,
        signatureData: signatureBase64,
        createdAt: DateTime.now(),
      );

      // Save to Firestore consents collection
      await _consentRepository.addConsent(consent);
      AppLogger.info('Consent saved to consents collection');

      // Also save to survey_results collection for analytics/reporting
      await _saveToSurveyResults(consent);
      AppLogger.info('Consent saved to survey_results collection');
    } catch (e) {
      AppLogger.error('Failed to save consent', e);
      // Continue with flow even if Firestore save fails
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Save consent data to survey_results collection
  Future<void> _saveToSurveyResults(Consent consent) async {
    try {
      final surveyData = {
        'id': consent.id,
        'memberId': consent.memberId,
        'eventId': consent.eventId,
        'type': 'consent', // Identify this as a consent survey
        'venue': consent.venue,
        'date': consent.date.toIso8601String(),
        'practitioner': consent.practitioner,
        'screenings': {
          'hra': consent.hra,
          'hiv': consent.hiv,
          'tb': consent.tb,
        },
        'signatureProvided': consent.signatureData != null,
        'createdAt': consent.createdAt.toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('survey_results')
          .doc(consent.id)
          .set(surveyData);
    } catch (e) {
      AppLogger.error('Failed to save consent to survey_results', e);
      // Don't rethrow - this is a secondary save operation
    }
  }

  Map<String, dynamic> toMap() => {
        'venue': venueController.text,
        'date': dateController.text,
        'practitioner': practitionerController.text,
        'hra': hra,
        'hiv': hiv,
        // 'vct': vct,
        'tb': tb,
        //'hiv': hiv,
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
