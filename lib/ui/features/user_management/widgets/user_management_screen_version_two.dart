import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../routing/route_names.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: KenwellAppBar(
                title: 'User Management',
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
                  tabs: const [
                    Tab(icon: Icon(Icons.person_add), text: 'Create User'),
                    Tab(icon: Icon(Icons.group), text: 'View Users'),
                  ],
                ),
                actions: [
                  // Sync verification status button
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Color(0xFF201C58)),
                    tooltip: 'More options',
                    onSelected: (value) async {
                      if (!mounted) return;
                      
                      if (value == 'sync_verification') {
                        // Show loading indicator
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text('Syncing your verification status...'),
                              ],
                            ),
                            duration: Duration(seconds: 10), // Fallback timeout if dismissal fails
                          ),
                        );
                        
                        // Sync verification status
                        await context
                            .read<UserManagementViewModel>()
                            .syncCurrentUserVerificationStatus();
                        
                        if (!mounted) return;
                        
                        // Hide loading snackbar
                        messenger.hideCurrentSnackBar();
                        
                        // Show result message
                        final viewModel = context.read<UserManagementViewModel>();
                        if (viewModel.successMessage != null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(viewModel.successMessage!),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else if (viewModel.errorMessage != null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'sync_verification',
                        child: Row(
                          children: [
                            Icon(Icons.sync, size: 20),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sync My Verification'),
                                Text(
                                  'Check if email is verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      if (mounted) {
                        context.read<UserManagementViewModel>().loadUsers();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Users refreshed'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF201C58)),
                    tooltip: 'Refresh users',
                  ),
                  TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        Navigator.pushNamed(context, RouteNames.help);
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
              body: Consumer<UserManagementViewModel>(
                builder: (context, viewModel, child) {
                  return TabBarView(
                    children: [
                      CreateUserSection(
                        onUserCreated: () {
                          // Reload users when a new user is created
                          viewModel.loadUsers();
                        },
                      ),
                      const ViewUsersSection(),
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
