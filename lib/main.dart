import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/ui/features/consent_form/view_model/consent_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'providers/theme_provider.dart';
import 'routing/go_router_config.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/calendar/view_model/calendar_view_model.dart';
import 'ui/features/event/view_model/event_view_model.dart';
import 'ui/features/stats_report/view_model/stats_report_view_model.dart';
import 'ui/shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - skip on Windows desktop for now due to build issues
  // Use web config for Windows which doesn't require C++ SDK
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    // Enable Firestore offline persistence so that previously loaded data is
    // available when the device has no network connection.  Each device that
    // runs the app maintains its own local Firestore cache; when connectivity
    // is restored Firestore automatically syncs queued writes back to the
    // server, providing a seamless offline-first experience.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('Firestore offline persistence enabled');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('App will run with limited functionality (local database only)');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
        ChangeNotifierProvider<ProfileViewModel>(
            create: (_) => ProfileViewModel()),
        ChangeNotifierProvider<ConsentScreenViewModel>(
            create: (_) => ConsentScreenViewModel()),
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<CalendarViewModel>(
            create: (_) => CalendarViewModel()),
        ChangeNotifierProvider<EventViewModel>(
          create: (_) => EventViewModel(),
        ),
        ChangeNotifierProvider<StatsReportViewModel>(
          create: (_) => StatsReportViewModel(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final goRouter = AppRouterConfig.createRouter();

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Wellness Planner',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: goRouter,
          );
        },
      ),
    );
  }
}
