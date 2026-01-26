import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';
import '../view_model/calendar_view_model.dart';
import 'event_list_dialog.dart';

class DayEventsDialog extends StatelessWidget {
  final DateTime selectedDay;
  final List<WellnessEvent> events;
  final CalendarViewModel viewModel;
  final Function(DateTime, {WellnessEvent? existingEvent}) onOpenEventForm;

  const DayEventsDialog({
    super.key,
    required this.selectedDay,
    required this.events,
    required this.viewModel,
    required this.onOpenEventForm,
  });

  @override
  Widget build(BuildContext context) {
    final dayEvents = [...events]..sort(viewModel.compareEvents);

    return AlertDialog(
      title: Text(viewModel.formatDateMedium(selectedDay)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dayEvents.isEmpty) const Text('No events scheduled for this day'),
          if (dayEvents.isNotEmpty)
            Text('${dayEvents.length} event(s) scheduled'),
        ],
      ),
      actions: [
        if (dayEvents.isNotEmpty)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show list of events in a new dialog
              showDialog(
                context: context,
                builder: (ctx) => EventListDialog(
                  selectedDay: selectedDay,
                  dayEvents: dayEvents,
                  viewModel: viewModel,
                  onOpenEventForm: onOpenEventForm,
                ),
              );
            },
            child: const Text('View Events'),
          ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onOpenEventForm(selectedDay);
          },
          child: const Text('Create Event'),
        ),
      ],
    );
  }
}
