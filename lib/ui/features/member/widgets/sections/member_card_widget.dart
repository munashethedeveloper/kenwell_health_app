import 'package:flutter/material.dart';
import '../../../../../domain/models/member.dart';
import '../../../../shared/ui/badges/number_badge.dart';

/// Widget to display member information as a card
/// Styled to match the user_card_widget look and feel
class MemberCardWidget extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final int? number; // Optional numbering for the card

  const MemberCardWidget({
    super.key,
    required this.member,
    required this.onTap,
    this.onDelete,
    this.number,
  });

  // Static constants to avoid recreating on each build
  static const Map<String, IconData> _genderIcons = {
    'Male': Icons.male,
    'Female': Icons.female,
  };
  
  static const String _defaultGenderLabel = 'Unknown';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final gender = member.gender ?? _defaultGenderLabel;
    final genderIcon = _genderIcons[gender] ?? Icons.person;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Number badge (if provided)
            if (number != null) ...[
              NumberBadge(number: number!),
              const SizedBox(width: 12),
            ],
            
            // Gender icon (left side)
            Icon(
              genderIcon,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),

            // Member Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${member.name} ${member.surname}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Gender badge (right side, replacing role badge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                gender,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
