/* import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/member/view_model/member_registration_view_model.dart';
import 'package:kenwell_health_app/ui/features/member/widgets/member_registration_screen.dart';
import 'package:provider/provider.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../profile/view_model/profile_view_model.dart';

/// User management screen with create and view users functionality
class MyMemberManagementScreen extends StatefulWidget {
  const MyMemberManagementScreen({super.key});

  @override
  State<MyMemberManagementScreen> createState() =>
      _MyMemberManagementScreenState();
}

class _MyMemberManagementScreenState extends State<MyMemberManagementScreen> {
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
          final List<Widget> tabViews = [];

     /*      if (canCreateMember) {
            tabs.add(
                const Tab(icon: Icon(Icons.person_add), text: 'Create Member'));
            tabViews.add(const MemberDetailsScreen(
                viewModel: viewModel, onNext: onNext));
          }

          if (canViewMembers) {
            tabs.add(const Tab(icon: Icon(Icons.group), text: 'View Members'));
            tabViews.add(const ViewMembersSection());
          } */

          // If user has no permissions, show a message
          if (tabs.isEmpty) {
            return Scaffold(
              appBar: const KenwellAppBar(
                automaticallyImplyLeading: true,
                title: 'Member Management',
                titleColor: Color(0xFF201C58),
                titleStyle: TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
                //automaticallyImplyLeading: true,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Access',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You do not have permission to access member management features.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                titleColor: const Color(0xFF201C58),
                titleStyle: const TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
                automaticallyImplyLeading: false,
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
                    icon: const Icon(Icons.refresh, color: Color(0xFF201C58)),
                    tooltip: 'Refresh members',
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        context.pushNamed('help');
                      }
                    },
                    icon: const Icon(Icons.help_outline,
                        color: Color(0xFF201C58)),
                    label: const Text(
                      'Help',
                      style: TextStyle(color: Color(0xFF201C58)),
                    ),
                  ),
                ],
              ),
              body: Consumer<MemberDetailsViewModel>(
                builder: (context, viewModel, child) {
                  // Update tab views with onUserCreated callback
                  final dynamicTabViews = <Widget>[];

               /*    if (canCreateMember) {
                    dynamicTabViews.add(CreateMemberSection(
                      onUserCreated: () {
                        // Reload members when a new member is created
                        viewModel.loadMembers();
                      },
                    ));
                  }

                  if (canViewMembers) {
                    dynamicTabViews.add(const ViewMembersSection());
                  } */

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
 */
