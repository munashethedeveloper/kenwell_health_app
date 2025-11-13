import 'package:flutter/material.dart';
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
import '../ui/features/hiv_test_nursing_intervention/view_model/hiv_test_nursing_intervention_view_model.dart';
import '../ui/features/hiv_test_nursing_intervention/widgets/hiv_test_nursing_intervention_screen.dart';
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

// TB Intervention
import '../ui/features/tb_test_nursing_intervention/view_model/tb_nursing_intervention_view_model.dart';
import '../ui/features/tb_test_nursing_intervention/widgets/tb_nursing_intervention_screen.dart';

import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

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
                Navigator.pushNamed(_, RouteNames.hivNurseIntervention);
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
                Navigator.pushNamed(_, RouteNames.tbNurseIntervention);
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
          builder: (_) => ChangeNotifierProvider(
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

      case RouteNames.hivNurseIntervention:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => HIVTestNursingInterventionViewModel(),
            child: HIVTestNursingInterventionScreen(
              onPrevious: () {
                Navigator.pop(_);
              },
              onNext: () {
                Navigator.pushNamed(_, RouteNames.tbTesting);
              },
            ),
          ),
        );

      case RouteNames.tbNurseIntervention:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => TBNursingInterventionViewModel(),
            child: TBNursingInterventionScreen(
              onPrevious: () {
                Navigator.pop(_);
              },
              onNext: () {
                Navigator.pushNamed(_, RouteNames.survey);
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
        final void Function(WellnessEvent) onSave =
            args?['onSave'] as void Function(WellnessEvent)? ?? (_) {};
        final List<WellnessEvent>? existingEvents =
            (args?['existingEvents'] as List<dynamic>?)
                ?.map((e) => e as WellnessEvent)
                .toList();
        final WellnessEvent? eventToEdit = args?['eventToEdit'] as WellnessEvent?;

        return MaterialPageRoute(
          builder: (context) {
            final eventVM = Provider.of<EventViewModel>(context, listen: false);
            return EventScreen(
              date: date,
              onSave: onSave,
              existingEvents: existingEvents,
              eventToEdit: eventToEdit,
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
