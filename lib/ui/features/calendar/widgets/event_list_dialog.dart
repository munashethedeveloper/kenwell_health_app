import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/calendar_view_model.dart';

/// Bottom sheet to display list of events for a selected day
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
    final profileVM = context.watch<ProfileViewModel>();
    final canEdit =
        RolePermissions.canAccessFeature(profileVM.role, 'edit_event');
    final canCreate =
        RolePermissions.canAccessFeature(profileVM.role, 'create_event');

    // Build the bottom sheet
    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
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
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF90C048).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_note_rounded,
                            color: Color(0xFF90C048), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.formatDateLong(selectedDay),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF201C58),
                              ),
                            ),
                            Text(
                              '${dayEvents.length} event(s)',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Events list
                Flexible(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: dayEvents.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      // Build each event item
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        // Icon based on event category
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: viewModel
                                .getCategoryColor(event.servicesRequested)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            viewModel.getServiceIcon(event.servicesRequested),
                            color: viewModel
                                .getCategoryColor(event.servicesRequested),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF201C58),
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          viewModel.getEventSubtitle(event),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        trailing: canEdit
                            ? const Icon(Icons.edit_outlined,
                                color: Color(0xFF90C048), size: 20)
                            : const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF6B7280), size: 20),
                        onTap: canEdit
                            ? () {
                                context.pop();
                                onOpenEventForm(selectedDay,
                                    existingEvent: event);
                              }
                            : null,
                      );
                    },
                  ),
                ),
                // Action buttons
                if (canCreate)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          context.pop();
                          onOpenEventForm(selectedDay);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Event'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF90C048),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
