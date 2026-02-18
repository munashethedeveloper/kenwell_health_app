import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_event');
    final theme = Theme.of(context);

    // Modern card with elegant shadow and animation
    final cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'eventDetails',
            extra: {'event': event},
          );
        },
        borderRadius: BorderRadius.circular(16),
        // Modern card container with shadow
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade400,
              Colors.red.shade600,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
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
    final categoryColor = viewModel.getCategoryColor(event.servicesRequested);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Enhanced icon container with gradient
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColor.withValues(alpha: 0.2),
                  categoryColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            // Icon representing the event category
            child: Icon(
              viewModel.getServiceIcon(event.servicesRequested),
              size: 32,
              color: categoryColor,
            ),
          ),
          const SizedBox(width: 16),
          // Event details with enhanced typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event title with better typography
                Text(
                  event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Event time with icon
                _buildInfoRow(
                  context,
                  icon: Icons.schedule_rounded,
                  text:
                      '${event.startTime}${event.endTime.isNotEmpty ? ' - ${event.endTime}' : ''}',
                  color: categoryColor,
                ),
                // Optional venue/address
                if (event.venue.isNotEmpty || event.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on_rounded,
                    text:
                        event.address.isNotEmpty ? event.address : event.venue,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
                // Expected participation
                if (event.expectedParticipation > 0) ...[
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    context,
                    icon: Icons.people_rounded,
                    text: '${event.expectedParticipation} expected',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
          // Chevron with subtle styling
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            size: 28,
          ),
        ],
      ),
    );
  }

  // Helper to build info rows with icons
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
