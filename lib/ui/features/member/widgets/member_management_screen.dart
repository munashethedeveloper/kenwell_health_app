import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/labels/kenwell_section_label.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/member_registration_view_model.dart';
import 'sections/create_member_section.dart';
import 'sections/view_members_section.dart';

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
                title: 'Member Management',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Members refreshed'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh members',
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        context.pushNamed('help');
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
                      // ── Gradient section header ────────────────────────
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        padding: const EdgeInsets.all(20),
                        //width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              KenwellColors.secondaryNavy,
                              Color(0xFF2E2880),
                              KenwellColors.primaryGreenDark,
                            ],
                            stops: [0.0, 0.6, 1.0],

                            // stops: [0.0, 0.55, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const KenwellSectionLabel(label: 'MEMBERS'),
                              const SizedBox(height: 10),
                              const Text(
                                'Member\nManagement',
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
                                'Create and view registered members.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
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
