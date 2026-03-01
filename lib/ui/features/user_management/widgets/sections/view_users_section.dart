import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/models/user_model.dart';
import '../../../../../domain/constants/role_permissions.dart';
import '../../../../shared/ui/containers/gradient_container.dart';
import '../../../profile/view_model/profile_view_model.dart';
import '../../viewmodel/user_management_view_model.dart';
import 'user_card_widget.dart';
import 'user_filter_chips.dart';
import 'user_search_bar.dart';

/// View users section with search, filter, and user list
class ViewUsersSection extends StatefulWidget {
  const ViewUsersSection({super.key});

  @override
  State<ViewUsersSection> createState() => _ViewUsersSectionState();
}

class _ViewUsersSectionState extends State<ViewUsersSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserOptions(UserModel user) {
    final theme = Theme.of(context);
    final viewModel = context.read<UserManagementViewModel>();
    final profileVM = context.read<ProfileViewModel>();

    // Check permissions
    final canResetPassword = RolePermissions.canAccessFeature(
        profileVM.role, 'reset_user_credentials');
    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_user');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: theme.primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF201C58),
                        ),
                      ),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (canResetPassword)
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lock_reset_rounded,
                      color: theme.colorScheme.primary, size: 18),
                ),
                title: const Text('Reset Password'),
                subtitle: const Text(
                    'Send password reset link to this user\'s email'),
                onTap: () {
                  context.pop();
                  _resetPassword(user, viewModel);
                },
              ),
            if (canDelete)
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_rounded,
                      color: theme.colorScheme.error, size: 18),
                ),
                title: Text(
                  'Delete User',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Permanently remove this user'),
                onTap: () {
                  context.pop();
                  _deleteUser(user, viewModel);
                },
              ),
            if (!canResetPassword && !canDelete)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No actions available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(
      UserModel user, UserManagementViewModel viewModel) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete User',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete ${user.firstName} ${user.lastName}? This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Cancel',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await viewModel.deleteUser(
        user.id, '${user.firstName} ${user.lastName}');

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(viewModel.successMessage ?? 'User deleted successfully'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to delete user')),
      );
    }
  }

  Future<void> _resetPassword(
      UserModel user, UserManagementViewModel viewModel) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Send password reset email to ${user.email}?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Cancel',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              'Send Email',
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await viewModel.resetUserPassword(
        user.email, '${user.firstName} ${user.lastName}');

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.successMessage ??
                'Password reset email sent successfully',
            maxLines: 5,
          ),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Failed to send reset email',
            maxLines: 3,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildEmptyState(ThemeData theme, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: theme.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF201C58),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementViewModel>(
      builder: (context, viewModel, child) {
        final theme = Theme.of(context);

        if (viewModel.isLoading && viewModel.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get filtered users and stats
        final filteredUsers = viewModel.filteredUsers;
        final totalUsers = viewModel.users.length;
        final verifiedCount = viewModel.verifiedUsersCount;
        final unverifiedCount = viewModel.unverifiedUsersCount;
        final filterActive = viewModel.selectedFilter != 'all' ||
            viewModel.searchQuery.isNotEmpty;

        return RefreshIndicator(
          onRefresh: viewModel.loadUsers,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Stats header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GradientContainer.purpleGreen(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.people_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filterActive
                                        ? 'Showing ${filteredUsers.length} of $totalUsers Users'
                                        : '$totalUsers Total Users',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$verifiedCount verified',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$unverifiedCount unverified',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.swipe_left_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Swipe for options',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.group_rounded,
                              color: theme.primaryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registered Users',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF201C58),
                                ),
                              ),
                              Text(
                                'Tap a user card to long-press for more options',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search and filter card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserSearchBar(
                            controller: _searchController,
                            searchQuery: viewModel.searchQuery,
                            onChanged: (value) =>
                                viewModel.setSearchQuery(value),
                            onClear: () {
                              _searchController.clear();
                              viewModel.clearSearch();
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 15,
                                color: KenwellColors.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Filter by role',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF201C58),
                                ),
                              ),
                            ],
                          ),
                          UserFilterChips(
                            selectedFilter: viewModel.selectedFilter,
                            onFilterChanged: viewModel.setFilter,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // User list or empty states
              if (viewModel.users.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptyState(
                    theme,
                    'No users yet',
                    'Create your first user to get started',
                  ),
                )
              else if (filteredUsers.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptyState(
                    theme,
                    'No users found',
                    'Try adjusting your search or filter',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = filteredUsers[index];
                        return UserCardWidget(
                          user: user,
                          number: index + 1,
                          onTap: () => _showUserOptions(user),
                          onResetPassword: () =>
                              _resetPassword(user, viewModel),
                          onDelete: () => _deleteUser(user, viewModel),
                        );
                      },
                      childCount: filteredUsers.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      },
    );
  }
}
