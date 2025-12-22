import 'package:flutter/material.dart';
import 'package:kenwell_health_app/routing/route_names.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/auth_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';

class MyProfileMenuScreen extends StatelessWidget {
  const MyProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadProfile(),
      child: const _MyProfileMenuScreenBody(),
    );
  }
}

class _MyProfileMenuScreenBody extends StatelessWidget {
  const _MyProfileMenuScreenBody();

  Future<void> _logout(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();
    await authVM.logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: const KenwellAppBar(
          title: 'My Profile',
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: vm.isLoadingProfile
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // App Logo
                      const AppLogo(size: 120),
                      const SizedBox(height: 24),

                      // User Information
                      if (vm.user != null) ...[
                        Text(
                          '${vm.firstName} ${vm.lastName}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: KenwellColors.secondaryNavy,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: KenwellColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            vm.role,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: KenwellColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // View My Profile Card
                      _ProfileMenuCard(
                        title: 'View My Profile',
                        description: 'Manage your user profile details',
                        icon: Icons.person,
                        onTap: () {
                          Navigator.pushNamed(context, RouteNames.profile);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Logout Card
                      _ProfileMenuCard(
                        title: 'Logout',
                        description: 'Log out of your profile',
                        icon: Icons.logout,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileMenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: KenwellColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                Icons.chevron_right,
                color: KenwellColors.primaryGreen,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
