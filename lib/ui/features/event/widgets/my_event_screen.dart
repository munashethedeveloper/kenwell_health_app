import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../view_model/event_view_model.dart';
import '../view_model/my_event_view_model.dart';
import '../../wellness/widgets/wellness_flow_page.dart';
import 'sections/my_event_tab_bar.dart';
import 'sections/my_event_empty_state.dart';
import 'sections/premium_event_card.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

/// Screen that lists the wellness events assigned to the currently logged-in
/// user.  Events are split into two tabs:
///   - **Today** – events whose date matches the current calendar day.
///   - **Upcoming** – events whose date is strictly after today.
///
/// All business logic is delegated to [MyEventViewModel].  A periodic [Timer]
/// fires every minute to drive [MyEventViewModel.autoTransitionEvents] so
/// button states stay up-to-date.
class MyEventScreen extends StatefulWidget {
  const MyEventScreen({super.key});

  /// Returns the nearest [MyEventScreenState] ancestor, allowing parent
  /// screens to call [MyEventScreenState.refreshUserEvents] after navigation.
  static MyEventScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyEventScreenState>();

  @override
  State<MyEventScreen> createState() => MyEventScreenState();
}

class MyEventScreenState extends State<MyEventScreen> {
  late MyEventViewModel _vm;
  Timer? _clockTimer;

  /// 0 = Today tab, 1 = Upcoming tab.
  int _selectedWeek = 0;
  bool _isVmInitialised = false;

  @override
  void initState() {
    super.initState();
    // ViewModel needs EventViewModel — read it once in initState via a
    // post-frame callback so the Provider tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vm = MyEventViewModel(
        eventViewModel: context.read<EventViewModel>(),
      );
      _vm.addListener(_onVmChanged);
      setState(() => _isVmInitialised = true);
      _vm.loadUserEvents();
      _clockTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _vm.autoTransitionEvents(),
      );
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    if (_isVmInitialised) {
      _vm
        ..removeListener(_onVmChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  /// Public hook so parent screens can trigger a refresh after navigation.
  void refreshUserEvents() => _vm.loadUserEvents();

  // ── Navigation ──────────────────────────────────────────────────────────

  /// Starts the event: marks it in-progress, opens [WellnessFlowPage], then
  /// refreshes the list on return.
  Future<void> _startEvent(WellnessEvent event) async {
    final updated = await _vm.startEvent(event);
    if (!mounted || updated == null) return;

    final eventVM = context.read<EventViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WellnessFlowPage(
          event: updated,
          onExitEarly: () async {
            await eventVM.updateEvent(
              updated.copyWith(
                status: WellnessEventStatus.scheduled,
                actualStartTime: null,
                actualEndTime: null,
              ),
            );
          },
        ),
      ),
    );

    if (mounted) await _vm.loadUserEvents();
  }

  /// Marks the event as completed and shows a snackbar.
  Future<void> _finishEvent(WellnessEvent event) async {
    await _vm.finishEvent(event);
    if (!mounted) return;
    AppSnackbar.showSuccess(context, 'Event finished successfully');
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Guard against the post-frame callback not yet having run.
    if (!_isVmInitialised) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allEvents = _vm.userEvents;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filteredEvents = _selectedWeek == 0
        ? allEvents.where((e) => _vm.eventDay(e).isAtSameMomentAs(today)).toList()
        : allEvents.where((e) => _vm.eventDay(e).isAfter(today)).toList();

    final todayCount =
        allEvents.where((e) => _vm.eventDay(e).isAtSameMomentAs(today)).length;
    final upcomingCount =
        allEvents.where((e) => _vm.eventDay(e).isAfter(today)).length;

    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: KenwellAppBar(
        title: 'KenWell365',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _vm.loadUserEvents();
              if (!context.mounted) return;
              AppSnackbar.showSuccess(context, 'Events refreshed',
                  duration: const Duration(seconds: 2));
            },
          ),
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              if (mounted) context.pushNamed('help');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _vm.loadUserEvents,
        color: KenwellColors.primaryGreen,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: KenwellGradientHeader(
                label: 'MY EVENTS',
                title: _selectedWeek == 0 ? "Today's\nEvents" : 'Upcoming\nEvents',
                subtitle: _selectedWeek == 0
                    ? 'Manage your wellness events for today.'
                    : 'Your scheduled events for the coming days.',
              ),
            ),
            SliverToBoxAdapter(
              child: MyEventTabBar(
                selectedIndex: _selectedWeek,
                onChanged: (i) {
                  if (mounted) setState(() => _selectedWeek = i);
                },
                todayCount: todayCount,
                upcomingCount: upcomingCount,
              ),
            ),
            if (filteredEvents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: MyEventEmptyState(isToday: _selectedWeek == 0),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = filteredEvents[index];
                      return PremiumEventCard(
                        event: event,
                        isStarting: _vm.startingEventId == event.id,
                        canStart: _vm.canStartEvent(event),
                        startTooltip: _vm.startEventTooltip(event),
                        onStart: () => _startEvent(event),
                        onFinish: () => _finishEvent(event),
                      )
                          .animate()
                          .fadeIn(
                              duration: 300.ms,
                              delay: (index * 60).ms,
                              curve: Curves.easeOut)
                          .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: 300.ms,
                              delay: (index * 60).ms,
                              curve: Curves.easeOut);
                    },
                    childCount: filteredEvents.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
