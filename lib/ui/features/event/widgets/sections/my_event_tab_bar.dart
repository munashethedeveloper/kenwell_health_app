import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Segmented tab bar for switching between the "Today" and "Upcoming" event
/// lists on the My Events screen.
///
/// Each tab shows a count badge that updates when the underlying event list
/// changes.  The selected tab is highlighted with the brand navy gradient.
class MyEventTabBar extends StatelessWidget {
  const MyEventTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.todayCount,
    required this.upcomingCount,
  });

  /// 0 = Today tab, 1 = Upcoming tab.
  final int selectedIndex;

  /// Called with the new index when the user taps a tab.
  final ValueChanged<int> onChanged;

  final int todayCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'Today',
              count: todayCount,
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            _TabItem(
              label: 'Upcoming',
              count: upcomingCount,
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single pill inside [MyEventTabBar].
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            // Navy gradient when selected; transparent background when not.
            gradient: isSelected
                ? const LinearGradient(
                    colors: [KenwellColors.secondaryNavy, Color(0xFF3B3F86)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : KenwellColors.secondaryNavy.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 6),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
