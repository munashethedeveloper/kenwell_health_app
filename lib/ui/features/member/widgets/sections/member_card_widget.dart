import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
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
                    // Toggle the slide menu on tap (open if closed, close if open)
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
                                color:
                                    theme.primaryColor.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              genderIcon,
                              color: theme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Member Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${member.name} ${member.surname}',
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
                                      Icons.badge_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'ID: $idNumber',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 13,
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

                          const SizedBox(width: 12),

                          // Gender badge with modern styling
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Colors.white.withValues(alpha: 0.8),
                                  //const Color(0xFF90C048),
                                  // const Color(0xFF90C048)
                                  //.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF90C048)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              gender,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                //color: Colors.white,
                                //color: Colors.grey[800],
                                color: KenwellColors.secondaryNavyDark,
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
                )));
  }
}
