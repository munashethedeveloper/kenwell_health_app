import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenBody();
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        final String firstName = vm.firstName.isNotEmpty
            ? vm.firstName
            : (vm.email.isNotEmpty ? vm.email.split('@').first : 'User');
        final String role = vm.role;
        final String greeting = _getGreeting();
        final String today =
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

        return Scaffold(
          body: vm.isLoadingProfile
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    _HomeAppBar(
                      firstName: firstName,
                      role: role,
                      greeting: greeting,
                      today: today,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),
                          _SectionLabel(label: 'Quick Actions'),
                          const SizedBox(height: 12),
                          _QuickActionsGrid(role: role),
                          const SizedBox(height: 24),
                          _SectionLabel(label: 'Features'),
                          const SizedBox(height: 12),
                          _FeatureCards(role: role),
                          const SizedBox(height: 24),
                          _BrandingFooter(),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

// ─── Sliver App Bar ─────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  final String firstName;
  final String role;
  final String greeting;
  final String today;

  const _HomeAppBar({
    required this.firstName,
    required this.role,
    required this.greeting,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: KenwellColors.secondaryNavy,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                KenwellColors.secondaryNavy,
                KenwellColors.secondaryNavyLight,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                color: KenwellColors.primaryGreenLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              firstName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (role.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: KenwellColors.primaryGreen
                                      .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: KenwellColors.primaryGreen
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: const TextStyle(
                                    color: KenwellColors.primaryGreenLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // KenWell logo / brand mark
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/app_logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_hospital_rounded,
                              color: KenwellColors.primaryGreen,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: KenwellColors.primaryGreenLight),
                      const SizedBox(width: 6),
                      Text(
                        today,
                        style: const TextStyle(
                          color: KenwellColors.primaryGreenLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'KenWell365',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: KenwellColors.neutralGrey,
      ),
    );
  }
}

// ─── Quick Actions Grid ──────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final String role;
  const _QuickActionsGrid({required this.role});

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context, role);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
    );
  }

  List<Widget> _buildItems(BuildContext context, String role) {
    final bool privileged = _isPrivileged(role);

    final List<_QuickActionTile> tiles = [
      _QuickActionTile(
        icon: Icons.calendar_month_rounded,
        label: 'Calendar',
        description: 'View & register events',
        color: KenwellColors.secondaryNavy,
        onTap: () => context.pushNamed('calendar'),
      ),
      _QuickActionTile(
        icon: Icons.bar_chart_rounded,
        label: 'Statistics',
        description: 'Reports & analytics',
        color: const Color(0xFF1565C0),
        onTap: () => context.pushNamed('stats'),
      ),
      if (privileged)
        _QuickActionTile(
          icon: Icons.app_registration_rounded,
          label: 'Registrations',
          description: 'Manage registrations',
          color: const Color(0xFF6A1B9A),
          onTap: () => context.pushNamed('myRegistrationManagement'),
        ),
      _QuickActionTile(
        icon: Icons.person_rounded,
        label: 'My Profile',
        description: 'Account & settings',
        color: KenwellColors.primaryGreenDark,
        onTap: () => context.pushNamed('profile'),
      ),
    ];
    return tiles;
  }

  bool _isPrivileged(String role) {
    final r = role.toUpperCase();
    return r == 'ADMIN' || r == 'TOP MANAGEMENT' || r == 'PROJECT MANAGER';
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
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

// ─── Feature Cards ───────────────────────────────────────────────────────────

class _FeatureCards extends StatelessWidget {
  final String role;
  const _FeatureCards({required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FeatureCard(
          icon: Icons.health_and_safety_rounded,
          title: 'Wellness Events',
          description:
              'Participate in on-site health screenings, HIV/TB testing, and wellness campaigns scheduled for your community.',
          accentColor: KenwellColors.primaryGreen,
          onTap: () => context.pushNamed('calendar'),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.monitor_heart_rounded,
          title: 'Health Screening',
          description:
              'Track health metrics including blood pressure, BMI, glucose levels, and access risk assessment results.',
          accentColor: const Color(0xFF1565C0),
          onTap: () => context.pushNamed('stats'),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.insights_rounded,
          title: 'Reports & Analytics',
          description:
              'Access detailed statistical reports and visual breakdowns of event outcomes and population health trends.',
          accentColor: const Color(0xFF6A1B9A),
          onTap: () => context.pushNamed('stats'),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Branding Footer ─────────────────────────────────────────────────────────

class _BrandingFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KenwellColors.secondaryNavy.withValues(alpha: 0.04),
            KenwellColors.primaryGreen.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KenwellColors.neutralDivider,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/app_logo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_hospital_rounded,
                  color: KenwellColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KenWell365',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: KenwellColors.secondaryNavy,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Corporate Health & Wellness Platform',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: KenwellColors.neutralGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
