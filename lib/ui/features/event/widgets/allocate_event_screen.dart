import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../user_management/viewmodel/user_management_view_model.dart';
import '../../user_management/widgets/sections/user_filter_chips.dart';
import 'package:kenwell_health_app/data/services/user_event_service.dart';
import '../../../../domain/models/wellness_event.dart';

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

  // Initialize state
  @override
  void initState() {
    super.initState();
    // Optionally, trigger user loading if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().loadUsers();
    });
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KenwellAppBar(
        title: 'Allocate Event: ${widget.event.title}',
        titleColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.white,
          //fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF201C58),
        centerTitle: true,
      ),
      // Body of the screen
      body: Consumer<UserManagementViewModel>(
        builder: (context, viewModel, _) {
          final users = viewModel.filteredUsers;
          return Column(
            children: [
              // App logo at the top
              const AppLogo(size: 150),
              const KenwellSectionHeader(
                title: 'Allocate Event to Users',
                subtitle:
                    'Select users from the list below to assign this event to them.',
              ),
              // Always show filter chips
              UserFilterChips(
                selectedFilter: viewModel.selectedFilter,
                onFilterChanged: viewModel.setFilter,
              ),
              // User list with checkboxes
              if (viewModel.isLoading && users.isEmpty)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (users.isEmpty)
                const Expanded(child: Center(child: Text('No users found')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final fullName = '${user.firstName} ${user.lastName}';
                      return CheckboxListTile(
                        title: Text(fullName),
                        subtitle: Text('${user.email} • ${user.role}'),
                        value: _selectedUserIds.contains(user.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedUserIds.add(user.id);
                            } else {
                              _selectedUserIds.remove(user.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                // Assign button
                child: ElevatedButton(
                  onPressed: _selectedUserIds.isNotEmpty
                      ? () async {
                          final selectedUsers = users
                              .where((u) => _selectedUserIds.contains(u.id))
                              .toList();
                          // Assign event to selected users
                          for (final user in selectedUsers) {
                            await UserEventService.addUserEvent(
                              event: widget.event,
                              user: user,
                            );
                          }
                          if (!context.mounted) return;
                          widget.onAllocate(_selectedUserIds.toList());
                          if (!context.mounted) return;
                          Navigator.pop(context,
                              true); // Pass true to indicate assignment
                        }
                      : null,
                  child: const Text('Assign Selected Users'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
