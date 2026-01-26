import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/buttons/custom_secondary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../view_model/event_view_model.dart';
import 'allocate_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final WellnessEvent event;
  final EventViewModel? viewModel;

  const EventDetailsScreen({
    super.key,
    required this.event,
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String fullName(String first, String last) => '$first $last';

    return Scaffold(
      appBar: KenwellAppBar(
        title: 'Event Details',
        titleColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.white,
          //fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF201C58),
        centerTitle: true,
        actions: [
          if (viewModel != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Event',
              onPressed: () => _navigateToEditEvent(context),
            ),
          if (viewModel != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Delete Event',
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          const AppLogo(size: 200),
          const SizedBox(height: 24),
          const KenwellSectionHeader(
            title: 'Event Summary Details',
            uppercase: true,
          ),
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
          const SizedBox(height: 24),
          CustomPrimaryButton(
            label: 'Allocate Event',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllocateEventScreen(
                    onAllocate: (assignedUserIds) {
                      // TODO: Handle assignment logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Assigned to: ' + assignedUserIds.join(', ')),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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

  void _navigateToEditEvent(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/event',
      arguments: {
        'date': event.date,
        'existingEvent': event,
      },
    );
  }

  Future<void> _deleteEvent(BuildContext context) async {
    if (viewModel == null) return;
    await viewModel!.deleteEvent(event.id); // implement deleteEvent in VM
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted')),
    );
  }

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
