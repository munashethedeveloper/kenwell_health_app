import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kenwell_health_app/ui/features/consent_form/view_model/consent_screen_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'routing/app_router.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/calendar/view_model/calendar_view_model.dart';
import 'ui/features/event/view_model/event_view_model.dart';
import 'ui/shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Wellness Planner',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/login', // Start at login
          );
        },
      ),
    );
  }
}
