import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../user_management/viewmodel/user_management_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../../shared/ui/cards/kenwell_detail_row.dart';
import '../../../shared/ui/cards/kenwell_section_card.dart';
import '../view_model/event_view_model.dart';
import 'allocate_event_screen.dart';
import 'my_event_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

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
    final profileVM = context.watch<ProfileViewModel>();
    final canEdit =
        RolePermissions.canAccessFeature(profileVM.role, 'edit_event');
    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_event');

    String fullName(String first, String last) => '$first $last';

    String eventTitle = event.title.toLowerCase();
    String eventTitleCapitalized = eventTitle.isNotEmpty
        ? '${eventTitle[0].toUpperCase()}${eventTitle.substring(1)}'
        : '';

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
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: 'Help',
            onPressed: () => context.pushNamed('help'),
          ),
        ],
      ),
      // Body of the screen
      body: Column(
        children: [
          // ── Gradient section header ─────────────────────────────
          KenwellGradientHeader(
            //   label: 'EVENT DETAILS',
            title: '$eventTitleCapitalized\nEvent Details',
            subtitle: 'Detailed information about the $eventTitle event',
          ),
          // ── Scrollable content ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /*  Container(
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
                      /*    Expanded(
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
                      ), */
                    ],
                  ),
                ),
                const SizedBox(height: 20), */
                // Event detail sections
                KenwellSectionCard(
                  title: 'Client Organization',
                  Icons.business_rounded,
                  [
                    KenwellDetailRow(label: 'Event Title', value: event.title),
                  ],
                ),
                KenwellSectionCard(
                  title: 'Date & Time',
                  Icons.schedule_rounded,
                  [
                    KenwellDetailRow(label: 'Date', value: DateFormat.yMMMMd().format(event.date)),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Set Up Time', value: event.setUpTime),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Start Time', value: event.startTime),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'End Time', value: event.endTime),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Strike Down Time', value: event.strikeDownTime),
                  ],
                ),
                KenwellSectionCard(
                  title: 'Event Location',
                  Icons.location_on_rounded,
                  [
                    KenwellDetailRow(label: 'Venue', value: event.venue),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Address', value: event.address),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Town/City', value: event.townCity),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Province', value: event.province),
                  ],
                ),
                KenwellSectionCard(
                  title: 'Onsite Contact',
                  Icons.person_pin_rounded,
                  [
                    KenwellDetailRow(label: 'Contact Person', value: fullName(event.onsiteContactFirstName, event.onsiteContactLastName)),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Contact Number', value: event.onsiteContactNumber),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Email', value: event.onsiteContactEmail),
                  ],
                ),
                KenwellSectionCard(
                  title: 'AE Contact',
                  Icons.support_agent_rounded,
                  [
                    KenwellDetailRow(label: 'Contact Person', value: fullName(event.aeContactFirstName, event.aeContactLastName)),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Contact Number', value: event.aeContactNumber),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Email', value: event.aeContactEmail),
                  ],
                ),
                KenwellSectionCard(
                  title: 'Participation & Options',
                  Icons.people_rounded,
                  [
                    KenwellDetailRow(label: 'Expected Participation', value: event.expectedParticipation.toString()),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Nurses', value: event.nurses.toString()),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Mobile Booths', value: event.mobileBooths),
                    const Divider(height: 1),
                    KenwellDetailRow(label: 'Medical Aid Option', value: event.medicalAid),
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const Divider(height: 1),
                      KenwellDetailRow(label: 'Description', value: event.description!),
                    ],
                  ],
                ),
                KenwellSectionCard(
                  title: 'Requested Services',
                  Icons.medical_services_rounded,
                  [
                    KenwellDetailRow(label: 'Services', value: event.servicesRequested.isNotEmpty
                          ? event.servicesRequested
                          : 'None'),
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
                          color: KenwellColors.primaryGreen
                              .withValues(alpha: 0.25),
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
                                    AppSnackbar.showSuccess(context,
                                        'Assigned to \${assignedUserIds.length} user(s)');
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
          ),
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
    AppSnackbar.showSuccess(context, 'Event deleted');
  }

  // Build a detail row widget

}
