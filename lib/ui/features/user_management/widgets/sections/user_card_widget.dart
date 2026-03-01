import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../domain/models/user_model.dart';
import '../../../../shared/ui/badges/number_badge.dart';

/// Displays a user card with swipe actions for reset password and delete
class UserCardWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;
  final int? number;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.onTap,
    required this.onResetPassword,
    required this.onDelete,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final roleIcons = {
      'ADMIN': Icons.admin_panel_settings_rounded,
      'TOPMANAGEMENT': Icons.business_center_rounded,
      'PROJECTMANAGER': Icons.manage_accounts_rounded,
      'COORDINATOR': Icons.event_rounded,
      'NURSE': Icons.medical_services_rounded,
      'CLIENT': Icons.person_rounded,
    };

    return Slidable(
      key: ValueKey(user.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onResetPassword(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.lock_reset_rounded,
            label: 'Reset',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            final slidable = Slidable.of(context);
            final isOpen =
                slidable?.actionPaneType.value != ActionPaneType.none;
            if (isOpen) {
              slidable?.close();
            } else {
              slidable?.openEndActionPane();
            }
          },
          onLongPress: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.12),
                width: 1,
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
                  if (number != null) ...[
                    NumberBadge(number: number!),
                    const SizedBox(width: 10),
                  ],

                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      roleIcons[user.role] ?? Icons.person_rounded,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF201C58),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
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
                                  color: const Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.emailVerified
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(0xFFEF4444)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user.emailVerified
                                    ? Icons.verified_rounded
                                    : Icons.error_outline_rounded,
                                color: user.emailVerified
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                user.emailVerified ? 'Verified' : 'Not Verified',
                                style: TextStyle(
                                  color: user.emailVerified
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Role badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
