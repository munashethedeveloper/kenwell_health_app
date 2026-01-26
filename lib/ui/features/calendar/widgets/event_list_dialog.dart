import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';
import '../view_model/calendar_view_model.dart';

class EventListDialog extends StatelessWidget {
  final DateTime selectedDay;
  final List<WellnessEvent> dayEvents;
  final CalendarViewModel viewModel;
  final Function(DateTime, {WellnessEvent? existingEvent}) onOpenEventForm;

  const EventListDialog({
    super.key,
    required this.selectedDay,
    required this.dayEvents,
    required this.viewModel,
    required this.onOpenEventForm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Events on ${viewModel.formatDateLong(selectedDay)}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: dayEvents.length,
          itemBuilder: (context, index) {
            final event = dayEvents[index];
            return ListTile(
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
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
