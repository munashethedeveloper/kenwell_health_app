import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class SurveyViewModel extends ChangeNotifier {
  String? _memberId;
  String? _eventId;

  void setMemberAndEventId(String memberId, String eventId) {
    _memberId = memberId;
    _eventId = eventId;
  }

  String? heardAbout; // e.g., Intranet, Flyer, etc.
  String? province;
  Map<String, int> ratings = {
    'overallExperience': -1,
    'friendlyStaff': -1,
    'nurseProfessional': -1,
    'clearResults': -1,
    'realisedValue': -1,
    'encourageColleagues': -1,
  };
  String? contactConsent; // Yes/No

  bool get isFormValid {
    return heardAbout != null &&
        province != null &&
        !ratings.values.contains(-1) &&
        contactConsent != null;
  }

  void updateRating(String key, int value) {
    ratings[key] = value;
    notifyListeners();
  }

  void updateHeardAbout(String value) {
    heardAbout = value;
    notifyListeners();
  }

  void updateProvince(String value) {
    province = value;
    notifyListeners();
  }

  void updateContactConsent(String value) {
    contactConsent = value;
    notifyListeners();
  }

  /// Submits the survey and triggers workflow continuation
  Future<void> submitSurvey(BuildContext context,
      {required VoidCallback onNext}) async {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    try {
      if (_memberId == null || _eventId == null) {
        throw StateError('Member or event information is missing');
      }
      final id = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('survey_results')
          .doc(id)
          .set({...toMap(), 'id': id});
      AppLogger.info('Survey saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save survey', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save survey. Please try again.')),
        );
      }
      return;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Survey submitted successfully!')),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    onNext();
  }

  Map<String, dynamic> toMap() => {
        'memberId': _memberId,
        'eventId': _eventId,
        'heardAbout': heardAbout,
        'province': province,
        'ratings': ratings,
        'contactConsent': contactConsent,
        'createdAt': DateTime.now().toIso8601String(),
      };
}
