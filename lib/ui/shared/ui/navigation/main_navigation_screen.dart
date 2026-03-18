import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/home/widgets/home_screen.dart';
import 'package:kenwell_health_app/ui/features/profile/widgets/my_profile_menu_screen.dart';
import 'package:kenwell_health_app/ui/features/user_management/widgets/registration_management_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/responsive/responsive_breakpoints.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

// Feature imports
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
          role == 'PROJECT MANAGER';
    }

    /*   bool isStaffRole(String role) {
      return role == 'ADMIN' ||
          role == 'TOP MANAGEMENT' ||
          role == 'PROJECT MANAGER' ||
          role == 'PROJECT COORDINATOR' ||
          role == 'HEALTH PRACTITIONER';
    } */

    // Define tabs and destinations based on role
    final List<Widget> allTabs = [
      //const UserManagementScreenVersionTwo(),
      const RegistrationManagementScreen(),
      const StatsReportScreen(),
      // privileged: Users=0, Stats=1, Home=2, Profile=3, Events=4
      HomeScreen(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      const MyProfileMenuScreen(),
      const MyEventScreen(),
    ];
    final List<Widget> clientTabs = [
      const StatsReportScreen(),
      //client should also be able to see the calendar but without the events displaying
      HomeScreen(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      const MyProfileMenuScreen(),
    ];
    final List<Widget> restrictedTabs = [
      // restricted: Home=0, Profile=1, Events=2
      HomeScreen(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      const MyProfileMenuScreen(),
      const MyEventScreen(),
    ];
    final List<NavigationRailDestination> allRailDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.people_outline_rounded),
        selectedIcon: Icon(Icons.people_rounded),
        label: Text('Users'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart_rounded),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: Text('Statistics'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: Text('Home'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('Profile'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note_rounded),
        label: Text('Events'),
      ),
    ];
    final List<NavigationRailDestination> clientRailDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart_rounded),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: Text('Statistics'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: Text('Home'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('Profile'),
      ),
    ];
    final List<NavigationRailDestination> restrictedRailDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: Text('Home'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('Profile'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note_rounded),
        label: Text('Events'),
      ),
    ];
    final List<NavigationDestination> allNavDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.people_outline_rounded),
        selectedIcon: Icon(Icons.people_rounded),
        label: 'Users',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_rounded),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: 'Statistics',
      ),
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
      const NavigationDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note_rounded),
        label: 'Events',
      ),
    ];
    final List<NavigationDestination> clientNavDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_rounded),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: 'Statistics',
      ),
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];
    final List<NavigationDestination> restrictedNavDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
      const NavigationDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note_rounded),
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
              indicatorColor: KenwellColors.primaryGreen,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selectedIconTheme: const IconThemeData(
                color: Colors.white,
                size: 26,
              ),
              unselectedIconTheme: const IconThemeData(
                color: KenwellColors.primaryGreen,
                size: 24,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: KenwellColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
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
          //indicatorColor: theme.colorScheme.secondaryContainer,
          indicatorColor: KenwellColors.primaryGreen,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                //color: theme.colorScheme.onSurface,
                color: KenwellColors.primaryGreen,
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
              return const IconThemeData(
                //color: theme.colorScheme.onSecondaryContainer,
                //color: KenwellColors.primaryGreen,
                color: Colors.white,
                size: 26,
              );
            }
            return const IconThemeData(
              //color: theme.colorScheme.onSurfaceVariant,
              color: KenwellColors.primaryGreen,
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
