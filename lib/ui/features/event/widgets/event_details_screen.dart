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
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Delete Event',
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _detailRow('Category', event.servicesRequested),
            _detailRow('Date', DateFormat.yMMMMd().format(event.date)),
            _detailRow('Set Up Time', event.setUpTime),
            _detailRow('Start Time', event.startTime),
            _detailRow('End Time', event.endTime),
            _detailRow('Strike Down Time', event.strikeDownTime),
            _detailRow('Venue', event.venue),
            _detailRow('Address', event.address),
            _detailRow('Onsite Contact Person', event.onsiteContactPerson),
            _detailRow('Onsite Contact Number', event.onsiteContactNumber),
            _detailRow('Onsite Contact Email', event.onsiteContactEmail),
            _detailRow('AE Contact Person', event.aeContactPerson),
            _detailRow('AE Contact Number', event.aeContactNumber),
            _detailRow('Expected Participation',
                event.expectedParticipation.toString()),
            _detailRow('Non Members', event.nonMembers.toString()),
            _detailRow('Passports', event.passports.toString()),
            _detailRow('Nurses', event.nurses.toString()),
            _detailRow('Coordinators', event.coordinators.toString()),
            _detailRow(
                'Multiply Promoters', event.multiplyPromoters.toString()),
            _detailRow('Mobile Booths', event.mobileBooths),
            _detailRow('Medical Aid Option', event.medicalAid),
            if (event.description != null && event.description!.isNotEmpty)
              _detailRow('Description', event.description!),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF201C58),
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
          const Divider(),
        ],
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

  /// Deletes the event and shows a Snackbar with undo option
  void _deleteEvent(BuildContext context) {
    final deletedEvent = viewModel?.deleteEvent(event.id);

    if (deletedEvent != null) {
      // Navigate back after deletion
      Navigator.of(context).pop();

      // Show Snackbar with undo option
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
