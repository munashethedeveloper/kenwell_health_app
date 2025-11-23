import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'routing/app_router.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/calendar/view_model/calendar_view_model.dart';
import 'ui/features/event/view_model/event_view_model.dart';
import 'ui/shared/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
