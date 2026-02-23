import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/buttons/custom_secondary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_modern_section_header.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../user_management/viewmodel/user_management_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/event_view_model.dart';
import 'allocate_event_screen.dart';
import 'my_event_screen.dart';

// EventDetailsScreen displays detailed information about a wellness event
class EventDetailsScreen extends StatelessWidget {
  // Event to display
  final WellnessEvent event;
  final EventViewModel? viewModel;

  // Constructor
  const EventDetailsScreen({
    super.key,
    required this.event,
    this.viewModel,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileVM = context.watch<ProfileViewModel>();
    final canEdit =
        RolePermissions.canAccessFeature(profileVM.role, 'edit_event');
    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_event');

    String fullName(String first, String last) => '$first $last';

    return Scaffold(
      // App bar with title and actions
      appBar: KenwellAppBar(
        title: '${event.title} Details',
        titleColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.white,
          //fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        //backgroundColor: const Color(0xFF201C58),
        centerTitle: true,
        // Action buttons for edit and delete (with permission checks) - FIX THIS!!!!!!
        actions: [
          if (viewModel != null && canEdit)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Event',
              onPressed: () => _navigateToEditEvent(context),
            ),
          if (viewModel != null && canDelete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Delete Event',
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      // Body of the screen
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          const AppLogo(size: 150),
          const SizedBox(height: 24),
          // Section header
          KenwellModernSectionHeader(
            title: 'Event Summary Details',
            subtitle: 'Detailed information about the ${event.title} event.',
            uppercase: true,
            icon: Icons.event_note,
          ),
          const SizedBox(height: 24),
          // Event detail sections
          _buildSectionCard('Client Organization', [
            _buildDetailRow('Event Title', event.title, theme),
          ]),
          _buildSectionCard('Date & Time', [
            _buildDetailRow(
                'Date', DateFormat.yMMMMd().format(event.date), theme),
            const Divider(),
            _buildDetailRow('Set Up Time', event.setUpTime, theme),
            const Divider(),
            _buildDetailRow('Start Time', event.startTime, theme),
            const Divider(),
            _buildDetailRow('End Time', event.endTime, theme),
            const Divider(),
            _buildDetailRow('Strike Down Time', event.strikeDownTime, theme),
          ]),
          _buildSectionCard('Event Location', [
            _buildDetailRow('Venue', event.venue, theme),
            const Divider(),
            _buildDetailRow('Address', event.address, theme),
            const Divider(),
            _buildDetailRow('Town/City', event.townCity, theme),
            const Divider(),
            _buildDetailRow('Province', event.province, theme),
          ]),
          _buildSectionCard('Onsite Contact', [
            _buildDetailRow(
                'Contact Person',
                fullName(
                    event.onsiteContactFirstName, event.onsiteContactLastName),
                theme),
            const Divider(),
            _buildDetailRow('Contact Number', event.onsiteContactNumber, theme),
            const Divider(),
            _buildDetailRow('Email', event.onsiteContactEmail, theme),
          ]),
          _buildSectionCard('AE Contact', [
            _buildDetailRow(
                'Contact Person',
                fullName(event.aeContactFirstName, event.aeContactLastName),
                theme),
            const Divider(),
            _buildDetailRow('Contact Number', event.aeContactNumber, theme),
            const Divider(),
            _buildDetailRow('Email', event.aeContactEmail, theme),
          ]),
          _buildSectionCard('Participation & Options', [
            _buildDetailRow('Expected Participation',
                event.expectedParticipation.toString(), theme),
            const Divider(),
            _buildDetailRow('Nurses', event.nurses.toString(), theme),
            const Divider(),
            _buildDetailRow(
                'Coordinators', event.coordinators.toString(), theme),
            const Divider(),
            _buildDetailRow('Mobile Booths', event.mobileBooths, theme),
            const Divider(),
            _buildDetailRow('Medical Aid Option', event.medicalAid, theme),
            if (event.description != null && event.description!.isNotEmpty) ...[
              const Divider(),
              _buildDetailRow('Description', event.description!, theme),
            ],
          ]),
          _buildSectionCard('Requested Services', [
            _buildDetailRow(
              'Services',
              event.servicesRequested.isNotEmpty
                  ? event.servicesRequested
                  : 'None',
              theme,
            ),
            if (event.additionalServicesRequested.isNotEmpty) ...[
              const Divider(),
              _buildDetailRow(
                'Additional Services',
                event.additionalServicesRequested,
                theme,
              ),
            ],
          ]),
          const SizedBox(height: 24),
          // Allocate Event button (with permission check)
          if (RolePermissions.canAccessFeature(
              profileVM.role, 'allocate_events'))
            CustomPrimaryButton(
              label: 'Allocate Event',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => UserManagementViewModel(),
                      child: AllocateEventScreen(
                        event: event,
                        onAllocate: (assignedUserIds) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Assigned to: ${assignedUserIds.join(', ')}'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
                // After returning from allocation, trigger refresh in MyEventScreen if allocation occurred
                if (context.mounted &&
                    result != null &&
                    result is bool &&
                    result) {
                  final myEventScreenState = MyEventScreen.of(context);
                  myEventScreenState?.refreshUserEvents();
                }
              },
            ),
        ],
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
              'Are you sure you want to delete this event? You can undo this action.'),
          actions: [
            CustomSecondaryButton(
              label: 'Cancel',
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            CustomPrimaryButton(
              label: 'Delete',
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteEvent(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Navigate to edit event screen
  void _navigateToEditEvent(BuildContext context) {
    context.pushNamed(
      'addEditEvent',
      extra: {
        'date': event.date,
        'existingEvent': event,
      },
    );
  }

  // Delete event method
  Future<void> _deleteEvent(BuildContext context) async {
    if (viewModel == null) return;
    await viewModel!.deleteEvent(event.id); // implement deleteEvent in VM
    if (!context.mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted')),
    );
  }

  // Build a detail row widget
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Build a section card widget
  Widget _buildSectionCard(String title, List<Widget> children) {
    return KenwellFormCard(
      title: title,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
