import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/constants/role_permissions.dart';
import '../../event/view_model/event_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/calendar_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/routing/app_routes.dart';

// Widget representing a single event card in the calendar
class EventCard extends StatelessWidget {
  final WellnessEvent event;
  final CalendarViewModel viewModel;

  /// When true, adds the same navy border used on the calendar widget.
  final bool showBorder;

  // Constructor
  const EventCard({
    super.key,
    required this.event,
    required this.viewModel,
    this.showBorder = false,
  });

  // Build method to render the event card
  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final canDelete =
        RolePermissions.canAccessFeature(profileVM.role, 'delete_event');

    final cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            AppRoutes.eventDetails,
            extra: {'event': event},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: showBorder
                ? Border.all(
                    color: KenwellColors.secondaryNavy.withValues(alpha: 0.08),
                    width: 2.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          // ClipRRect ensures the left accent bar respects rounded corners
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left green accent bar
                  Container(
                    width: 5,
                    color: KenwellColors.primaryGreen,
                  ),
                  // Main card body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: _buildCardContent(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Event'),
            content: const Text('Are you sure you want to delete this event?'),
            // Actions for confirming or canceling the deletion
            actionsAlignment: MainAxisAlignment.end,
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              // Delete button
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      // Background shown when swiping to delete
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
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
          AppSnackbar.showSuccess(
            context,
            'Event deleted successfully',
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await eventViewModel.addEvent(event);
                viewModel.loadEvents();
              },
            ),
          );
        }
      },
      // Event card content
      child: cardContent,
    );
  }

  // Build the modernised card content
  Widget _buildCardContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: icon badge + organization label + title + address ──────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar icon badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: KenwellColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.event_rounded,
                color: KenwellColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Organization label, title and address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eyebrow label
                  Text(
                    'CLIENT ORGANIZATION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: KenwellColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Event title
                  Text(
                    event.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: KenwellColors.secondaryNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: KenwellColors.neutralGrey,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          event.address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: KenwellColors.neutralGrey,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Divider(
            height: 1, thickness: 1, color: KenwellColors.neutralDivider),
        const SizedBox(height: 10),

        // ── Meta chips: date, time, and optional participation ─────────────────
        Row(
          children: [
            Expanded(
              child: _EventMetaChip(
                icon: Icons.calendar_today_outlined,
                label: viewModel.formatDateShort(event.date),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _EventMetaChip(
                icon: Icons.access_time_rounded,
                label: event.endTime.isNotEmpty
                    ? '${event.startTime} – ${event.endTime}'
                    : event.startTime,
              ),
            ),
            if (event.expectedParticipation > 0) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _EventMetaChip(
                  icon: Icons.people_outline_rounded,
                  label: '${event.expectedParticipation} participants',
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),
        const Divider(
            height: 1, thickness: 1, color: KenwellColors.neutralDivider),

        // ── Tap affordance ─────────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tap for more details',
                style: TextStyle(
                  fontSize: 11,
                  color: KenwellColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: KenwellColors.primaryGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Small pill chip used in the meta row ──────────────────────────────────────
class _EventMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EventMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: KenwellColors.neutralBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: KenwellColors.neutralDivider,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: KenwellColors.secondaryNavy),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: KenwellColors.secondaryNavy,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
