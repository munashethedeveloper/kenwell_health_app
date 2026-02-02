import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/profile/widgets/my_profile_menu_screen.dart';
import 'package:kenwell_health_app/ui/features/user_management/widgets/user_management_screen_version_two.dart';
import 'package:kenwell_health_app/ui/shared/ui/responsive/responsive_breakpoints.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

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
  int _lastTabCount = 0;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final profileVM = context.watch<ProfileViewModel>();
    final String role = profileVM.role.toUpperCase();

    bool isPrivilegedRole(String role) {
      return role == 'ADMIN' ||
          role == 'TOP MANAGEMENT' ||
          role == 'PROJECT MANAGER' ||
          role == 'COORDINATOR';
    }

    // Define tabs and destinations based on role
    final List<Widget> allTabs = [
      const UserManagementScreenVersionTwo(),
      const StatsReportScreen(),
      const CalendarScreen(),
      const MyProfileMenuScreen(),
      const MyEventScreen(),
    ];
    final List<Widget> clientTabs = [
      const StatsReportScreen(),
      const MyProfileMenuScreen(),
    ];
    final List<Widget> restrictedTabs = [
      const CalendarScreen(),
      const MyProfileMenuScreen(),
      const MyEventScreen(),
    ];
    final List<NavigationRailDestination> allRailDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: Text('Users'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: Text('Statistics'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: Text('Planner'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Profile'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note),
        label: Text('Events'),
      ),
    ];
    final List<NavigationRailDestination> clientRailDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: Text('Statistics'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Profile'),
      ),
    ];
    final List<NavigationRailDestination> restrictedRailDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: Text('Planner'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Profile'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note),
        label: Text('Events'),
      ),
    ];
    final List<NavigationDestination> allNavDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: 'Users',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: 'Statistics',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: 'Planner',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      const NavigationDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note),
        label: 'Events',
      ),
    ];
    final List<NavigationDestination> clientNavDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: 'Statistics',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
    final List<NavigationDestination> restrictedNavDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: 'Planner',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      const NavigationDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note),
        label: 'Events',
      ),
    ];

    final bool privileged = isPrivilegedRole(role);
    final bool isClient = role == 'CLIENT';
    final List<Widget> tabs = privileged
        ? allTabs
        : isClient
            ? clientTabs
            : restrictedTabs;
    final List<NavigationRailDestination> railDestinations = privileged
        ? allRailDestinations
        : isClient
            ? clientRailDestinations
            : restrictedRailDestinations;
    final List<NavigationDestination> navDestinations = privileged
        ? allNavDestinations
        : isClient
            ? clientNavDestinations
            : restrictedNavDestinations;

    // Adjust _currentIndex if needed (fixes out-of-range errors on role change)
    if (_lastTabCount != tabs.length) {
      if (_currentIndex >= tabs.length) {
        setState(() {
          _currentIndex = tabs.length - 1;
        });
      }
      _lastTabCount = tabs.length;
    }
    int currentIndex = _currentIndex;

    // For desktop/tablet, use NavigationRail + content side-by-side
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
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
              destinations: railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
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
        index: currentIndex,
        children: tabs,
      ),
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
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: navDestinations,
        ),
      ),
    );
  }
}
