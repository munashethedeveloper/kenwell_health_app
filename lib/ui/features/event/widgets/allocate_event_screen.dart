import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
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
import 'sections/allocate_user_card.dart';

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
            if (!isAssigned)
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person_add_rounded,
                      color: theme.colorScheme.primary, size: 18),
                ),
                title: const Text('Assign'),
                subtitle: const Text('Add this user to the event'),
                onTap: () {
                  context.pop();
                  _assignUser(user);
                },
              ),
            if (isAssigned)
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person_remove_rounded,
                      color: theme.colorScheme.error, size: 18),
                ),
                title: Text(
                  'Unassign',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Remove this user from the event'),
                onTap: () {
                  context.pop();
                  _unassignUser(user);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignUser(UserModel user) async {
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
    final repo = UserEventRepository();
    await repo.removeUserEvent(widget.event.id, user.id);

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    // Refresh assigned users list immediately
    await _fetchAssignedUsers();
  }

  Widget _buildEmptyState(ThemeData theme) {
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
              'No users found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF201C58),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use'),
        content: const Text(
          'Swipe left on a user card to reveal the Assign or Unassign action.\n\n'
          'Long press a card to view a menu with the same options.\n\n'
          'Tap the refresh icon to reload the latest assignment data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
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
      appBar: KenwellAppBar(
        //title: 'Allocate Event: ${widget.event.title}',
        title: 'KenWell365',
        titleColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: KenwellColors.primaryGreen,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,
                color: Colors.white, semanticLabel: 'Refresh'),
            tooltip: 'Refresh',
            onPressed: _fetchAssignedUsers,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline,
                color: Colors.white, semanticLabel: 'Help'),
            tooltip: 'Help',
            onPressed: _showHelpDialog,
          ),
        ],
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
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
                      'No users available',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF201C58),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create users first to allocate events',
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

          return RefreshIndicator(
            onRefresh: viewModel.loadUsers,
            child: CustomScrollView(
              slivers: [
                // ── Gradient section header ───────────────────────────
                SliverToBoxAdapter(
                  child: KenwellGradientHeader(
                    // label: 'ALLOCATE',
                    title: 'Allocate\nEvent',
                    subtitle:
                        'Allocate users to the ${widget.event.title} event',
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      /*  // Stats header
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
                                          Icons.check_circle_rounded,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          size: 13,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$assignedCount assigned',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          Icons.radio_button_unchecked_rounded,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          size: 13,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$notAssignedCount unassigned',
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
                      
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), */

                      /*             // Section title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.event_rounded,
                                color: theme.primaryColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Allocate Event',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF201C58),
                                    ),
                                  ),
                                  Text(
                                    widget.event.title,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12), */

                      // Search and filter card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: KenwellColors.secondaryNavy
                                .withValues(alpha: 0.08),
                            width: 2.5,
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
                            Text(
                              'Search users:',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF201C58),
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                const Icon(
                                  Icons.tune_rounded,
                                  size: 15,
                                  color: KenwellColors.primaryGreen,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Filter by role:',
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
                      const SizedBox(height: 32),
                      const SizedBox(height: 16),
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
                          return AllocateUserCard(
                          user: user,
                          number: index + 1,
                          isAssigned: _assignedUserIds.contains(user.id),
                          onAssign: () => _assignUser(user),
                          onUnassign: () => _unassignUser(user),
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
      ),
    );
  }
}
