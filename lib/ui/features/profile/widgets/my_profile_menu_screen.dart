import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/auth_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_action_card.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/dialogs/confirmation_dialog.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_modern_section_header.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';
import 'package:provider/provider.dart';

class MyProfileMenuScreen extends StatelessWidget {
  const MyProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load profile when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ProfileViewModel>().loadProfile();
      }
    });

    return const _MyProfileMenuScreenBody();
  }
}

class _MyProfileMenuScreenBody extends StatelessWidget {
  const _MyProfileMenuScreenBody();

  Future<void> _logout(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      icon: Icons.logout,
    );

    if (!confirmed) return;

    await authVM.logout();

    if (!context.mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) => Scaffold(
        backgroundColor: KenwellColors.neutralBackground,
        body: vm.isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // ── Gradient header ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: _ProfileHeader(vm: vm),
                  ),
                  // ── Action cards ──────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const KenwellModernSectionHeader(
                          label: 'PROFILE',
                          title: 'My Profile',
                          subtitle: 'Manage your account settings',
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 20),
                        KenwellActionCard(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF201C58), Color(0xFF3B3F86)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          badgeLabel: 'Account',
                          onTap: () => context.pushNamed('profile'),
                        ),
                        const SizedBox(height: 16),
                        KenwellActionCard(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF90C048), Color(0xFF5E8C1F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get assistance and FAQs',
                          badgeLabel: 'Support',
                          onTap: () => context.pushNamed('help'),
                        ),
                        const SizedBox(height: 16),
                        // Destructive logout card
                        _LogoutCard(onTap: () => _logout(context)),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Gradient profile header ──────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
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
              // Section label
              const KenwellSectionLabel(label: 'PROFILE'),
              const SizedBox(height: 10),
              const Text(
                'My\nProfile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your personal details and preferences.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              // Avatar row
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: KenwellColors.primaryGreen
                          .withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        vm.firstName.isNotEmpty
                            ? vm.firstName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vm.firstName} ${vm.lastName}'.trim(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (vm.role.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              vm.role,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout card (red destructive style) ─────────────────────────────────────

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sign out of your account',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.red.withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



