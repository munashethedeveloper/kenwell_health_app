import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';
import '../view_model/calendar_view_model.dart';

/// Dialog to display list of events for a selected day
class EventListDialog extends StatelessWidget {
  // Selected day to show events for
  final DateTime selectedDay;
  final List<WellnessEvent> dayEvents;
  final CalendarViewModel viewModel;
  final Function(DateTime, {WellnessEvent? existingEvent}) onOpenEventForm;

  /// Constructor
  const EventListDialog({
    super.key,
    required this.selectedDay,
    required this.dayEvents,
    required this.viewModel,
    required this.onOpenEventForm,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    // Build the dialog
    return AlertDialog(
      title: Text('Events on ${viewModel.formatDateLong(selectedDay)}'),
      content: SizedBox(
        width: double.maxFinite,
        // List of events for the selected day
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: dayEvents.length,
          itemBuilder: (context, index) {
            final event = dayEvents[index];
            // Build each event item
            return ListTile(
              // Icon based on event category
              leading: CircleAvatar(
                backgroundColor:
                    viewModel.getCategoryColor(event.servicesRequested),
                child: Icon(
                  viewModel.getServiceIcon(event.servicesRequested),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(event.title),
              subtitle: Text(viewModel.getEventSubtitle(event)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () {
                Navigator.pop(context);
                onOpenEventForm(selectedDay, existingEvent: event);
              },
            );
          },
        ),
      ),
      // Dialog actions
      actions: [
        // Close button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        // Add Event button
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onOpenEventForm(selectedDay);
          },
          child: const Text('Add Event'),
        ),
      ],
    );
  }
}
