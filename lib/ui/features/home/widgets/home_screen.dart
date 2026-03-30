import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/calendar/view_model/calendar_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'sections/home_notifications_section.dart';

/// Home screen — modern profile hero, quick-action grid, smart alerts.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onTabSwitch});

  /// Optional callback to switch the bottom-nav tab.
  final void Function(int tabIndex)? onTabSwitch;

  // Calendar tab index (privileged role: Users=0, Stats=1, Home=2, Calendar=3, Events=4)
  static const int calendarTabIndex = 3;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CalendarViewModel>().loadEvents();
        context.read<ProfileViewModel>().loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, CalendarViewModel>(
      builder: (context, profileVM, calendarVM, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: KenwellAppBar(
            title: 'KenWell365',
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () async {
                  await Future.wait([
                    calendarVM.loadEvents(),
                    profileVM.loadProfile(),
                  ]);
                  if (context.mounted) {
                    AppSnackbar.showSuccess(context, 'Refreshed',
                        duration: const Duration(seconds: 1));
                  }
                },
              ),
              TextButton.icon(
                onPressed: () => context.pushNamed('help'),
                icon: const Icon(Icons.help_outline, color: Colors.white),
                label:
                    const Text('Help', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                calendarVM.loadEvents(),
                profileVM.loadProfile(),
              ]);
            },
            color: KenwellColors.primaryGreen,
            child: CustomScrollView(
              slivers: [
                // ── Gradient header ─────────────────────────────────────
                const SliverToBoxAdapter(
                  child: KenwellGradientHeader(
                    label: 'HOME',
                    title: 'My\nDashboard',
                    subtitle: 'Your health overview at a glance.',
                  ),
                ),

                // ── Today's summary strip ───────────────────────────────
                SliverToBoxAdapter(
                  child: _TodaySummaryStrip(
                    calendarVM: calendarVM,
                  ),
                ),

                // ── Quick actions ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _QuickActionsGrid(
                    onAddEvent: () => context.pushNamed('addEditEvent'),
                    onAllEvents: () => context.pushNamed('allEvents'),
                    onProfile: () => context.pushNamed('profile'),
                    onLiveStats: () => context.pushNamed('liveEvents'),
                  ),
                ),

                // ── Notifications ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: HomeNotificationsSection(
                      profileVM: profileVM,
                      calendarVM: calendarVM,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Quick actions grid ────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.onAddEvent,
    required this.onAllEvents,
    required this.onProfile,
    required this.onLiveStats,
  });

  final VoidCallback onAddEvent;
  final VoidCallback onAllEvents;
  final VoidCallback onProfile;
  final VoidCallback onLiveStats;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(
        icon: Icons.add_circle_rounded,
        label: 'Add Event',
        subtitle: 'Create new',
        color: KenwellColors.primaryGreen,
        onTap: onAddEvent,
      ),
      _Action(
        icon: Icons.event_available_rounded,
        label: 'All Events',
        subtitle: 'Browse & allocate',
        color: const Color(0xFF3B82F6),
        onTap: onAllEvents,
      ),
      _Action(
        icon: Icons.person_rounded,
        label: 'My Profile',
        subtitle: 'Account & role',
        color: const Color(0xFF8B5CF6),
        onTap: onProfile,
      ),
      _Action(
        icon: Icons.bar_chart_rounded,
        label: 'Live Stats',
        subtitle: 'Real-time data',
        color: const Color(0xFFEF4444),
        onTap: onLiveStats,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: KenwellColors.secondaryNavy,
                letterSpacing: -0.3,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.0,
            children: actions.map((a) => _ActionCard(action: a)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Action {
  const _Action({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _Action action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: action.color.withValues(alpha: 0.18),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KenwellColors.secondaryNavy,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Today's summary strip ─────────────────────────────────────────────────

class _TodaySummaryStrip extends StatelessWidget {
  const _TodaySummaryStrip({required this.calendarVM});

  final CalendarViewModel calendarVM;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayEvents = calendarVM.events.where((e) {
      final d = e.date.toLocal();
      return DateTime(d.year, d.month, d.day).isAtSameMomentAs(today);
    }).toList();

    final upcomingThisWeek = calendarVM.events.where((e) {
      final d = e.date.toLocal();
      final eventDay = DateTime(d.year, d.month, d.day);
      return eventDay.isAfter(today) &&
          eventDay.isBefore(today.add(const Duration(days: 7)));
    }).length;

    final inProgress = calendarVM.events.where((e) {
      final s = e.status.toLowerCase();
      return s == 'in_progress' || s == 'in progress' || s == 'ongoing';
    }).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          _SummaryChip(
            icon: Icons.today_rounded,
            label: 'Today',
            value: '${todayEvents.length}',
            color: KenwellColors.primaryGreen,
          ),
          const SizedBox(width: 10),
          _SummaryChip(
            icon: Icons.date_range_rounded,
            label: 'This Week',
            value: '$upcomingThisWeek',
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 10),
          _SummaryChip(
            icon: Icons.play_circle_rounded,
            label: 'Live',
            value: '$inProgress',
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: KenwellColors.secondaryNavy,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
