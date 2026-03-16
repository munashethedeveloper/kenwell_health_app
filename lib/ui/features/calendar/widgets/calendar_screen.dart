import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/calendar/widgets/sections/event_list_tab_view.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../event/view_model/event_view_model.dart';
import '../../event/widgets/event_screen.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/calendar_view_model.dart';
import 'sections/calendar_tab_view.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

/// The main calendar screen.
///
/// Hosts two tabs:
/// - **Events Calendar** — full [TableCalendar] with event markers
///   (see [CalendarTabView]).
/// - **Events List** — month-grouped list of events with navigation
///   (see [EventsListTabView]).
///
/// A FAB is shown only when the user has permission to create events.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) => const _CalendarScreenBody();
}

class _CalendarScreenBody extends StatefulWidget {
  const _CalendarScreenBody();

  @override
  State<_CalendarScreenBody> createState() => _CalendarScreenBodyState();
}

class _CalendarScreenBodyState extends State<_CalendarScreenBody> {
  /// Checks whether the current user role has the create_event permission.
  bool _canAddEvent(BuildContext context) {
    final profileVM = context.read<ProfileViewModel>();
    return RolePermissions.canAccessFeature(profileVM.role, 'create_event');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarViewModel>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: KenwellAppBar(
              title: 'KenWell365',
              automaticallyImplyLeading: true,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    if (mounted) {
                      viewModel.loadEvents();
                      AppSnackbar.showSuccess(context, 'Events refreshed',
                          duration: const Duration(seconds: 1));
                    }
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh events',
                ),
                TextButton.icon(
                  onPressed: () {
                    if (mounted) context.pushNamed('help');
                  },
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  label:
                      const Text('Help', style: TextStyle(color: Colors.white)),
                ),
              ],
              // Tab bar switching between Calendar and List views
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3.0,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.7),
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 14),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.calendar_today_rounded),
                    text: 'Events Calendar',
                  ),
                  Tab(
                    icon: Icon(Icons.list_rounded),
                    text: 'Events List',
                  ),
                ],
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const KenwellGradientHeader(
                        title: 'Event Management',
                        subtitle: 'View and manage your wellness events',
                      ),
                      // Error banner (non-blocking — calendar still shows)
                      if (viewModel.error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: Colors.orange.shade100,
                          child: Row(
                            children: [
                              Icon(Icons.warning,
                                  color: Colors.orange.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.error!,
                                  style:
                                      TextStyle(color: Colors.orange.shade900),
                                ),
                              ),
                              TextButton(
                                onPressed: () => viewModel.loadEvents(),
                                child: const Text('Retry'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => viewModel.clearError(),
                                color: Colors.orange.shade900,
                                tooltip: 'Dismiss',
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: full calendar widget
                            CalendarTabView(
                              viewModel: viewModel,
                              onOpenEventForm: (date, {existingEvent}) =>
                                  _openEventForm(
                                context,
                                viewModel,
                                date,
                                existingEvent: existingEvent,
                              ),
                            ),
                            // Tab 2: month grouped event list
                            EventsListTabView(
                              viewModel: viewModel,
                              canAddEvent: _canAddEvent(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            // FAB: only for users with create_event permission
            floatingActionButton: _canAddEvent(context)
                ? FloatingActionButton.extended(
                    backgroundColor: const Color(0xFF90C048),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Event',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      final targetDate =
                          viewModel.selectedDay ?? viewModel.focusedDay;
                      _openEventForm(context, viewModel, targetDate);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  /// Opens the event creation/editing form and reloads the calendar on return.
  Future<void> _openEventForm(
    BuildContext context,
    CalendarViewModel viewModel,
    DateTime date, {
    WellnessEvent? existingEvent,
  }) async {
    final eventViewModel = context.read<EventViewModel>();
    await eventViewModel.initialized;

    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventScreen(
          date: date,
          existingEvent: existingEvent,
          onSave: (event) async {
            if (existingEvent == null) {
              await eventViewModel.addEvent(event);
            } else {
              await eventViewModel.updateEvent(event);
            }
          },
          viewModel: eventViewModel,
        ),
      ),
    );

    // Reload to reflect any changes made in the form
    if (context.mounted) {
      try {
        await viewModel.loadEvents();
      } catch (e) {
        debugPrint('CalendarScreen: Error reloading events after save: $e');
      }
    }
  }
}
