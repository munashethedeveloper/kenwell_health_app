import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/calendar_view_model.dart';
import 'event_list_dialog.dart';

/// Bottom sheet to show events for a selected day with options to view or create events
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

  // Build method to create the bottom sheet UI
  @override
  Widget build(BuildContext context) {
    // Sort events by start time
    final dayEvents = [...events]..sort(viewModel.compareEvents);
    final canAdd = _canAddEvent(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Date title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF90C048).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_rounded,
                      color: Color(0xFF90C048), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    viewModel.formatDateMedium(selectedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF201C58),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Event count indicator
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: dayEvents.isEmpty
                    ? Colors.grey.shade50
                    : const Color(0xFF201C58).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    dayEvents.isEmpty
                        ? Icons.event_busy_rounded
                        : Icons.event_available_rounded,
                    color: dayEvents.isEmpty
                        ? Colors.grey.shade400
                        : const Color(0xFF90C048),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    dayEvents.isEmpty
                        ? 'No events scheduled for this day'
                        : '${dayEvents.length} event(s) scheduled',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: dayEvents.isEmpty
                          ? Colors.grey.shade500
                          : const Color(0xFF201C58),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                if (dayEvents.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.pop();
                        // Show list of events in a new bottom sheet
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => EventListDialog(
                            selectedDay: selectedDay,
                            dayEvents: dayEvents,
                            viewModel: viewModel,
                            onOpenEventForm: onOpenEventForm,
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_rounded),
                      label: const Text('View Events'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF201C58),
                        side: const BorderSide(color: Color(0xFF201C58)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (canAdd) const SizedBox(width: 12),
                ],
                if (canAdd)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.pop();
                        onOpenEventForm(selectedDay);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Event'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF90C048),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
