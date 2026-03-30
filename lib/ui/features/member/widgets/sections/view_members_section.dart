import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_empty_state.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/models/member.dart';
import '../../../../../domain/constants/role_permissions.dart';
import '../../../profile/view_model/profile_view_model.dart';
import '../../view_model/member_registration_view_model.dart';
import '../member_events_screen.dart';
import 'member_card_widget.dart';
import 'member_filter_chips.dart';
import 'member_search_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

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
      AppSnackbar.showSuccess(
          context, viewModel.successMessage ?? 'Member deleted successfully');
    } else if (mounted) {
      AppSnackbar.showError(
          context, viewModel.errorMessage ?? 'Failed to delete member');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberDetailsViewModel>(
      builder: (context, viewModel, child) {


        if (viewModel.isLoading && viewModel.members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalMembers = viewModel.members.length;
        final filteredMembers = viewModel.filteredMembers;
        final maleCount =
            viewModel.members.where((m) => m.gender == 'Male').length;
        final femaleCount =
            viewModel.members.where((m) => m.gender == 'Female').length;

        return RefreshIndicator(
          onRefresh: viewModel.loadMembers,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats header ────────────────────────────────────
                    _MembersStatsHeader(
                      totalMembers: totalMembers,
                      maleCount: maleCount,
                      femaleCount: femaleCount,
                    ),

                    // ── Search bar + inline filter button ───────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: MemberSearchBar(
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
                          _MembersFilterButton(viewModel: viewModel),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Member list or empty states
              if (viewModel.members.isEmpty)
                const SliverToBoxAdapter(
                  child: KenwellEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'No members yet',
                    message: 'Create your first member to get started',
                  ),
                )
              else if (filteredMembers.isEmpty)
                const SliverToBoxAdapter(
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

// ── Stats header (mirrors _AllocateStatsHeader in allocate_event_screen.dart) ─

class _MembersStatsHeader extends StatelessWidget {
  const _MembersStatsHeader({
    required this.totalMembers,
    required this.maleCount,
    required this.femaleCount,
  });

  final int totalMembers;
  final int maleCount;
  final int femaleCount;

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
            'Registered Members',
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
            'Search and manage your members',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MemberStatPill(
                icon: Icons.people_rounded,
                label: '$totalMembers',
                sublabel: 'Total',
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              _MemberStatPill(
                icon: Icons.male_rounded,
                label: '$maleCount',
                sublabel: 'Male',
                color: const Color(0xFF93C5FD),
              ),
              const SizedBox(width: 8),
              _MemberStatPill(
                icon: Icons.female_rounded,
                label: '$femaleCount',
                sublabel: 'Female',
                color: const Color(0xFFF9A8D4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberStatPill extends StatelessWidget {
  const _MemberStatPill({
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

class _MembersFilterButton extends StatelessWidget {
  const _MembersFilterButton({required this.viewModel});

  final MemberDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final hasFilter = viewModel.selectedFilter != 'All';
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
        child: const _MembersFilterSheet(),
      ),
    );
  }
}

class _MembersFilterSheet extends StatelessWidget {
  const _MembersFilterSheet();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemberDetailsViewModel>();
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
                'Filter Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: KenwellColors.secondaryNavy,
                ),
              ),
              const Spacer(),
              if (vm.selectedFilter != 'All')
                TextButton(
                  onPressed: () {
                    vm.setFilter('All');
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
            'Filter by gender:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KenwellColors.secondaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          MemberFilterChips(
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
