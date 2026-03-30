import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/home/widgets/home_screen.dart';
import 'package:kenwell_health_app/ui/features/user_management/widgets/registration_management_screen.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/responsive/responsive_breakpoints.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

// Feature imports
import '../../../features/stats_report/widgets/stats_report_screen.dart';
import '../../../features/event/widgets/my_event_screen.dart';
import '../../../features/calendar/widgets/calendar_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2;

  // ── Cached tab state ──────────────────────────────────────────────────────
  // Tab widget lists and their navigation destinations are built once per role.
  // They are only recreated when the user's role actually changes (e.g. after
  // logging out and back in with a different account). Keeping the same widget
  // instances across builds ensures IndexedStack can preserve per-tab state
  // without unnecessary re-initialisation — rebuilding all tabs simultaneously
  // on every ProfileViewModel.notifyListeners() was what caused "Skipped 156
  // frames" on first load.
  String? _cachedRole;
  List<Widget> _tabs = const [];
  List<NavigationDestination> _navDestinations = const [];
  List<NavigationRailDestination> _railDestinations = const [];

  static bool _isPrivilegedRole(String role) =>
      role == 'ADMIN' ||
      role == 'TOP MANAGEMENT' ||
      role == 'PROJECT MANAGER';

  /// Rebuilds the cached tab / destination lists for [role].
  ///
  /// Called only when the role changes, so the widgets inside the IndexedStack
  /// remain stable across unrelated ProfileViewModel notifications.
  void _rebuildTabsForRole(String role) {
    _cachedRole = role;
    final bool privileged = _isPrivilegedRole(role);
    final bool isClient = role == 'CLIENT';

    _tabs = privileged
        ? [
            const RegistrationManagementScreen(),
            const StatsReportScreen(),
            // privileged: Users=0, Stats=1, Home=2, Calendar=3, Events=4
            HomeScreen(onTabSwitch: (i) => setState(() => _currentIndex = i)),
            const CalendarScreen(),
            const MyEventScreen(),
          ]
        : isClient
            ? [
                const StatsReportScreen(),
                HomeScreen(
                    onTabSwitch: (i) => setState(() => _currentIndex = i)),
                const CalendarScreen(),
              ]
            : [
                // restricted: Home=0, Calendar=1, Events=2
                HomeScreen(
                    onTabSwitch: (i) => setState(() => _currentIndex = i)),
                const CalendarScreen(),
                const MyEventScreen(),
              ];

    _navDestinations = privileged
        ? const [
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Statistics',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note_rounded),
              label: 'Events',
            ),
          ]
        : isClient
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: 'Statistics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note_rounded),
                  label: 'Events',
                ),
              ];

    _railDestinations = privileged
        ? const [
            NavigationRailDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: Text('Users'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.bar_chart_rounded),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: Text('Statistics'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: Text('Calendar'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note_rounded),
              label: Text('Events'),
            ),
          ]
        : isClient
            ? const [
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: Text('Statistics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Calendar'),
                ),
              ]
            : const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Calendar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note_rounded),
                  label: Text('Events'),
                ),
              ];

    // Clamp selected index when the tab count changes (e.g. role promotion).
    if (_currentIndex >= _tabs.length) {
      _currentIndex = _tabs.length - 1;
    }
  }

  @override
  void initState() {
    super.initState();
    // Eagerly populate the tab lists so they are never in an uninitialised
    // state when build() runs for the first time.  The role is unknown here
    // (ProfileViewModel loads it asynchronously), so we use an empty string
    // which maps to the "restricted" tab set.  build() will call
    // _rebuildTabsForRole again with the real role as soon as the provider
    // delivers it.
    _rebuildTabsForRole('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    // Listen only to role changes — not every name/email update — so this
    // widget only rebuilds when the set of available tabs must change.
    final String role = context
        .select<ProfileViewModel, String>((vm) => vm.role)
        .toUpperCase();

    // Rebuild cached tab/destination lists only when the role changes.
    if (role != _cachedRole) {
      _rebuildTabsForRole(role);
    }

    final int currentIndex = _currentIndex;

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
              destinations: _railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: _tabs,
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
        children: _tabs,
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
          destinations: _navDestinations,
        ),
      ),
    );
  }
}
