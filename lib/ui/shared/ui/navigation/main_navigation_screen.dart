import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/profile/widgets/profile_screen.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/features/user_management/widgets/user_management_screen_version_two.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

// Feature imports
import '../../../features/calendar/widgets/calendar_screen.dart';
import '../../../features/stats_report/widgets/stats_report_screen.dart';
import '../../../features/event/view_model/event_view_model.dart';
import '../../../features/event/widgets/conduct_event_screen.dart';

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
    // Load profile data when the main navigation screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const UserManagementScreenVersionTwo(),
      const StatsReportScreen(),
      const CalendarScreen(),
      const ProfileScreen(),
      const ConductEventScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),

      // -------------------------------
      //      FLOATING TOOLBAR
      // -------------------------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: KenwellColors.neutralWhite,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                return const TextStyle(color: KenwellColors.secondaryNavy);
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                return const IconThemeData(color: KenwellColors.secondaryNavy);
              }),
            ),
            child: NavigationBar(
              height: 65,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: KenwellColors.primaryGreen,
              elevation: 6,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'User Management',
                ),

                NavigationDestination(
                  icon: Icon(Icons.bar_chart),
                  label: 'Statistics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today),
                  label: 'Planner',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                // NavigationDestination(
                // icon: Icon(Icons.settings),
                // label: 'Settings',
                // ),

                //NavigationDestination(
                //  icon: Icon(Icons.help),
                //  label: 'Help',
                // ),
                NavigationDestination(
                  icon: Icon(Icons.event),
                  label: 'Conduct Event',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
