import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/domain/models/consent.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_consent_repository.dart';
import 'package:kenwell_health_app/utils/logger.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';

// ViewModel for Consent Screen
class ConsentScreenViewModel extends ChangeNotifier {
  // Firestore repository
  final FirestoreConsentRepository _consentRepository =
      FirestoreConsentRepository();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Patient signature controller
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  // Healthcare practitioner (HP) signature + details
  final SignatureController hpSignatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final TextEditingController sancNumberController = TextEditingController();
  final TextEditingController rankController = TextEditingController();

  final TextEditingController venueController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController practitionerController = TextEditingController();

  // Checkbox states
  bool hra = false;
  bool hct = false;
  bool tb = false;
  bool cancer = false;

  // Submission state
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Stored event and IDs
  WellnessEvent? event;
  String? _memberId;
  String? _eventId;

  // Profile names (passed in from ProfileViewModel)
  String? userFirstName;
  String? userLastName;

  // Validate form
  bool get isFormValid =>
      (hra || hct || tb || cancer) && // At least one checkbox must be selected
      venueController.text.isNotEmpty &&
      dateController.text.isNotEmpty &&
      practitionerController.text.isNotEmpty &&
      signatureController.isNotEmpty &&
      hpSignatureController.isNotEmpty &&
      sancNumberController.text.isNotEmpty &&
      rankController.text.isNotEmpty;

  // Helper to check if at least one screening is selected
  bool get hasAtLeastOneScreening => hra || hct || tb || cancer;

  // Get list of selected screenings
  List<String> get selectedScreenings {
    final List<String> selected = [];
    if (hra) selected.add('hra');
    if (hct) selected.add('hct');
    if (tb) selected.add('tb');
    if (cancer) selected.add('cancer');
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

    // Store event and IDs
    event = e;
    userFirstName = firstName;
    userLastName = lastName;
    _memberId = memberId;
    _eventId = eventId ?? e.id;

    // Pre-fill venue and date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      venueController.text = e.venue;
      dateController.text = DateFormat('yyyy-MM-dd').format(e.date);

      // Fill practitioner name from profile
      practitionerController.text =
          '${userFirstName ?? ''} ${userLastName ?? ''}'.trim();

      // Notify listeners
      notifyListeners();
    });
  }

  /// Resets all form state so the VM can be re-initialised for a new member.
  /// Call this when the wellness flow moves to a new member (e.g. back to
  /// search) so that stale memberId / event values don't bleed through.
  void reset() {
    event = null;
    _memberId = null;
    _eventId = null;
    hra = false;
    hct = false;
    tb = false;
    cancer = false;
    signatureController.clear();
    hpSignatureController.clear();
    sancNumberController.clear();
    rankController.clear();
    venueController.clear();
    dateController.clear();
    practitionerController.clear();
    notifyListeners();
  }

  // Toggle checkbox values
  void toggleCheckbox(String field, bool? value) {
    switch (field) {
      case 'hra':
        hra = value ?? false;
        break;
      case 'hct':
        hct = value ?? false;
        break;
      case 'tb':
        tb = value ?? false;
        break;
      case 'cancer':
        cancer = value ?? false;
        break;
    }
    notifyListeners();
  }

  // Clear patient signature
  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  // Clear HP signature
  void clearHpSignature() {
    hpSignatureController.clear();
    notifyListeners();
  }

  // Submit consent form
  Future<void> submitConsent() async {
    debugPrint('Saving consent for memberId=$_memberId, eventId=$_eventId');
    _isSubmitting = true;
    notifyListeners();

    try {
      // Convert patient signature to base64
      String? signatureBase64;
      if (signatureController.isNotEmpty) {
        final Uint8List? signatureBytes =
            await signatureController.toPngBytes();
        if (signatureBytes != null) {
          signatureBase64 = base64Encode(signatureBytes);
        }
      }

      // Convert HP signature to base64
      String? hpSignatureBase64;
      if (hpSignatureController.isNotEmpty) {
        final Uint8List? hpBytes = await hpSignatureController.toPngBytes();
        if (hpBytes != null) {
          hpSignatureBase64 = base64Encode(hpBytes);
        }
      }

      // Create consent object
      final consent = Consent(
        id: const Uuid().v4(),
        memberId: _memberId,
        eventId: _eventId,
        venue: venueController.text,
        date: DateFormat('yyyy-MM-dd').parse(dateController.text),
        practitioner: practitionerController.text,
        hra: hra,
        hct: hct,
        tb: tb,
        cancer: cancer,
        signatureData: signatureBase64,
        sancNumber: sancNumberController.text.isEmpty
            ? null
            : sancNumberController.text,
        rank: rankController.text.isEmpty ? null : rankController.text,
        hpSignatureData: hpSignatureBase64,
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
      rethrow;
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
          'hct': consent.hct,
          'tb': consent.tb,
          'cancer': consent.cancer,
        },
        'signatureProvided': consent.signatureData != null,
        'createdAt': consent.createdAt.toIso8601String(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('survey_results')
          .doc(consent.id)
          .set(surveyData);
    } catch (e) {
      AppLogger.error('Failed to save consent to survey_results', e);
      // Don't rethrow - this is a secondary save operation
    }
  }

  // Convert current form state to Map (for debugging or other uses)
  Map<String, dynamic> toMap() => {
        'venue': venueController.text,
        'date': dateController.text,
        'practitioner': practitionerController.text,
        'hra': hra,
        'hct': hct,
        'tb': tb,
        'cancer': cancer,
        'hasSignature': signatureController.isNotEmpty,
      };

  // Dispose controllers
  @override
  void dispose() {
    signatureController.dispose();
    hpSignatureController.dispose();
    sancNumberController.dispose();
    rankController.dispose();
    venueController.dispose();
    dateController.dispose();
    practitionerController.dispose();
    super.dispose();
  }
}
