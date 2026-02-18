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
  final int? number; // Optional numbering for the card

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

    final firstName = user.firstName;
    final lastName = user.lastName;
    final email = user.email;
    final role = user.role;

    final roleIcons = {
      'ADMIN': Icons.admin_panel_settings,
      'TOPMANAGEMENT': Icons.business_center,
      'PROJECTMANAGER': Icons.manage_accounts,
      'COORDINATOR': Icons.event,
      'NURSE': Icons.medical_services,
      //'DATA CAPTURER': Icons.data_usage,
      'CLIENT': Icons.person,
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
            icon: Icons.lock_reset,
            label: 'Reset Password',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete User',
          ),
        ],
      ),
      child: Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            // Toggle the slide menu on tap (open if closed, close if open)
            final slidable = Slidable.of(context);
            final isOpen = slidable?.actionPaneType.value != ActionPaneType.none;
            if (isOpen) {
              slidable?.close();
            } else {
              slidable?.openEndActionPane();
            }
          },
          onLongPress: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  theme.primaryColor.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Number badge (if provided)
                  if (number != null) ...[
                    NumberBadge(number: number!),
                    const SizedBox(width: 12),
                  ],

                  // Modern avatar with icon and gradient background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor.withValues(alpha: 0.2),
                          theme.primaryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      roleIcons[role] ?? Icons.person,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF201C58),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                email,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: user.emailVerified
                                    ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.1)
                                    : const Color(0xFFEF4444)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: user.emailVerified
                                      ? const Color(0xFF10B981)
                                          .withValues(alpha: 0.3)
                                      : const Color(0xFFEF4444)
                                          .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    user.emailVerified
                                        ? Icons.verified
                                        : Icons.error_outline,
                                    color: user.emailVerified
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.emailVerified
                                        ? 'Verified'
                                        : 'Not Verified',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: user.emailVerified
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Role badge with modern styling
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF90C048),
                          const Color(0xFF90C048).withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF90C048).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      role,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: theme.primaryColor,
                      size: 20,
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
