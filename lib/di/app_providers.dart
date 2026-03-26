import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/services/connectivity_service.dart';
import '../providers/theme_provider.dart';
import '../ui/features/auth/view_models/auth_view_model.dart';
import '../ui/features/calendar/view_model/calendar_view_model.dart';
import '../ui/features/consent_form/view_model/consent_view_model.dart';
import '../ui/features/event/view_model/event_view_model.dart';
import '../ui/features/profile/view_model/profile_view_model.dart';
import '../ui/features/stats_report/view_model/stats_report_view_model.dart';

/// Central registry of all app-wide [ChangeNotifierProvider] registrations.
///
/// By keeping all root-level providers in one place we avoid scattering
/// `ChangeNotifierProvider(create: (_) => SomeVM())` across `main.dart` and
/// any widget that happens to need a fresh ViewModel.  Route-scoped providers
/// (ones created per-screen in `go_router_config.dart`) are intentionally
/// kept close to their routes — this class only contains the singletons that
/// must live for the full app lifetime.
///
/// ### Usage
/// ```dart
/// // In main.dart:
/// MultiProvider(
///   providers: AppProviders.rootProviders,
///   child: MyApp(),
/// );
/// ```
abstract final class AppProviders {
  AppProviders._();

  /// Providers that span the full application lifetime.
  ///
  /// Order matters: providers later in the list may depend on those earlier.
  static List<SingleChildWidget> get rootProviders => [
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => ConnectivityService(),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(),
        ),
        ChangeNotifierProvider<ConsentScreenViewModel>(
          create: (_) => ConsentScreenViewModel(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider<CalendarViewModel>(
          create: (_) => CalendarViewModel(),
        ),
        ChangeNotifierProvider<EventViewModel>(
          create: (_) => EventViewModel(),
        ),
        ChangeNotifierProvider<StatsReportViewModel>(
          create: (_) => StatsReportViewModel(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ];
}
