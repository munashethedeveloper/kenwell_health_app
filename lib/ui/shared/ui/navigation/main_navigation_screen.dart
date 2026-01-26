import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/profile/widgets/my_profile_menu_screen.dart';
import 'package:kenwell_health_app/ui/features/user_management/widgets/user_management_screen_version_two.dart';
import 'package:kenwell_health_app/ui/shared/ui/responsive/responsive_breakpoints.dart';

// Feature imports
import '../../../features/calendar/widgets/calendar_screen.dart';
import '../../../features/stats_report/widgets/stats_report_screen.dart';
import '../../../features/event/widgets/my_event_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    final List<Widget> tabs = [
      const UserManagementScreenVersionTwo(),
      const StatsReportScreen(),
      const CalendarScreen(),
      const MyProfileMenuScreen(),
      const MyEventScreen(),
    ];

    // For desktop/tablet, use NavigationRail + content side-by-side
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // NavigationRail for larger screens
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              extended: ResponsiveBreakpoints.isExpanded(context),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              indicatorColor: theme.colorScheme.secondaryContainer,
              labelType: ResponsiveBreakpoints.isExpanded(context)
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Statistics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: Text('Planner'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note),
                  label: Text('Events'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: tabs,
              ),
            ),
          ],
        ),
      );
    }

    // For mobile, use traditional bottom NavigationBar
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),

      // -------------------------------
      //      MATERIAL 3 BOTTOM NAV BAR
      // -------------------------------
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          indicatorColor: theme.colorScheme.secondaryContainer,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                color: theme.colorScheme.onSecondaryContainer,
                size: 26,
              );
            }
            return IconThemeData(
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            );
          }),
          elevation: 3,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Planner',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Events',
            ),
          ],
        ),
      ),
    );
  }
}
