import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';
import '../view_model/event_view_model.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFF201C58),
        iconTheme: const IconThemeData(color: Colors.white),
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
          _buildDetailCard('Category', event.servicesRequested),
          _buildDetailCard('Date', DateFormat.yMMMMd().format(event.date)),
          _buildDetailCard('Set Up Time', event.setUpTime),
          _buildDetailCard('Start Time', event.startTime),
          _buildDetailCard('End Time', event.endTime),
          _buildDetailCard('Strike Down Time', event.strikeDownTime),
          _buildDetailCard('Venue', event.venue),
          _buildDetailCard('Address', event.address),
          _buildDetailCard('Onsite Contact Person', event.onsiteContactPerson),
          _buildDetailCard('Onsite Contact Number', event.onsiteContactNumber),
          _buildDetailCard('Onsite Contact Email', event.onsiteContactEmail),
          _buildDetailCard('AE Contact Person', event.aeContactPerson),
          _buildDetailCard('AE Contact Number', event.aeContactNumber),
          _buildDetailCard(
              'Expected Participation', event.expectedParticipation.toString()),
          _buildDetailCard('Non Members', event.nonMembers.toString()),
          _buildDetailCard('Passports', event.passports.toString()),
          _buildDetailCard('Nurses', event.nurses.toString()),
          _buildDetailCard('Coordinators', event.coordinators.toString()),
          _buildDetailCard(
              'Multiply Promoters', event.multiplyPromoters.toString()),
          _buildDetailCard('Mobile Booths', event.mobileBooths),
          _buildDetailCard('Medical Aid Option', event.medicalAid),
          if (event.description != null && event.description!.isNotEmpty)
            _buildDetailCard('Description', event.description!),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF201C58),
                )),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the event
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text(
            'Are you sure you want to delete this event? You can undo this action.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteEvent(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Navigates to the event form screen for editing
  void _navigateToEditEvent(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/event',
      arguments: {
        'date': event.date,
        'existingEvent': event,
        'onSave': (WellnessEvent updatedEvent) {
          _updateEvent(context, updatedEvent);
        },
      },
    );
  }

  /// Updates the event and shows a Snackbar with undo option
  void _updateEvent(BuildContext context, WellnessEvent updatedEvent) {
    final previousEvent = viewModel?.updateEvent(updatedEvent);

    if (previousEvent != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event updated'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              viewModel?.updateEvent(previousEvent);
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Deletes the event and shows a Snackbar with undo option
  void _deleteEvent(BuildContext context) {
    final deletedEvent = viewModel?.deleteEvent(event.id);

    if (deletedEvent != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              viewModel?.restoreEvent(deletedEvent);
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
