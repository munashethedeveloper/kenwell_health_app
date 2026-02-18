import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../../shared/utils/event_status_colors.dart';
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
    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_event');
    final theme = Theme.of(context);

    // Event Breakdown Card design
    final cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'eventDetails',
            extra: {'event': event},
          );
        },
        borderRadius: BorderRadius.circular(12),
        // Event Breakdown Card container
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: _buildCardContent(context),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);

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
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade400,
              Colors.red.shade600,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);

    return Row(
      children: [
        // Icon badge with Event Breakdown Card styling
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            viewModel.getServiceIcon(event.servicesRequested),
            color: theme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Event details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event title with primary color
              Text(
                event.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Date and status row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    viewModel.formatDateShort(event.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: EventStatusColors.getStatusColor(event.status)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: EventStatusColors.getStatusColor(event.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Event time with icon
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${event.startTime}${event.endTime.isNotEmpty ? ' - ${event.endTime}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Optional venue/address
              if (event.venue.isNotEmpty || event.address.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.address.isNotEmpty
                            ? event.address
                            : event.venue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
              // Expected participation
              if (event.expectedParticipation > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${event.expectedParticipation} expected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Chevron icon
        Icon(
          Icons.chevron_right,
          color: theme.primaryColor,
        ),
      ],
    );
  }
}
