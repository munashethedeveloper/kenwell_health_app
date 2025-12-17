import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/help/widgets/help_screen.dart';
import 'package:kenwell_health_app/ui/features/user_management/widgets/user_management_screen.dart';
import 'package:kenwell_health_app/ui/features/user_management/widgets/user_management_screen_version_two.dart';
import 'package:provider/provider.dart';

import '../domain/models/wellness_event.dart';

// Navigation & Auth
import '../ui/shared/ui/navigation/main_navigation_screen.dart';
import '../ui/features/auth/widgets/forgot_password_screen.dart';
import '../ui/features/auth/widgets/login_screen.dart';
import '../ui/features/auth/widgets/register_screen.dart';

// Calendar & Events
import '../ui/features/calendar/widgets/calendar_screen.dart';
import '../ui/features/event/view_model/event_details_view_model.dart';
import '../ui/features/event/view_model/event_view_model.dart';
import '../ui/features/event/widgets/event_details_screen.dart';
import '../ui/features/event/widgets/event_screen.dart';

// Consent & Reports
import '../ui/features/hiv_test_results/view_model/hiv_test_result_view_model.dart';
import '../ui/features/hiv_test_results/widgets/hiv_test_result_screen.dart';
import '../ui/features/stats_report/view_model/stats_report_view_model.dart';
import '../ui/features/stats_report/widgets/stats_report_screen.dart';

// HIV & TB Tests
import '../ui/features/hiv_test/view_model/hiv_test_view_model.dart';
import '../ui/features/hiv_test/widgets/hiv_test_screen.dart';
import '../ui/features/tb_test/view_model/tb_testing_view_model.dart';
import '../ui/features/tb_test/widgets/tb_testing_screen.dart';

// Nurse Interventions
import '../ui/features/nurse_interventions/view_model/nurse_intervention_view_model.dart';
import '../ui/features/nurse_interventions/widgets/nurse_intervention_screen.dart';

// Survey
import '../ui/features/survey/view_model/survey_view_model.dart';
import '../ui/features/survey/widgets/survey_screen.dart';

// Profile & Settings
import '../ui/features/profile/widgets/profile_screen.dart';
import '../ui/features/settings/widgets/settings_screen.dart';

import 'route_names.dart';

class AppRouter {
  //final NurseInterventionFormMixin nurseViewModel;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      //case RouteNames.signup:
      //return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RouteNames.main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());

      case RouteNames.statsReport:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => StatsReportViewModel(),
            child: const StatsReportScreen(),
          ),
        );

      case RouteNames.hivTest:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => HIVTestViewModel(),
            child: const HIVTestScreen(),
          ),
        );

      case RouteNames.hivResults:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => HIVTestResultViewModel(),
            child: HIVTestResultScreen(
              onPrevious: () {
                Navigator.pop(_);
              },
              onNext: () {
                Navigator.pushNamed(_, RouteNames.tbTesting);
              },
            ),
          ),
        );

      case RouteNames.tbTesting:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => TBTestingViewModel(),
            child: TBTestingScreen(
              onPrevious: () {
                Navigator.pop(_);
              },
              onNext: () {
                Navigator.pushNamed(_, RouteNames.survey);
              },
            ),
          ),
        );

      case RouteNames.survey:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => SurveyViewModel(),
            child: SurveyScreen(
              onPrevious: () {
                Navigator.pop(_);
              },
              onSubmit: () {
                Navigator.pushNamedAndRemoveUntil(
                    _, RouteNames.main, (r) => false);
              },
            ),
          ),
        );

      case RouteNames.nurseIntervention:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<NurseInterventionViewModel>(
            create: (_) => NurseInterventionViewModel(),
            child: NurseInterventionScreen(
              onPrevious: () {
                Navigator.pop(_);
              },
              onNext: () {
                Navigator.pushNamed(_, RouteNames.hivTest);
              },
            ),
          ),
        );

      case RouteNames.calendar:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteNames.calendar),
          builder: (context) {
            final eventVM = Provider.of<EventViewModel>(context, listen: false);
            return CalendarScreen(eventVM: eventVM);
          },
        );

      case RouteNames.event:
        final args = settings.arguments as Map<String, dynamic>?;
        final DateTime date = args?['date'] as DateTime? ?? DateTime.now();
        final Future<void> Function(WellnessEvent) onSave =
            args?['onSave'] as Future<void> Function(WellnessEvent)? ??
                (_) async {};
        final WellnessEvent? existingEvent =
            args?['existingEvent'] as WellnessEvent?;

        return MaterialPageRoute(
          builder: (context) {
            final eventVM = Provider.of<EventViewModel>(context, listen: false);
            return EventScreen(
              date: date,
              onSave: onSave,
              existingEvent: existingEvent,
              viewModel: eventVM,
            );
          },
        );

      case RouteNames.eventDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final WellnessEvent event = args?['event'] as WellnessEvent;
        final EventViewModel? viewModel = args?['viewModel'] as EventViewModel?;

        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => EventDetailsViewModel()..setEvent(event),
            child: EventDetailsScreen(
              event: event,
              viewModel: viewModel,
            ),
          ),
        );

      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case RouteNames.help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());

      case RouteNames.userManagement:
        return MaterialPageRoute(builder: (_) => const UserManagementScreen());

      case RouteNames.userManagementVersionTwo:
        return MaterialPageRoute(
            builder: (_) => const UserManagementScreenVersionTwo());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
