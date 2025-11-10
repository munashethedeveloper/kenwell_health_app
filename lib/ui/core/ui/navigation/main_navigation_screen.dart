import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Feature imports
import '../../../features/calendar/widgets/calendar_screen.dart';
import '../../../features/profile/widgets/profile_screen.dart';
import '../../../features/settings/widgets/settings_screen.dart';
import '../../../features/stats_report/widgets/stats_report_screen.dart';
import '../../../features/help/widgets/help_screen.dart';
import '../../../features/wellness/widgets/wellness_flow_screen.dart';
import '../../../features/wellness/view_model/wellness_flow_view_model.dart';
import '../../../features/event/view_model/event_view_model.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final eventVM = Provider.of<EventViewModel>(context);

    final List<Widget> tabs = [
      CalendarScreen(eventVM: eventVM),
      const ProfileScreen(),
      const SettingsScreen(),
      const StatsReportScreen(),
      const HelpScreen(),
      // Conduct Event Tab
      _buildConductEventTab(),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF90C048),
        selectedItemColor: const Color(0xFF201C58),
        unselectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Conduct Event',
          ),
        ],
      ),
    );
  }

  Widget _buildConductEventTab() {
    // Wrap WellnessFlowScreen with its ViewModel
    return ChangeNotifierProvider(
      create: (_) => WellnessFlowViewModel(),
      child: Consumer<WellnessFlowViewModel>(
        builder: (context, flowVM, _) {
          return WellnessFlowScreen(
            // Use ViewModel’s currentStep for internal step tracking
            viewModel: flowVM,
            onNext: flowVM.nextStep,
            onPrevious: flowVM.previousStep,
            onCancel: flowVM.cancelFlow,
          );
        },
      ),
    );
  }
}
