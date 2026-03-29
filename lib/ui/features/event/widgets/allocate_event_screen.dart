import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_empty_state.dart';
import 'package:provider/provider.dart';
import '../../user_management/viewmodel/user_management_view_model.dart';
import '../../user_management/widgets/sections/user_filter_chips.dart';
import '../../user_management/widgets/sections/user_search_bar.dart';
import '../view_model/allocate_event_view_model.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/models/user_model.dart';
import 'sections/allocate_user_card.dart';

class AllocateEventScreen extends StatefulWidget {
  final void Function(List<String> assignedUserIds) onAllocate;
  final WellnessEvent event;
  const AllocateEventScreen({
    super.key,
    required this.onAllocate,
    required this.event,
  });

  @override
  State<AllocateEventScreen> createState() => _AllocateEventScreenState();
}

class _AllocateEventScreenState extends State<AllocateEventScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final AllocateEventViewModel _allocVM;

  @override
  void initState() {
    super.initState();
    _allocVM = AllocateEventViewModel(event: widget.event);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().loadUsers();
      _allocVM.loadAssignedUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _allocVM.dispose();
    super.dispose();
  }

  void _showUserOptions(UserModel user) {
    final theme = Theme.of(context);
    final isAssigned = _allocVM.isAssigned(user.id);

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
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await _allocVM.assignUser(user);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _unassignUser(UserModel user) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unassign User',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to unassign ${user.firstName} ${user.lastName} from this event?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text('Cancel',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error),
            child: Text('Unassign',
                style:
                    theme.textTheme.titleSmall?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await _allocVM.unassignUser(user);
    if (!mounted) return;
    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: KenwellAppBar(
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
            onPressed: _allocVM.loadAssignedUsers,
          ),
          TextButton.icon(
            onPressed: () => context.pushNamed('help'),
            icon: const Icon(Icons.help_outline, color: Colors.white),
            label: const Text('Help', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _allocVM,
        builder: (context, _) => Consumer<UserManagementViewModel>(
          builder: (context, viewModel, _) {
            final filteredUsers = viewModel.filteredUsers;
            final totalUsers = viewModel.users.length;
            final assignedCount = _allocVM.assignedCount;
            final notAssignedCount = totalUsers - assignedCount;

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
                  SliverToBoxAdapter(
                    child: _AllocateStatsHeader(
                      eventTitle: widget.event.title,
                      totalUsers: totalUsers,
                      assignedCount: assignedCount,
                      notAssignedCount: notAssignedCount,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
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
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
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
                  if (filteredUsers.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
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
                            return AllocateUserCard(
                              user: user,
                              number: index + 1,
                              isAssigned: _allocVM.isAssigned(user.id),
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
      ),
    );
  }
}

// ── Stats header with assignment counts ─────────────────────────────────────

class _AllocateStatsHeader extends StatelessWidget {
  const _AllocateStatsHeader({
    required this.eventTitle,
    required this.totalUsers,
    required this.assignedCount,
    required this.notAssignedCount,
  });

  final String eventTitle;
  final int totalUsers;
  final int assignedCount;
  final int notAssignedCount;

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
          const Text(
            'Allocate Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            eventTitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(
                icon: Icons.people_rounded,
                label: '$totalUsers',
                sublabel: 'Total Users',
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              _StatPill(
                icon: Icons.check_circle_outline_rounded,
                label: '$assignedCount',
                sublabel: 'Assigned Users',
                color: const Color(0xFF86EFAC),
              ),
              const SizedBox(width: 8),
              _StatPill(
                icon: Icons.pending_outlined,
                label: '$notAssignedCount',
                sublabel: 'Unassigned Users',
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
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
