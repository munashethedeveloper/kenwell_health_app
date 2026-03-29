/// Centralised registry of every named route and fixed path used in the app.
///
/// Use these constants anywhere you call [GoRouter.pushNamed],
/// [GoRouter.goNamed], or [BuildContext.go] / [BuildContext.pushNamed] to
/// eliminate magic strings and make route renames a single-file change.
abstract final class AppRoutes {
  AppRoutes._();

  // ── Fixed paths ────────────────────────────────────────────────────────────

  /// Root / home shell path.
  static const String homePath = '/';

  /// Login page path.
  static const String loginPath = '/login';

  /// All events listing path (used by push notification deep links).
  static const String allEventsPath = '/all-events';

  // ── Named routes ───────────────────────────────────────────────────────────

  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String main = 'main';
  static const String memberSearch = 'memberSearch';
  static const String allEvents = 'allEvents';
  static const String calendar = 'calendar';
  static const String myRegistrationManagement = 'myRegistrationManagement';
  static const String memberManagement = 'memberManagement';
  static const String eventById = 'eventById';
  static const String addEditEvent = 'addEditEvent';
  static const String eventDetails = 'eventDetails';
  static const String stats = 'stats';
  static const String liveEvents = 'liveEvents';
  static const String pastEvents = 'pastEvents';
  static const String hctTest = 'hctTest';
  static const String hctResults = 'hctResults';
  static const String tbTesting = 'tbTesting';
  static const String survey = 'survey';
  static const String profile = 'profile';
  static const String allocateEvent = 'allocateEvent';
  static const String help = 'help';
  static const String faq = 'faq';
  static const String auditLog = 'auditLog';
  static const String userManagement = 'userManagement';
  static const String userManagementVersionTwo = 'userManagementVersionTwo';
}
