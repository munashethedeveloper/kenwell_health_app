import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../event/view_model/event_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/calendar_view_model.dart';

// Widget representing a single event card in the calendar
class EventCard extends StatelessWidget {
  final WellnessEvent event;
  final CalendarViewModel viewModel;

  // Constructor
  const EventCard({
    super.key,
    required this.event,
    required this.viewModel,
  });

  // Build method to render the event card
  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final canDelete = RolePermissions.canAccessFeature(profileVM.role, 'delete_event');
    
    // Use Dismissible to enable swipe-to-delete functionality (only if user has permission)
    final cardContent = InkWell(
      onTap: () {
        context.pushNamed(
          'eventDetails',
          extra: {'event': event},
        );
      },
      // Card container
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF201C58),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildCardContent(context),
      ),
    );
    
    // Only wrap with Dismissible if user can delete
    if (!canDelete) {
      return cardContent;
    }
    
    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text('Are you sure you want to delete this event?'),
            // Actions for confirming or canceling the deletion
            actions: [
              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              // Delete button
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      // Background shown when swiping to delete
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        final eventViewModel =
            Provider.of<EventViewModel>(context, listen: false);
        await eventViewModel.deleteEvent(event.id);

        // Show snackbar with UNDO option
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text('Event deleted successfully'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async {
                    await eventViewModel.addEvent(event);
                    viewModel.loadEvents();
                  },
                ),
              ),
            );
        }
      },
      // Event card content
      child: cardContent,
    );
  }

  // Build the card content (extracted for reuse)
  Widget _buildCardContent(BuildContext context) {
    return KenwellFormCard(
      child: Row(
        children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: viewModel
                        .getCategoryColor(event.servicesRequested)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Icon representing the event category
                  child: Icon(
                    viewModel.getServiceIcon(event.servicesRequested),
                    size: 28,
                    color: viewModel.getCategoryColor(event.servicesRequested),
                  ),
                ),
                const SizedBox(width: 16),
                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF201C58),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Event time
                      Row(
                        children: [
                          // Time icon
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          // Time text
                          Text(
                            '${event.startTime}${event.endTime.isNotEmpty ? ' - ${event.endTime}' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      // Optional venue/address and expected participation
                      if (event.venue.isNotEmpty ||
                          event.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.address.isNotEmpty
                                    ? event.address
                                    : event.venue,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (event.expectedParticipation > 0) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.people,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${event.expectedParticipation} expected',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
  }
}
