import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
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
    Widget detailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15)),
          ],
        ),
      );
    }

      return Scaffold(
        appBar: KenwellAppBar(
          title: event.title,
          automaticallyImplyLeading: true,
          backgroundColor: const Color(0xFF201C58),
          titleColor: Colors.white,
          centerTitle: false,
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
            const KenwellSectionHeader(
              title: 'Event Summary',
              uppercase: true,
            ),
            _buildSectionCard('Event Details', [
              detailRow('Category', event.servicesRequested),
              detailRow('Date', DateFormat.yMMMMd().format(event.date)),
              detailRow('Set Up Time', event.setUpTime),
              detailRow('Start Time', event.startTime),
              detailRow('End Time', event.endTime),
              detailRow('Strike Down Time', event.strikeDownTime),
            ]),
            _buildSectionCard('Venue & Address', [
              detailRow('Venue', event.venue),
              detailRow('Address', event.address),
            ]),
            _buildSectionCard('Onsite Contact', [
              detailRow('Contact Person', event.onsiteContactPerson),
              detailRow('Contact Number', event.onsiteContactNumber),
              detailRow('Email', event.onsiteContactEmail),
            ]),
            _buildSectionCard('AE Contact', [
              detailRow('Contact Person', event.aeContactPerson),
              detailRow('Contact Number', event.aeContactNumber),
            ]),
            _buildSectionCard('Participation & Options', [
              detailRow('Expected Participation',
                  event.expectedParticipation.toString()),
              detailRow('Non Members', event.nonMembers.toString()),
              detailRow('Passports', event.passports.toString()),
              detailRow('Nurses', event.nurses.toString()),
              detailRow('Coordinators', event.coordinators.toString()),
              detailRow('Multiply Promoters', event.multiplyPromoters.toString()),
              detailRow('Mobile Booths', event.mobileBooths),
              detailRow('Medical Aid Option', event.medicalAid),
              if (event.description != null && event.description!.isNotEmpty)
                detailRow('Description', event.description!),
            ]),
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
