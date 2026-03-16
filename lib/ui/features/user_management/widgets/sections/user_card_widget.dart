import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../../../domain/models/user_model.dart';
import '../../../../shared/ui/badges/number_badge.dart';

// ── Role-specific styling helpers ────────────────────────────────────────────

_RoleStyle _roleStyle(String role) {
  switch (role.toUpperCase()) {
    case 'ADMIN':
      return const _RoleStyle(
        icon: Icons.admin_panel_settings_rounded,
        accentColor: Color(0xFF7C3AED),
      );
    case 'TOP MANAGEMENT':
      return const _RoleStyle(
        icon: Icons.business_center_rounded,
        accentColor: Color(0xFF1D4ED8),
      );
    case 'PROJECT MANAGER':
      return const _RoleStyle(
        icon: Icons.manage_accounts_rounded,
        accentColor: Color(0xFF0891B2),
      );
    case 'PROJECT COORDINATOR':
      return const _RoleStyle(
        icon: Icons.event_rounded,
        accentColor: Color(0xFF059669),
      );
    case 'HEALTH PRACTITIONER':
    case 'NURSE':
      return const _RoleStyle(
        icon: Icons.medical_services_rounded,
        accentColor: Color(0xFFD97706),
      );
    case 'CLIENT':
      return const _RoleStyle(
        icon: Icons.person_rounded,
        accentColor: KenwellColors.primaryGreen,
      );
    default:
      return const _RoleStyle(
        icon: Icons.person_outline_rounded,
        accentColor: Color(0xFF6B7280),
      );
  }
}

class _RoleStyle {
  const _RoleStyle({
    required this.icon,
    required this.accentColor,
  });
  final IconData icon;
  final Color accentColor;
}

// ─────────────────────────────────────────────────────────────────────────────

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
    final rs = _roleStyle(user.role);

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
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
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
                  if (number != null) ...[
                    NumberBadge(number: number!),
                    const SizedBox(width: 10),
                  ],

                  // Gradient avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          KenwellColors.primaryGreen.withOpacity(0.15),
                          KenwellColors.primaryGreenDark.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // rs.gradient,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: const [
                        BoxShadow(
                          color: KenwellColors.primaryGreen,

                          //rs.accentColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(rs.icon, color: Colors.white, size: 22),
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
                            Icon(Icons.email_outlined,
                                size: 11, color: Colors.grey.shade400),
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Verification badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: user.emailVerified
                                    ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.12)
                                    : const Color(0xFFEF4444)
                                        .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(6),
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
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    user.emailVerified
                                        ? 'Verified'
                                        : 'Unverified',
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
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Role badge
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              rs.accentColor.withValues(alpha: 0.18),
                              rs.accentColor.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: rs.accentColor.withValues(alpha: 0.30),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            color: rs.accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade300,
                        size: 18,
                      ),
                    ],
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
