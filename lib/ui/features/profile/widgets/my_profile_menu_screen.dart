import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/auth_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/dialogs/confirmation_dialog.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_modern_section_header.dart';
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
        backgroundColor: KenwellColors.primaryGreen,
        body: SafeArea(
          child: Column(
            children: [
              // Profile header section on navy background
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Column(
                  children: [
                    // Top row: back button + centered title
                    Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'KenWell365',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Spacer to balance back button
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Avatar with first-name initial
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: KenwellColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: vm.isLoadingProfile
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Center(
                              child: Text(
                                vm.firstName.isNotEmpty
                                    ? vm.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    if (!vm.isLoadingProfile) ...[
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
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            vm.role,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // Menu panel — white with rounded top corners
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*    const Text(
                          'ACCOUNT SETTINGS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                            letterSpacing: 1.2,
                          ),
                        ), */
                        const KenwellModernSectionHeader(
                          title: 'My Profile',
                          subtitle: 'View your profile',
                        ),
                        const SizedBox(height: 16),
                        // Menu items
                        _ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () => context.pushNamed('profile'),
                        ),
                        _ProfileMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get assistance and FAQs',
                          onTap: () => context.pushNamed('help'),
                        ),
                        /*  const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: const Divider(
                            color: KenwellColors.primaryGreenLight,
                            //color: KenwellColors.secondaryNavy,
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ), */
                        _ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          isDestructive: true,
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withValues(alpha: 0.1)
                        : const Color(0xFF90C048).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isDestructive ? Colors.red : KenwellColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Colors.red
                              : const Color(0xFF201C58),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.5)
                      : KenwellColors.primaryGreen.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
