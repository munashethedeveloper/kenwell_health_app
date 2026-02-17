import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/models/member.dart';
import '../../../../../domain/constants/role_permissions.dart';
import '../../../../shared/ui/containers/gradient_container.dart';
import '../../../profile/view_model/profile_view_model.dart';
import '../../view_model/member_registration_view_model.dart';
import '../member_events_screen.dart';
import 'member_card_widget.dart';
import 'member_filter_chips.dart';
import 'member_search_bar.dart';

/// View members section with search, filter, and member list
class ViewMembersSection extends StatefulWidget {
  const ViewMembersSection({super.key});

  @override
  State<ViewMembersSection> createState() => _ViewMembersSectionState();
}

class _ViewMembersSectionState extends State<ViewMembersSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load members when section is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberDetailsViewModel>().loadMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMemberOptions(Member member) {
    final theme = Theme.of(context);
    final viewModel = context.read<MemberDetailsViewModel>();
    final profileVM = context.read<ProfileViewModel>();

    // Check permissions
    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_member');

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
              '${member.name} ${member.surname}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              member.email ?? 'No email',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // View Events option
            ListTile(
              leading: Icon(Icons.event, color: theme.colorScheme.primary),
              title: Text(
                'View Events',
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () {
                context.pop();
                _navigateToMemberEvents(member);
              },
            ),
            if (canDelete)
              ListTile(
                leading: Icon(Icons.delete, color: theme.colorScheme.error),
                title: Text(
                  'Delete Member',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  context.pop();
                  _deleteMember(member, viewModel);
                },
              ),
            if (!canDelete)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Tap an option above',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToMemberEvents(Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberEventsScreen(member: member),
      ),
    );
  }

  Future<void> _deleteMember(
      Member member, MemberDetailsViewModel viewModel) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Member',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete ${member.name} ${member.surname}? This action cannot be undone.',
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

    final success = await viewModel.deleteMember(
        member.id, '${member.name} ${member.surname}');

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(viewModel.successMessage ?? 'Member deleted successfully'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to delete member')),
      );
    }
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
            'No members found',
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

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberDetailsViewModel>(
      builder: (context, viewModel, child) {
        final theme = Theme.of(context);

        if (viewModel.isLoading && viewModel.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.members.isEmpty) {
          return _buildEmptyState(theme);
        }

        // Get filtered members and stats
        final filteredMembers = viewModel.filteredMembers;
        final totalMembers = viewModel.members.length;
        final filterActive = viewModel.selectedFilter != 'All' ||
            viewModel.searchQuery.isNotEmpty;

        return RefreshIndicator(
          onRefresh: viewModel.loadMembers,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Stats header
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
                                  // Show filter status and member counts
                                  Text(
                                    filterActive
                                        ? 'Showing Members: ${filteredMembers.length} of $totalMembers'
                                        : '$totalMembers Total Members',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                          MemberSearchBar(
                            controller: _searchController,
                            searchQuery: viewModel.searchQuery,
                            onChanged: (value) => viewModel.setSearchQuery(value),
                            onClear: () {
                              _searchController.clear();
                              viewModel.clearSearch();
                            },
                          ),
                          const SizedBox(height: 8),
                          MemberFilterChips(
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
              // Member list
              if (filteredMembers.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: _buildEmptyState(theme),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final member = filteredMembers[index];
                        return MemberCardWidget(
                          member: member,
                          onTap: () => _showMemberOptions(member),
                          onDelete: () => _deleteMember(member, viewModel),
                        );
                      },
                      childCount: filteredMembers.length,
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
    );
  }
}
