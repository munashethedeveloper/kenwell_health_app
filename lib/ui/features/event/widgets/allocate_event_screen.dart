import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/containers/gradient_container.dart';
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
  final Set<String> _selectedUserIds = {};
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
        debugPrint('AllocateEventScreen: Loaded ${assignedIds.length} already assigned users');
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

  Widget _buildUserCard(UserModel user, ThemeData theme) {
    final isSelected = _selectedUserIds.contains(user.id);
    final isAssigned = _assignedUserIds.contains(user.id);
    
    final roleIcons = {
      'ADMIN': Icons.admin_panel_settings,
      'TOP MANAGEMENT': Icons.business_center,
      'PROJECT MANAGER': Icons.manage_accounts,
      'PROJECT COORDINATOR': Icons.event,
      'HEALTH PRACTITIONER': Icons.medical_services,
      'CLIENT': Icons.person,
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedUserIds.remove(user.id);
          } else {
            _selectedUserIds.add(user.id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.15)
              : theme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.primaryColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedUserIds.add(user.id);
                  } else {
                    _selectedUserIds.remove(user.id);
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            
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
                  // Show assigned/unassigned status instead of verified/not verified
                  Row(
                    children: [
                      Icon(
                        isAssigned
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isAssigned ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAssigned ? 'Assigned' : 'Not Assigned',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isAssigned ? Colors.green : Colors.grey,
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
          ],
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
      appBar: KenwellAppBar(
        title: 'Allocate Event',
        titleColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF201C58),
        centerTitle: true,
      ),
      // Body of the screen
      body: Consumer<UserManagementViewModel>(
        builder: (context, viewModel, _) {
          final filteredUsers = viewModel.filteredUsers;
          final totalUsers = viewModel.users.length;
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

          return Column(
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
                          Icons.event,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              filterActive
                                  ? 'Showing ${filteredUsers.length} of $totalUsers users'
                                  : '$totalUsers users available • ${_selectedUserIds.length} selected',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
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
                    UserSearchBar(
                      controller: _searchController,
                      searchQuery: viewModel.searchQuery,
                      onChanged: (value) => viewModel.setSearchQuery(value),
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
              const SizedBox(height: 16),
              // User list
              Expanded(
                child: filteredUsers.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(user, theme);
                        },
                      ),
              ),
              // Assign button
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedUserIds.isNotEmpty
                          ? () async {
                              final selectedUsers = filteredUsers
                                  .where((u) => _selectedUserIds.contains(u.id))
                                  .toList();
                              
                              // Show loading indicator
                              if (!mounted) return;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              // Assign event to selected users
                              for (final user in selectedUsers) {
                                await UserEventService.addUserEvent(
                                  event: widget.event,
                                  user: user,
                                );
                              }
                              
                              if (!context.mounted) return;
                              
                              // Close loading dialog
                              Navigator.of(context).pop();
                              
                              // Refresh assigned users list
                              await _fetchAssignedUsers();
                              
                              // Clear selection
                              setState(() {
                                _selectedUserIds.clear();
                              });
                              
                              // Show success message
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Event assigned to ${selectedUsers.length} user(s)',
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                              
                              widget.onAllocate(selectedUsers.map((u) => u.id).toList());
                              
                              // Pop back to event details screen with success result
                              if (!context.mounted) return;
                              context.pop(true);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _selectedUserIds.isEmpty
                            ? 'Select Users to Assign'
                            : 'Assign to ${_selectedUserIds.length} User(s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
