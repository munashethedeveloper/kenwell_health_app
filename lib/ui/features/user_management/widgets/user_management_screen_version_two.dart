import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../viewmodel/user_management_view_model.dart';
import 'sections/create_user_section.dart';
import 'sections/view_users_section.dart';

/// User management screen with create and view users functionality
class UserManagementScreenVersionTwo extends StatefulWidget {
  const UserManagementScreenVersionTwo({super.key});

  @override
  State<UserManagementScreenVersionTwo> createState() =>
      _UserManagementScreenVersionTwoState();
}

class _UserManagementScreenVersionTwoState
    extends State<UserManagementScreenVersionTwo> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserManagementViewModel(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final profileVM = context.watch<ProfileViewModel>();

          // Check permissions
          final canCreateUser =
              RolePermissions.canAccessFeature(profileVM.role, 'create_user');
          final canViewUsers =
              RolePermissions.canAccessFeature(profileVM.role, 'view_users');

          // Determine number of tabs based on permissions
          final List<Tab> tabs = [];
          final List<Widget> tabViews = [];

          if (canCreateUser) {
            tabs.add(
                const Tab(icon: Icon(Icons.person_add), text: 'Create User'));
            tabViews.add(const CreateUserSection());
          }

          if (canViewUsers) {
            tabs.add(const Tab(icon: Icon(Icons.group), text: 'View Users'));
            tabViews.add(const ViewUsersSection());
          }

          // If user has no permissions, show a message
          if (tabs.isEmpty) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: const KenwellAppBar(
                automaticallyImplyLeading: true,
                title: 'User Management',
                titleColor: Color(0xFF201C58),
                titleStyle: TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
              ),
              body: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        theme.primaryColor.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.red.withValues(alpha: 0.15),
                              Colors.red.withValues(alpha: 0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 64,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Access',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF201C58),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You do not have permission to access user management features.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: KenwellAppBar(
                title: 'User Management',
                titleColor: const Color(0xFF201C58),
                titleStyle: const TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
                automaticallyImplyLeading: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF201C58)
                          .withValues(alpha: 0.6),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: tabs,
                    ),
                  ),
                ),
                actions: [
                  // Refresh users button
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (mounted) {
                          context.read<UserManagementViewModel>().loadUsers();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Users refreshed'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded,
                          color: Color(0xFF201C58)),
                      tooltip: 'Refresh users',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        context.pushNamed('help');
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.help_outline_rounded,
                        color: Color(0xFF201C58)),
                    label: const Text(
                      'Help',
                      style: TextStyle(
                        color: Color(0xFF201C58),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              body: Consumer<UserManagementViewModel>(
                builder: (context, viewModel, child) {
                  // Update tab views with onUserCreated callback
                  final dynamicTabViews = <Widget>[];

                  if (canCreateUser) {
                    dynamicTabViews.add(CreateUserSection(
                      onUserCreated: () {
                        // Reload users when a new user is created
                        viewModel.loadUsers();
                      },
                    ));
                  }

                  if (canViewUsers) {
                    dynamicTabViews.add(const ViewUsersSection());
                  }

                  return TabBarView(
                    children: dynamicTabViews,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
