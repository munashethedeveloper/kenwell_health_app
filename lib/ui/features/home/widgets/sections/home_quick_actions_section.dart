import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Quick-action shortcut grid shown on the home screen.
class HomeQuickActionsSection extends StatelessWidget {
  const HomeQuickActionsSection({
    super.key,
    required this.onStartEvent,
    required this.onViewStats,
    required this.onViewMembers,
    required this.onMyEvents,
  });

  final VoidCallback onStartEvent;
  final VoidCallback onViewStats;
  final VoidCallback onViewMembers;
  final VoidCallback onMyEvents;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.play_circle_rounded,
        label: 'Start Event',
        color: KenwellColors.primaryGreen,
        onTap: onStartEvent,
      ),
      _QuickAction(
        icon: Icons.bar_chart_rounded,
        label: 'Statistics',
        color: const Color(0xFF3B82F6),
        onTap: onViewStats,
      ),
      _QuickAction(
        icon: Icons.people_rounded,
        label: 'Members',
        color: const Color(0xFF8B5CF6),
        onTap: onViewMembers,
      ),
      _QuickAction(
        icon: Icons.event_note_rounded,
        label: 'My Events',
        color: const Color(0xFFF59E0B),
        onTap: onMyEvents,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KenwellColors.secondaryNavy,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: actions
                .map((a) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _QuickActionCard(action: a),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: action.color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: KenwellColors.secondaryNavy,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
