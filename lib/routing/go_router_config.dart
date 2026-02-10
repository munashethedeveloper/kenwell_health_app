import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/auth_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/domain/constants/role_permissions.dart';

// Navigation & Auth
import '../ui/shared/ui/navigation/main_navigation_screen.dart';
import '../ui/features/auth/widgets/forgot_password_screen.dart';
import '../ui/features/auth/widgets/login_screen.dart';

// Calendar & Events
import '../ui/features/calendar/widgets/calendar_screen.dart';
import '../ui/features/event/view_model/event_details_view_model.dart';
import '../ui/features/event/view_model/event_view_model.dart';
import '../ui/features/event/widgets/event_details_screen.dart';
import '../ui/features/event/widgets/event_screen.dart';
import '../domain/models/wellness_event.dart';

// Reports
import '../ui/features/hiv_test_results/view_model/hiv_test_result_view_model.dart';
import '../ui/features/hiv_test_results/widgets/hiv_test_result_screen.dart';
import '../ui/features/stats_report/view_model/stats_report_view_model.dart';
import '../ui/features/stats_report/widgets/stats_report_screen.dart';

// HIV & TB Tests
import '../ui/features/hiv_test/view_model/hiv_test_view_model.dart';
import '../ui/features/hiv_test/widgets/hiv_test_screen.dart';
import '../ui/features/tb_test/view_model/tb_testing_view_model.dart';
import '../ui/features/tb_test/widgets/tb_testing_screen.dart';

// Survey
import '../ui/features/survey/view_model/survey_view_model.dart';
import '../ui/features/survey/widgets/survey_screen.dart';

// Profile & Settings
import '../ui/features/profile/widgets/profile_screen.dart';

// Admin & User Management
import '../ui/features/help/widgets/help_screen.dart';
import '../ui/features/user_management/widgets/user_management_screen_version_two.dart';
import '../ui/features/wellness/widgets/member_search_screen.dart';

/// GoRouter configuration for the Kenwell Health App
///
/// Features:
/// - Authentication guards with redirect logic
/// - Role-based access control using RolePermissions
/// - Deep linking support for web and mobile
/// - Path parameters for dynamic routes
class AppRouterConfig {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Check if a user is authenticated
  static bool _isAuthenticated(BuildContext context) {
    try {
      final authVM = context.read<AuthViewModel>();
      return authVM.isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  /// Get the current user's role
  static String? _getUserRole(BuildContext context) {
    try {
      final profileVM = context.read<ProfileViewModel>();
      return profileVM.role;
    } catch (e) {
      return null;
    }
  }

  /// Check if user can access a specific route
  static bool _canAccessRoute(BuildContext context, String path) {
    final userRole = _getUserRole(context);
    return RolePermissions.canAccessRoute(userRole, path);
  }

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/login',

      // Global redirect logic for authentication and authorization
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = _isAuthenticated(context);
        final currentPath = state.uri.path;

        // Public routes that don't require authentication
        final publicRoutes = ['/login', '/forgot-password'];
        final isPublicRoute = publicRoutes.contains(currentPath);

        // If not authenticated and trying to access protected route
        if (!isAuthenticated && !isPublicRoute) {
          return '/login';
        }

        // If authenticated and trying to access login/forgot-password
        if (isAuthenticated && isPublicRoute) {
          return '/';
        }

        // Role-based access control for authenticated users
        if (isAuthenticated && !isPublicRoute) {
          if (!_canAccessRoute(context, currentPath)) {
            // Redirect to home if user doesn't have permission
            return '/';
          }
        }

        // Allow navigation
        return null;
      },

      routes: [
        // Authentication Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Main Navigation Route
        GoRoute(
          path: '/',
          name: 'main',
          builder: (context, state) => const MainNavigationScreen(),
        ),

        // Member Search Route
        // Note: This screen is primarily used within the wellness flow navigation
        // and typically accessed via wellness_navigator.dart, not directly via routes
        GoRoute(
          path: '/member-search',
          name: 'memberSearch',
          builder: (context, state) {
            return MemberSearchScreen(
              onGoToMemberDetails: (searchQuery) {},
              onPrevious: () {}, // No-op to prevent pop on root
            );
          },
        ),

        // Calendar Route
        GoRoute(
          path: '/calendar',
          name: 'calendar',
          builder: (context, state) => const CalendarScreen(),
        ),

        // Event Routes with path parameter support for deep linking
        GoRoute(
          path: '/event/:id',
          name: 'eventById',
          builder: (context, state) {
            final eventId = state.pathParameters['id'];

            // This route supports deep linking by event ID
            // The EventDetailsScreen will need to fetch the event by ID
            // For now, we'll use the extra approach as a fallback
            final extra = state.extra as Map<String, dynamic>?;
            final WellnessEvent? event = extra?['event'] as WellnessEvent?;
            final EventViewModel? viewModel =
                extra?['viewModel'] as EventViewModel?;

            if (event == null) {
              // If no event passed, show error or redirect
              // In a real app, you'd fetch the event by ID here
              return Scaffold(
                appBar: AppBar(title: const Text('Event Not Found')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Event not found or not provided'),
                      const SizedBox(height: 16),
                      Text('Event ID: $eventId'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Go to Home'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ChangeNotifierProvider(
              create: (_) => EventDetailsViewModel()..setEvent(event),
              child: EventDetailsScreen(
                event: event,
                viewModel: viewModel,
              ),
            );
          },
        ),

        // Legacy route for backward compatibility
        GoRoute(
          path: '/add-edit-event',
          name: 'addEditEvent',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final DateTime date = extra?['date'] as DateTime? ?? DateTime.now();
            final Future<void> Function(WellnessEvent) onSave =
                extra?['onSave'] as Future<void> Function(WellnessEvent)? ??
                    (_) async {};
            final WellnessEvent? existingEvent =
                extra?['existingEvent'] as WellnessEvent?;

            return Consumer<EventViewModel>(
              builder: (context, eventVM, _) {
                return EventScreen(
                  date: date,
                  onSave: onSave,
                  existingEvent: existingEvent,
                  viewModel: eventVM,
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/event-details',
          name: 'eventDetails',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final WellnessEvent event = extra?['event'] as WellnessEvent;
            final EventViewModel? viewModel =
                extra?['viewModel'] as EventViewModel?;

            return ChangeNotifierProvider(
              create: (_) => EventDetailsViewModel()..setEvent(event),
              child: EventDetailsScreen(
                event: event,
                viewModel: viewModel,
              ),
            );
          },
        ),

        // Stats & Reports Routes
        GoRoute(
          path: '/stats',
          name: 'stats',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => StatsReportViewModel(),
            child: const StatsReportScreen(),
          ),
        ),

        // HIV Testing Routes
        GoRoute(
          path: '/hiv-test',
          name: 'hivTest',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => HIVTestViewModel(),
            child: const HIVTestScreen(),
          ),
        ),
        GoRoute(
          path: '/hiv-result',
          name: 'hivResults',
          builder: (context, state) {
            return ChangeNotifierProvider(
              create: (_) => HIVTestResultViewModel(),
              child: HIVTestResultScreen(
                onPrevious: () {
                  context.pop();
                },
                onNext: () {
                  context.pushNamed('tbTesting');
                },
              ),
            );
          },
        ),

        // TB Testing Route
        GoRoute(
          path: '/tb-testing',
          name: 'tbTesting',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => TBTestingViewModel(),
            child: TBTestingScreen(
              onPrevious: () {
                context.pop();
              },
              onNext: () {
                context.pushNamed('survey');
              },
            ),
          ),
        ),

        // Survey Route
        GoRoute(
          path: '/survey',
          name: 'survey',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => SurveyViewModel(),
            child: SurveyScreen(
              onPrevious: () {
                context.pop();
              },
              onSubmit: () {
                context.go('/');
              },
            ),
          ),
        ),

        // Profile Routes
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // Help Route
        GoRoute(
          path: '/help',
          name: 'help',
          builder: (context, state) => const HelpScreen(),
        ),

        // User Management Routes
        GoRoute(
          path: '/user-management',
          name: 'userManagement',
          builder: (context, state) => const UserManagementScreenVersionTwo(),
        ),
        GoRoute(
          path: '/user-management-version-two',
          name: 'userManagementVersionTwo',
          builder: (context, state) => const UserManagementScreenVersionTwo(),
        ),
      ],

      // Error page for undefined routes
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Route not found',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                'Path: ${state.uri.path}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
