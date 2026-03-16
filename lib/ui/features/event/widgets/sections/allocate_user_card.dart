import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../../shared/ui/badges/number_badge.dart';
import '../../../../../domain/models/user_model.dart';

/// A slidable user card for the Allocate Event screen.
///
/// Swipe left to reveal an "Assign" or "Unassign" [SlidableAction].
/// Tapping the card body toggles the action pane without needing a swipe,
/// which improves discoverability on devices where swipe gestures are unusual.
class AllocateUserCard extends StatelessWidget {
  const AllocateUserCard({
    super.key,
    required this.user,
    required this.isAssigned,
    required this.onAssign,
    required this.onUnassign,
    this.number,
  });

  final UserModel user;

  /// Whether this user is already assigned to the event.
  final bool isAssigned;

  /// Called when the user taps the "Assign" action.
  final VoidCallback onAssign;

  /// Called when the user taps the "Unassign" action.
  final VoidCallback onUnassign;

  /// Optional ordinal number badge shown at the start of the card.
  final int? number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(user.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (!isAssigned)
            SlidableAction(
              onPressed: (_) => onAssign(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: Icons.person_add_rounded,
              label: 'Assign',
              borderRadius: BorderRadius.circular(12),
            ),
          if (isAssigned)
            SlidableAction(
              onPressed: (_) => onUnassign(),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.person_remove_rounded,
              label: 'Unassign',
              borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
      // Builder gives access to the Slidable controller inside the child.
      child: Builder(
        builder: (context) => GestureDetector(
          // Tap toggles the action pane so users don't need to swipe.
          onTap: () {
            final slidable = Slidable.of(context);
            final isOpen =
                slidable?.actionPaneType.value != ActionPaneType.none;
            isOpen ? slidable?.close() : slidable?.openEndActionPane();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: KenwellColors.secondaryNavyDark.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Optional ordinal badge
                  if (number != null) ...[
                    NumberBadge(number: number!),
                    const SizedBox(width: 10),
                  ],

                  // User info: name, email, assignment status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: KenwellColors.secondaryNavyDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        // Email row
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.email,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: KenwellColors.secondaryNavyDark,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Assigned / Unassigned badge
                        _AssignmentBadge(isAssigned: isAssigned),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small coloured badge showing "Assigned" (green) or "Unassigned" (red).
class _AssignmentBadge extends StatelessWidget {
  const _AssignmentBadge({required this.isAssigned});

  final bool isAssigned;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF10B981);
    const red = Color(0xFFEF4444);
    final color = isAssigned ? green : red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAssigned
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 3),
          Text(
            isAssigned ? 'Assigned' : 'Unassigned',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
