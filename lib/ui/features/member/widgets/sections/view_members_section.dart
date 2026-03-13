import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_empty_state.dart';
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

    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_member');

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
                        '${member.name} ${member.surname}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF201C58),
                        ),
                      ),
                      Text(
                        member.email ?? 'No email',
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
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event_rounded,
                    color: theme.colorScheme.primary, size: 18),
              ),
              title: const Text('View Events'),
              subtitle: const Text('See events assigned to this member'),
              onTap: () {
                context.pop();
                _navigateToMemberEvents(member);
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
                  'Delete Member',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Permanently remove this member'),
                onTap: () {
                  context.pop();
                  _deleteMember(member, viewModel);
                },
              ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberDetailsViewModel>(
      builder: (context, viewModel, child) {
        final theme = Theme.of(context);

        if (viewModel.isLoading && viewModel.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

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
                                        ? 'Showing ${filteredMembers.length} of $totalMembers Members'
                                        : '$totalMembers Total Members',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ), */
                    //const SizedBox(height: 16),

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
                            'Search members:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF201C58),
                            ),
                          ),
                          const SizedBox(height: 8),
                          MemberSearchBar(
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
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade100,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                size: 15,
                                color: KenwellColors.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Filter by gender:',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF201C58),
                                ),
                              ),
                            ],
                          ),
                          MemberFilterChips(
                            selectedFilter: viewModel.selectedFilter,
                            onFilterChanged: viewModel.setFilter,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    /* const Text(
                      'View Registered Members',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF201C58),
                      ),
                    ),

                    const SizedBox(height: 16), */
                  ],
                ),
              ),

              // Member list or empty states
              if (viewModel.members.isEmpty)
                SliverToBoxAdapter(
                  child: KenwellEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No members yet',
                      message: 'Create your first member to get started',
                    ),
                )
              else if (filteredMembers.isEmpty)
                SliverToBoxAdapter(
                  child: KenwellEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No members found',
                      message: 'Try adjusting your search or filter',
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
                          number: index + 1,
                          onTap: () => _showMemberOptions(member),
                          onDelete: () => _deleteMember(member, viewModel),
                          onViewDetails: () => _navigateToMemberEvents(member),
                        );
                      },
                      childCount: filteredMembers.length,
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
