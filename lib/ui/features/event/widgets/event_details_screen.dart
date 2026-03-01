import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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
        title: 'KenWell365',
        titleColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
        actions: [
          if (viewModel != null && canEdit)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              tooltip: 'Edit Event',
              onPressed: () => _navigateToEditEvent(context),
            ),
          if (viewModel != null && canDelete)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
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
          // Event title header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF201C58),
                  const Color(0xFF201C58).withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF201C58).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMMd().format(event.date),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Event detail sections
          _buildSectionCard(
            'Client Organization',
            Icons.business_rounded,
            [
              _buildDetailRow('Event Title', event.title, theme),
            ],
          ),
          _buildSectionCard(
            'Date & Time',
            Icons.schedule_rounded,
            [
              _buildDetailRow(
                  'Date', DateFormat.yMMMMd().format(event.date), theme),
              const Divider(height: 1),
              _buildDetailRow('Set Up Time', event.setUpTime, theme),
              const Divider(height: 1),
              _buildDetailRow('Start Time', event.startTime, theme),
              const Divider(height: 1),
              _buildDetailRow('End Time', event.endTime, theme),
              const Divider(height: 1),
              _buildDetailRow('Strike Down Time', event.strikeDownTime, theme),
            ],
          ),
          _buildSectionCard(
            'Event Location',
            Icons.location_on_rounded,
            [
              _buildDetailRow('Venue', event.venue, theme),
              const Divider(height: 1),
              _buildDetailRow('Address', event.address, theme),
              const Divider(height: 1),
              _buildDetailRow('Town/City', event.townCity, theme),
              const Divider(height: 1),
              _buildDetailRow('Province', event.province, theme),
            ],
          ),
          _buildSectionCard(
            'Onsite Contact',
            Icons.person_pin_rounded,
            [
              _buildDetailRow(
                  'Contact Person',
                  fullName(event.onsiteContactFirstName,
                      event.onsiteContactLastName),
                  theme),
              const Divider(height: 1),
              _buildDetailRow(
                  'Contact Number', event.onsiteContactNumber, theme),
              const Divider(height: 1),
              _buildDetailRow('Email', event.onsiteContactEmail, theme),
            ],
          ),
          _buildSectionCard(
            'AE Contact',
            Icons.support_agent_rounded,
            [
              _buildDetailRow(
                  'Contact Person',
                  fullName(event.aeContactFirstName, event.aeContactLastName),
                  theme),
              const Divider(height: 1),
              _buildDetailRow('Contact Number', event.aeContactNumber, theme),
              const Divider(height: 1),
              _buildDetailRow('Email', event.aeContactEmail, theme),
            ],
          ),
          _buildSectionCard(
            'Participation & Options',
            Icons.people_rounded,
            [
              _buildDetailRow('Expected Participation',
                  event.expectedParticipation.toString(), theme),
              const Divider(height: 1),
              _buildDetailRow('Nurses', event.nurses.toString(), theme),
              const Divider(height: 1),
              _buildDetailRow('Mobile Booths', event.mobileBooths, theme),
              const Divider(height: 1),
              _buildDetailRow('Medical Aid Option', event.medicalAid, theme),
              if (event.description != null &&
                  event.description!.isNotEmpty) ...[
                const Divider(height: 1),
                _buildDetailRow('Description', event.description!, theme),
              ],
            ],
          ),
          _buildSectionCard(
            'Requested Services',
            Icons.medical_services_rounded,
            [
              _buildDetailRow(
                'Services',
                event.servicesRequested.isNotEmpty
                    ? event.servicesRequested
                    : 'None',
                theme,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Allocate Event button (with permission check)
          if (RolePermissions.canAccessFeature(
              profileVM.role, 'allocate_events'))
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: KenwellColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
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
                                      'Assigned to ${assignedUserIds.length} user(s)'),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  );
                  if (context.mounted &&
                      result != null &&
                      result is bool &&
                      result) {
                    final myEventScreenState = MyEventScreen.of(context);
                    myEventScreenState?.refreshUserEvents();
                  }
                },
                icon: const Icon(Icons.people_alt_rounded, size: 20),
                label: const Text(
                  'Allocate Event',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KenwellColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_rounded,
                    color: Colors.red, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Delete Event'),
            ],
          ),
          content: const Text(
              'Are you sure you want to delete this event? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteEvent(context);
              },
              child: const Text('Delete'),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF201C58),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a section card widget with an icon
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF201C58).withValues(alpha: 0.08),
          width: 1,
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
          // Section header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201C58).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF201C58), size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF201C58),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFF201C58).withValues(alpha: 0.06),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
