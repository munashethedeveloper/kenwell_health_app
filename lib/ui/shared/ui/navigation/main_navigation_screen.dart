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

  // ── Cached per-role tab data ───────────────────────────────────────────────
  // Rebuilt only when the user's role changes so the IndexedStack never
  // discards live screen states due to role-unrelated ProfileViewModel updates.
  String _cachedRole = '';
  List<Widget> _tabs = const [];
  List<NavigationRailDestination> _railDestinations = const [];
  List<NavigationDestination> _navDestinations = const [];

  @override
  void initState() {
    super.initState();
    _rebuildTabsForRole('');
  }

  void _rebuildTabsForRole(String role) {
    final upperRole = role.toUpperCase();

    bool isPrivilegedRole(String r) =>
        r == 'ADMIN' || r == 'TOP MANAGEMENT' || r == 'PROJECT MANAGER';

    final List<Widget> allTabs = [
      const RegistrationManagementScreen(),
      const StatsReportScreen(),
      // privileged: Users=0, Stats=1, Home=2, Calendar=3, Events=4
      HomeScreen(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      const CalendarScreen(),
      const MyEventScreen(),
    ];
    final List<Widget> clientTabs = [
      const StatsReportScreen(),
      HomeScreen(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      const CalendarScreen(),
    ];
    final List<Widget> restrictedTabs = [
      // restricted: Home=0, Calendar=1, Events=2
      HomeScreen(onTabSwitch: (i) => setState(() => _currentIndex = i)),
      const CalendarScreen(),
      const MyEventScreen(),
    ];

    if (isPrivilegedRole(upperRole)) {
      _tabs = allTabs;
      _railDestinations = const [
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
      ];
      _navDestinations = const [
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
      ];
    } else if (upperRole == 'CLIENT') {
      _tabs = clientTabs;
      _railDestinations = const [
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
      ];
      _navDestinations = const [
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
      ];
    } else {
      _tabs = restrictedTabs;
      _railDestinations = const [
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
      _navDestinations = const [
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    // Subscribe only to role changes to avoid rebuilding on unrelated
    // ProfileViewModel updates (e.g. firstName/lastName changes).
    final String role =
        context.select<ProfileViewModel, String>((vm) => vm.role);

    // Rebuild cached tab data only when the role changes.  This is a direct
    // mutation inside build (no setState) — safe because it is idempotent and
    // does not schedule an additional frame.
    if (role != _cachedRole) {
      _cachedRole = role;
      _rebuildTabsForRole(role);
      // Clamp the current index in-place so the IndexedStack never receives
      // an out-of-range index.  A postFrameCallback is used so that we do not
      // call setState() while Flutter is executing buildScope(), which would
      // throw "setState() called during build".
      if (_currentIndex >= _tabs.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _currentIndex = _tabs.length - 1);
        });
      }
    }

    final int currentIndex =
        _currentIndex.clamp(0, _tabs.length - 1);

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
