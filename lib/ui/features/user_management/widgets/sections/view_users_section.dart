import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_empty_state.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/models/user_model.dart';
import '../../../../../domain/constants/role_permissions.dart';
import '../../../profile/view_model/profile_view_model.dart';
import '../../viewmodel/user_management_view_model.dart';
import 'user_card_widget.dart';
import 'user_filter_chips.dart';
import 'user_search_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

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
      AppSnackbar.showSuccess(
          context, viewModel.successMessage ?? 'User deleted successfully');
    } else if (mounted) {
      AppSnackbar.showError(
          context, viewModel.errorMessage ?? 'Failed to delete user');
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
      AppSnackbar.showSuccess(
        context,
        viewModel.successMessage ?? 'Password reset email sent successfully',
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );
    } else if (mounted) {
      AppSnackbar.showError(
          context, viewModel.errorMessage ?? 'Failed to send reset email',
          duration: const Duration(seconds: 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get filtered users and stats
        final filteredUsers = viewModel.filteredUsers;
        final totalUsers = viewModel.users.length;
        final verifiedCount = viewModel.verifiedUsersCount;
        final unverifiedCount = viewModel.unverifiedUsersCount;

        return RefreshIndicator(
          onRefresh: viewModel.loadUsers,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats header ─────────────────────────────────────
                    _UsersStatsHeader(
                      totalUsers: totalUsers,
                      verifiedCount: verifiedCount,
                      unverifiedCount: unverifiedCount,
                    ),

                    // ── Search bar + inline filter button ────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: UserSearchBar(
                              controller: _searchController,
                              searchQuery: viewModel.searchQuery,
                              onChanged: (value) =>
                                  viewModel.setSearchQuery(value),
                              onClear: () {
                                _searchController.clear();
                                viewModel.clearSearch();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          _UsersFilterButton(viewModel: viewModel),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // User list or empty states
              if (viewModel.users.isEmpty)
                const SliverToBoxAdapter(
                  child: KenwellEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'No users yet',
                    message: 'Create your first user to get started',
                  ),
                )
              else if (filteredUsers.isEmpty)
                const SliverToBoxAdapter(
                  child: KenwellEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'No users found',
                    message: 'Try adjusting your search or filter',
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

// ── Helper widget ─────────────────────────────────────────────────────────────

// ── Stats header (mirrors _AllocateStatsHeader in allocate_event_screen.dart) ─

class _UsersStatsHeader extends StatelessWidget {
  const _UsersStatsHeader({
    required this.totalUsers,
    required this.verifiedCount,
    required this.unverifiedCount,
  });

  final int totalUsers;
  final int verifiedCount;
  final int unverifiedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KenwellColors.secondaryNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UserStatPill(
                icon: Icons.people_rounded,
                label: '$totalUsers',
                sublabel: 'Total Users',
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              _UserStatPill(
                icon: Icons.verified_rounded,
                label: '$verifiedCount',
                sublabel: 'Verified',
                color: const Color(0xFF86EFAC),
              ),
              const SizedBox(width: 8),
              _UserStatPill(
                icon: Icons.error_outline_rounded,
                label: '$unverifiedCount',
                sublabel: 'Unverified',
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserStatPill extends StatelessWidget {
  const _UserStatPill({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter button ─────────────────────────────────────────────────────────────

class _UsersFilterButton extends StatelessWidget {
  const _UsersFilterButton({required this.viewModel});

  final UserManagementViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final hasFilter = viewModel.selectedFilter != 'all';
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: hasFilter ? KenwellColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                hasFilter ? KenwellColors.primaryGreen : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: hasFilter ? Colors.white : KenwellColors.secondaryNavy,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: const _UsersFilterSheet(),
      ),
    );
  }
}

class _UsersFilterSheet extends StatelessWidget {
  const _UsersFilterSheet();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserManagementViewModel>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Text(
                'Filter Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: KenwellColors.secondaryNavy,
                ),
              ),
              const Spacer(),
              if (vm.selectedFilter != 'all')
                TextButton(
                  onPressed: () {
                    vm.setFilter('all');
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: KenwellColors.primaryGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Filter by role:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KenwellColors.secondaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          UserFilterChips(
            selectedFilter: vm.selectedFilter,
            onFilterChanged: (value) {
              vm.setFilter(value);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KenwellColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Apply',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
