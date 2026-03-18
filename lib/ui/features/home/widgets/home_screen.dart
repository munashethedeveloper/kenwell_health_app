import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/calendar/view_model/calendar_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import 'sections/home_notifications_section.dart';
import 'sections/home_quick_actions_section.dart';

/// Home screen — shows a profile hero, quick-actions grid, and smart alerts.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onTabSwitch});

  /// Optional callback to switch the bottom-nav tab programmatically.
  /// The integer is the destination tab index in the current role's tab list.
  final void Function(int tabIndex)? onTabSwitch;

  // ── Tab-index constants for the privileged-role layout ────────────────────
  // Layout: Users=0, Stats=1, Home=2, Profile=3, Events=4
  static const int _membersTabIndex = 0;
  static const int _statsTabIndex = 1;
  static const int _eventsTabIndex = 4;

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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, CalendarViewModel>(
      builder: (context, profileVM, calendarVM, _) {
        final firstName = profileVM.firstName;
        final lastName = profileVM.lastName;
        final role = profileVM.role ?? '';
        final initials = _initials(firstName, lastName);

        return Scaffold(
          backgroundColor: KenwellColors.neutralBackground,
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
                tooltip: 'Help',
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => context.pushNamed('help'),
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
                // ── Profile hero ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _ProfileHero(
                    initials: initials,
                    greeting: _greeting(),
                    firstName: firstName,
                    role: role,
                  ),
                ),

                // ── Quick actions ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: HomeQuickActionsSection(
                      onStartEvent: () => widget.onTabSwitch
                          ?.call(HomeScreen._eventsTabIndex),
                      onViewStats: () => widget.onTabSwitch
                          ?.call(HomeScreen._statsTabIndex),
                      onViewMembers: () => widget.onTabSwitch
                          ?.call(HomeScreen._membersTabIndex),
                      onMyEvents: () => widget.onTabSwitch
                          ?.call(HomeScreen._eventsTabIndex),
                    ),
                  ),
                ),

                // ── Notifications / alerts ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
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

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : '?';
  }
}

// ── Profile hero card ─────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.initials,
    required this.greeting,
    required this.firstName,
    required this.role,
  });

  final String initials;
  final String greeting;
  final String firstName;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1454), Color(0xFF0D7B56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name & role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName.isNotEmpty ? firstName : 'there',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (role.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 12,
                            color: Colors.greenAccent.shade100),
                        const SizedBox(width: 4),
                        Text(
                          role,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // KenWell365 branding badge
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'KenWell',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
