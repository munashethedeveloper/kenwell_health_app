import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/member_registration_view_model.dart';
import 'sections/create_member_section.dart';
import 'sections/view_members_section.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/routing/app_routes.dart';

/// Member registration screen with create and view members functionality
///
/// This screen has TWO tabs:
/// 1. "Create Members" tab - Form to register new event participants
/// 2. "View Members" tab - List all members with search/filter functionality
///
/// Navigation Path: Main App → Users Tab → My User Management → Member Management
/// Route: /member-management (name: 'memberManagement')
///
/// See VIEW_MEMBERS_TAB_GUIDE.md for detailed navigation instructions
class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemberDetailsViewModel(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final profileVM = context.watch<ProfileViewModel>();

          // Check permissions
          final canCreateMember =
              RolePermissions.canAccessFeature(profileVM.role, 'create_member');
          final canViewMembers =
              RolePermissions.canAccessFeature(profileVM.role, 'view_members');

          // Determine number of tabs based on permissions
          final List<Tab> tabs = [];
          //final List<Widget> tabViews = [];

          if (canCreateMember) {
            tabs.add(const Tab(
                icon: Icon(Icons.person_add_rounded), text: 'Create Members'));
          }

          if (canViewMembers) {
            tabs.add(const Tab(
                icon: Icon(Icons.group_rounded), text: 'View Members'));
          }

          // If user has no permissions, show a message
          if (tabs.isEmpty) {
            return Scaffold(
              appBar: const KenwellAppBar(
                automaticallyImplyLeading: true,
                title: 'Member Management',
                titleColor: Colors.white,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              body: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.08),
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
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 56,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Access',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF201C58),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You do not have permission to access member management features.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
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
              appBar: KenwellAppBar(
                title: 'KenWell365',
                titleColor: Colors.white,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                automaticallyImplyLeading: true,
                bottom: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 3.0,
                      color: theme.colorScheme.onPrimary,
                    ),
                    insets: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor:
                      theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  tabs: tabs,
                ),
                actions: [
                  // Refresh members button
                  IconButton(
                    onPressed: () {
                      if (mounted) {
                        context.read<MemberDetailsViewModel>().loadMembers();
                        AppSnackbar.showSuccess(context, 'Members refreshed',
                            duration: const Duration(seconds: 1));
                      }
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh members',
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        context.pushNamed(AppRoutes.help);
                      }
                    },
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    label: const Text(
                      'Help',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              body: Consumer<MemberDetailsViewModel>(
                builder: (context, viewModel, child) {
                  // Build tab views with callbacks that use the view model
                  final dynamicTabViews = <Widget>[];

                  if (canCreateMember) {
                    dynamicTabViews.add(CreateMemberSection(
                      onMemberCreated: () {
                        // Reload members when a new member is created
                        viewModel.loadMembers();
                      },
                    ));
                  }

                  if (canViewMembers) {
                    dynamicTabViews.add(const ViewMembersSection());
                  }

                  return Column(
                    children: [
                      Builder(
                        builder: (ctx) {
                          final tabController = DefaultTabController.of(ctx);
                          return AnimatedBuilder(
                            animation: tabController,
                            builder: (_, __) {
                              final idx = tabController.index;
                              // Determine title based on active tab
                              String title = 'Member Management';
                              String subtitle =
                                  'Create and view registered members';
                              if (canCreateMember && canViewMembers) {
                                if (idx == 0) {
                                  title = 'New Member\nRegistration';
                                  subtitle =
                                      'Register a new wellness participant';
                                } else {
                                  title = 'Registered Members';
                                  subtitle = 'Search and manage your members';
                                }
                              } else if (canCreateMember) {
                                title = 'New Member\nRegistration';
                                subtitle =
                                    'Register a new wellness participant';
                              } else if (canViewMembers) {
                                title = 'Registered Members';
                                subtitle = 'Search and manage your members';
                              }
                              return KenwellGradientHeader(
                                title: title,
                                subtitle: subtitle,
                              );
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: TabBarView(
                          children: dynamicTabViews,
                        ),
                      ),
                    ],
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
