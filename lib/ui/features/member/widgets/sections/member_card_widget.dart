import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../domain/models/member.dart';
import '../../../../shared/ui/badges/number_badge.dart';

/// Widget to display member information as a card
/// Styled to match the user_card_widget look and feel
class MemberCardWidget extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDelete;
  final int? number;

  const MemberCardWidget({
    super.key,
    required this.member,
    required this.onTap,
    required this.onViewDetails,
    required this.onDelete,
    this.number,
  });

  static const Map<String, IconData> _genderIcons = {
    'Male': Icons.male_rounded,
    'Female': Icons.female_rounded,
  };

  static const String _defaultGenderLabel = 'Unknown';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final gender = member.gender ?? _defaultGenderLabel;
    final genderIcon = _genderIcons[gender] ?? Icons.person_rounded;
    final idNumber = member.idNumber ?? member.passportNumber;

    return Slidable(
      key: ValueKey(member.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onViewDetails != null)
            SlidableAction(
              onPressed: (_) => onViewDetails!(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: Icons.visibility_rounded,
              label: 'View',
              borderRadius: onDelete != null
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    )
                  : BorderRadius.circular(12),
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: onViewDetails != null
                  ? const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                  : BorderRadius.circular(12),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      genderIcon,
                      color: theme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Member info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.name} ${member.surname}',
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
                              Icons.badge_outlined,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'ID: $idNumber',
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
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Gender badge
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
                      gender,
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
