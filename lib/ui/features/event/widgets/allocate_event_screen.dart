import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_modern_section_header.dart';
import 'package:kenwell_health_app/ui/shared/ui/logo/app_logo.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/containers/gradient_container.dart';
import '../../../shared/ui/badges/number_badge.dart';
import '../../user_management/viewmodel/user_management_view_model.dart';
import '../../user_management/widgets/sections/user_filter_chips.dart';
import '../../user_management/widgets/sections/user_search_bar.dart';
import 'package:kenwell_health_app/data/services/user_event_service.dart';
import 'package:kenwell_health_app/data/repositories_dcl/user_event_repository.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/models/user_model.dart';

// AllocateEventScreen allows assigning a wellness event to multiple users
class AllocateEventScreen extends StatefulWidget {
  final void Function(List<String> assignedUserIds) onAllocate;
  final WellnessEvent event;

  // Constructor
  const AllocateEventScreen({
    super.key,
    required this.onAllocate,
    required this.event,
  });

  @override
  State<AllocateEventScreen> createState() => _AllocateEventScreenState();
}

// State class for AllocateEventScreen
class _AllocateEventScreenState extends State<AllocateEventScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _assignedUserIds = {};
  bool _isLoadingAssignedUsers = true;

  // Initialize state
  @override
  void initState() {
    super.initState();
    // Load users and fetch already assigned users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().loadUsers();
      _fetchAssignedUsers();
    });
  }

  // Fetch users already assigned to this event
  Future<void> _fetchAssignedUsers() async {
    setState(() => _isLoadingAssignedUsers = true);
    try {
      final repo = UserEventRepository();
      final assignedIds = await repo.fetchAssignedUserIds(widget.event.id);
      if (mounted) {
        setState(() {
          _assignedUserIds.clear();
          _assignedUserIds.addAll(assignedIds);
          _isLoadingAssignedUsers = false;
        });
        debugPrint(
            'AllocateEventScreen: Loaded ${assignedIds.length} already assigned users');
      }
    } catch (e) {
      debugPrint('AllocateEventScreen: Error fetching assigned users: $e');
      if (mounted) {
        setState(() => _isLoadingAssignedUsers = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserOptions(UserModel user) {
    final theme = Theme.of(context);
    final isAssigned = _assignedUserIds.contains(user.id);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${user.firstName} ${user.lastName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (!isAssigned)
              ListTile(
                leading:
                    Icon(Icons.person_add, color: theme.colorScheme.primary),
                title: Text('Assign', style: theme.textTheme.bodyMedium),
                onTap: () {
                  context.pop();
                  _assignUser(user);
                },
              ),
            if (isAssigned)
              ListTile(
                leading:
                    Icon(Icons.person_remove, color: theme.colorScheme.error),
                title: Text(
                  'Unassign',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  context.pop();
                  _unassignUser(user);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _assignUser(UserModel user) async {
    final theme = Theme.of(context);

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Assign event to user
    await UserEventService.addUserEvent(
      event: widget.event,
      user: user,
    );

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    // Refresh assigned users list
    await _fetchAssignedUsers();

    // Show success message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event assigned to ${user.firstName} ${user.lastName}'),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _unassignUser(UserModel user) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unassign User',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to unassign ${user.firstName} ${user.lastName} from this event?',
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
              'Unassign',
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Unassign event from user
    //final repo = UserEventRepository();
    //await repo.removeUserEvent(widget.event.id, user.id);

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    // Refresh assigned users list
    await _fetchAssignedUsers();

    // Show success message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${user.firstName} ${user.lastName} unassigned successfully'),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, ThemeData theme, {int? number}) {
    final isAssigned = _assignedUserIds.contains(user.id);

    final roleIcons = {
      'ADMIN': Icons.admin_panel_settings,
      'TOP MANAGEMENT': Icons.business_center,
      'PROJECT MANAGER': Icons.manage_accounts,
      'PROJECT COORDINATOR': Icons.event,
      'HEALTH PRACTITIONER': Icons.medical_services,
      'CLIENT': Icons.person,
    };

    return Slidable(
      key: ValueKey(user.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (!isAssigned)
            SlidableAction(
              onPressed: (_) => _assignUser(user),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: Icons.person_add,
              label: 'Assign',
            ),
          if (isAssigned)
            SlidableAction(
              onPressed: (_) => _unassignUser(user),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.person_remove,
              label: 'Unassign',
            ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showUserOptions(user),
        onLongPress: () => _showUserOptions(user),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Number badge (if provided)
              if (number != null) ...[
                NumberBadge(number: number),
                const SizedBox(width: 12),
              ],

              // Icon instead of avatar with initials
              Icon(
                roleIcons[user.role] ?? Icons.person,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isAssigned ? Icons.verified : Icons.error_outline,
                          color: isAssigned ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAssigned ? 'Assigned' : 'Not Assigned',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isAssigned ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Role badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.role,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Allocate Event',
        titleColor: Colors.white,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFF201C58),
        centerTitle: true,
      ),
      // Body of the screen
      body: Consumer<UserManagementViewModel>(
        builder: (context, viewModel, _) {
          final filteredUsers = viewModel.filteredUsers;
          final totalUsers = viewModel.users.length;
          final assignedCount = _assignedUserIds.length;
          final notAssignedCount = totalUsers - assignedCount;
          final filterActive = viewModel.selectedFilter != 'all' ||
              viewModel.searchQuery.isNotEmpty;

          if (viewModel.isLoading && viewModel.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 200),
                  const SizedBox(height: 16),
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create users first to allocate events',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadUsers,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      //const AppLogo(size: 200),

                      const SizedBox(height: 16), // Stats header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GradientContainer.purpleGreen(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Show filter status and user counts
                                    Text(
                                      filterActive
                                          ? 'Showing Users: ${filteredUsers.length} of $totalUsers'
                                          : '$totalUsers Total Users',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$assignedCount assigned',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$notAssignedCount not assigned',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search and filter section with background
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
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
                            const SizedBox(height: 8),
                            UserFilterChips(
                              selectedFilter: viewModel.selectedFilter,
                              onFilterChanged: viewModel.setFilter,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: KenwellModernSectionHeader(
                            title: 'Assigned Users',
                            subtitle:
                                'Manage which users are assigned to this wellness event.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap on a user to assign or unassign them from this event:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // User list
                if (filteredUsers.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(theme),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(user, theme, number: index + 1);
                        },
                        childCount: filteredUsers.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
