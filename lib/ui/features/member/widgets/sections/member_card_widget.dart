import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../domain/models/member.dart';

/// Widget to display member information as a card
/// Styled to match the user_card_widget look and feel
class MemberCardWidget extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDelete;

  const MemberCardWidget({
    super.key,
    required this.member,
    required this.onTap,
    required this.onViewDetails,
    required this.onDelete,
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
                icon: Icons.visibility,
                label: 'View Member Details',
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                icon: Icons.delete,
                label: 'Delete Member',
              ),
          ],
        ),
        child: Builder(
            builder: (context) => GestureDetector(
                  onTap: () {
                    //Open the slide menu on tap
                    final slidable = Slidable.of(context);
                    slidable?.openEndActionPane();
                  },
                  onLongPress: onTap,
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
                              Text(
                                'ID: $idNumber',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Gender badge (right side, replacing role badge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                )));
  }
}
