import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/calendar_view_model.dart';
import 'event_list_dialog.dart';

/// Dialog to show events for a selected day with options to view or create events
class DayEventsDialog extends StatelessWidget {
  // The selected day to show events for
  final DateTime selectedDay;
  final List<WellnessEvent> events;
  final CalendarViewModel viewModel;
  final Function(DateTime, {WellnessEvent? existingEvent}) onOpenEventForm;

  // Constructor
  const DayEventsDialog({
    super.key,
    required this.selectedDay,
    required this.events,
    required this.viewModel,
    required this.onOpenEventForm,
  });

  // Helper to check if user can add events using RolePermissions
  bool _canAddEvent(BuildContext context) {
    final profileVM = context.read<ProfileViewModel>();
    return RolePermissions.canAccessFeature(profileVM.role, 'create_event');
  }

  // Build method to create the dialog UI
  @override
  Widget build(BuildContext context) {
    // Sort events by start time
    final dayEvents = [...events]..sort(viewModel.compareEvents);

    // Return the AlertDialog widget
    return AlertDialog(
      title: Text(viewModel.formatDateMedium(selectedDay)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        // Show message based on whether there are events or not
        children: [
          if (dayEvents.isEmpty) const Text('No events scheduled for this day'),
          if (dayEvents.isNotEmpty)
            Text('${dayEvents.length} event(s) scheduled'),
        ],
      ),
      // Actions for viewing or creating events
      actions: [
        if (dayEvents.isNotEmpty)
          // Button to view the list of events
          TextButton(
            onPressed: () {
              context.pop();
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
        // Only show Create Event button for privileged roles
        if (_canAddEvent(context))
          FilledButton(
            onPressed: () {
              context.pop();
              onOpenEventForm(selectedDay);
            },
            child: const Text('Create Event'),
          ),
      ],
    );
  }
}
