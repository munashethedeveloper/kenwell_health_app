class RouteNames {
  static const String memberSearch = '/member-search';
  static const String login = '/login';
  static const String register = '/register';
  //static const String signup = '/sign-up'; // <-- UPDATED
  static const String calendar = '/calendar';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String event = '/event';
  static const String help = '/help';
  static const String userManagement = '/user-management';
  static const String userManagementVersionTwo = '/user-management-version-two';
  static const String eventDetails = '/event-details'; // <-- NEW

  static const String forgotPassword = '/forgot-password';
  static const String main = '/';
  static const String nurseIntervention = '/nurse';
  // Note: hivNurseIntervention route removed - consolidated into hivResults screen
  // static const String hivNurseIntervention = '/hiv-intervention';
  // Note: tbNurseIntervention route removed - consolidated into tbTesting screen
  // static const String tbNurseIntervention = '/tb-intervention';
  static const String hivTest = '/hiv-test';
  static const String hivResults = '/hiv-result';
  static const String tbTesting = '/tb-testing';
  static const String survey = '/survey';
  static const String statsReport = '/stats-report';

  // NEW: standalone consent route so the app can navigate to ConsentScreen directly
  static const String consent = '/consent';

  // NEW: standalone personal details route
  static const String personalDetails = '/personal-details';

  // Admin tools route
  static const String adminTools = '/admin-tools';
}
