class RouteNames {
  static const String login = '/login';
  static const String register = '/register';
  //static const String signup = '/sign-up'; // <-- UPDATED
  static const String calendar = '/calendar';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String event = '/event';
  static const String eventDetails = '/event-details'; // <-- NEW

  static const String forgotPassword = '/forgot-password';
  static const String main = '/';
  static const String nurseIntervention = '/nurse';
  static const String hivNurseIntervention = '/hiv-intervention';
  static const String tbNurseIntervention = '/tb-intervention';
  static const String hivTest = '/hiv-test';
  static const String hivResults = '/hiv-result';
  static const String tbTesting = '/tb-testing';
  static const String survey = '/survey';
  static const String statsReport = '/stats-report';

  // NEW: standalone consent route so the app can navigate to ConsentScreen directly
  static const String consent = '/consent';

  // NEW: standalone personal details route
  static const String personalDetails = '/personal-details';
}
