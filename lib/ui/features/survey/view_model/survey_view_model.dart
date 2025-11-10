import 'package:flutter/material.dart';

class SurveyViewModel extends ChangeNotifier {
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

    debugPrint('✅ Survey Submitted:');
    debugPrint('Heard About: $heardAbout');
    debugPrint('Province: $province');
    debugPrint('Ratings: $ratings');
    debugPrint('Contact Consent: $contactConsent');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Survey submitted successfully!')),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    onNext();
  }

  Map<String, dynamic> toMap() => {
        'heardAbout': heardAbout,
        'province': province,
        'ratings': ratings,
        'contactConsent': contactConsent,
      };
}
