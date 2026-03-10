import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/features/calendar/view_model/calendar_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  bool _isPrivilegedRole(String role) {
    final r = role.toUpperCase();
    return r == 'ADMIN' || r == 'TOP MANAGEMENT' || r == 'PROJECT MANAGER';
  }

  bool _isStaffRole(String role) {
    final r = role.toUpperCase();
    return _isPrivilegedRole(r) ||
        r == 'PROJECT COORDINATOR' ||
        r == 'HEALTH PRACTITIONER';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, CalendarViewModel>(
      builder: (context, profileVM, calendarVM, _) {
        final role = profileVM.role;
        final firstName = profileVM.firstName;
        final now = DateTime.now();
        final events = calendarVM.events;
        final upcomingEvents = events
            .where((e) =>
                e.date.isAfter(now) &&
                e.date.isBefore(now.add(const Duration(days: 7))))
            .length;
        final todayEvents = events
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .length;

        return Scaffold(
          backgroundColor: KenwellColors.neutralBackground,
          body: RefreshIndicator(
            onRefresh: () async {
              await calendarVM.loadEvents();
            },
            color: KenwellColors.primaryGreen,
            child: CustomScrollView(
              slivers: [
                // ── Hero Header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    greeting: _greeting(),
                    firstName: firstName.isNotEmpty ? firstName : 'there',
                    role: role,
                    date: now,
                  ),
                ),

                // ── Stats Row ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _StatsRow(
                    totalEvents: events.length,
                    upcomingEvents: upcomingEvents,
                    todayEvents: todayEvents,
                    isLoading: calendarVM.isLoading,
                  ),
                ),

                // ── Quick Actions ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _QuickActionsSection(
                    role: role,
                    isPrivileged: _isPrivilegedRole(role),
                    isStaff: _isStaffRole(role),
                  ),
                ),

                // ── Welcome Banner ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: _WelcomeBanner(role: role),
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

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.firstName,
    required this.role,
    required this.date,
  });

  final String greeting;
  final String firstName;
  final String role;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(date);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KenwellColors.secondaryNavy,
            Color(0xFF2E2880),
            KenwellColors.primaryGreenDark,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: app name + date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: KenwellColors.primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'KenWell365',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Greeting
              Text(
                greeting,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                firstName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (role.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: KenwellColors.primaryGreen.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: KenwellColors.primaryGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: KenwellColors.primaryGreen,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          color: KenwellColors.primaryGreenLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalEvents,
    required this.upcomingEvents,
    required this.todayEvents,
    required this.isLoading,
  });

  final int totalEvents;
  final int upcomingEvents;
  final int todayEvents;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.event_rounded,
              iconColor: KenwellColors.primaryGreen,
              label: 'Total\nEvents',
              value: isLoading ? '—' : '$totalEvents',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.upcoming_rounded,
              iconColor: const Color(0xFF5B8DEF),
              label: 'Upcoming\n(7 days)',
              value: isLoading ? '—' : '$upcomingEvents',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.today_rounded,
              iconColor: const Color(0xFFE67E22),
              label: "Today's\nEvents",
              value: isLoading ? '—' : '$todayEvents',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: KenwellColors.secondaryNavy,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    required this.role,
    required this.isPrivileged,
    required this.isStaff,
  });

  final String role;
  final bool isPrivileged;
  final bool isStaff;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionItem>[
      _QuickActionItem(
        icon: Icons.calendar_month_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF90C048), Color(0xFF5E8C1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        title: 'Calendar',
        subtitle: 'View & manage events',
        onTap: () => context.pushNamed('calendar'),
        visible: true,
      ),
      _QuickActionItem(
        icon: Icons.bar_chart_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        title: 'Reports',
        subtitle: 'Analytics & insights',
        onTap: () => context.pushNamed('stats'),
        visible: isStaff || role.toUpperCase() == 'CLIENT',
      ),
      _QuickActionItem(
        icon: Icons.people_alt_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF201C58), Color(0xFF3B3F86)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        title: 'Users',
        subtitle: 'Register & manage users',
        onTap: () => context.pushNamed('myRegistrationManagement'),
        visible: isPrivileged,
      ),
      _QuickActionItem(
        icon: Icons.person_search_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF16A085), Color(0xFF0E6655)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        title: 'Find Member',
        subtitle: 'Search participants',
        onTap: () => context.pushNamed('memberSearch'),
        visible: isStaff,
      ),
    ];

    final visibleActions = actions.where((a) => a.visible).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: KenwellColors.secondaryNavy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Navigate to key features',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemCount: visibleActions.length,
            itemBuilder: (context, index) {
              final action = visibleActions[index];
              return _QuickActionCard(item: action);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.visible = true,
  });

  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool visible;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.item});

  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: item.gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Welcome Banner
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              KenwellColors.secondaryNavy,
              Color(0xFF2E2880),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: KenwellColors.secondaryNavy.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KenWell365',
                    style: TextStyle(
                      color: KenwellColors.primaryGreenLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Corporate Wellness\nManagement Platform',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empowering organisations to deliver world-class wellness programmes.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: KenwellColors.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: KenwellColors.primaryGreenLight,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
