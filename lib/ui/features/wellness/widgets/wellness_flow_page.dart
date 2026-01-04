import 'package:flutter/material.dart';
import 'package:kenwell_health_app/routing/route_names.dart';
import 'package:provider/provider.dart';

import '../../../../data/services/firebase_auth_service.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/wellness_flow_view_model.dart';
import 'wellness_flow_screen.dart';
import '../../auth/widgets/login_screen.dart';

class WellnessFlowPage extends StatefulWidget {
  final WellnessEvent event;
  final Future<void> Function()? onFlowCompleted;
  final Future<void> Function()? onExitEarly;

  const WellnessFlowPage({
    super.key,
    required this.event,
    this.onFlowCompleted,
    this.onExitEarly,
  });

  @override
  State<WellnessFlowPage> createState() => _WellnessFlowPageState();
}

class _WellnessFlowPageState extends State<WellnessFlowPage> {
  Future<void> _logout() async {
    await FirebaseAuthService().logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleExit(BuildContext context) async {
    if (widget.onExitEarly != null) {
      await widget.onExitEarly!();
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _handleCompletion(BuildContext context) async {
    if (widget.onFlowCompleted != null) {
      await widget.onFlowCompleted!();
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KenwellAppBar(
        title: 'Event Name: ${widget.event.title}',
        backgroundColor: const Color(0xFF201C58),
        titleColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          // 🔹 Popup menu
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 0: // Profile
                  if (mounted) {
                    Navigator.pushNamed(context, RouteNames.profile);
                  }
                  break;
                case 1: // Help
                  if (mounted) {
                    Navigator.pushNamed(context, RouteNames.help);
                  }
                  break;
                case 2: // Logout
                  await _logout();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.black),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.black),
                  title: Text('Help'),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),

          // 🔹 Existing close button (kept)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => _handleExit(context),
          ),
        ],
      ),
      body: ChangeNotifierProvider<WellnessFlowViewModel>(
        create: (_) => WellnessFlowViewModel(activeEvent: widget.event),
        child: WellnessFlowScreen(
          event: widget.event,
          onExitFlow: () => _handleExit(context),
          onFlowCompleted: () => _handleCompletion(context),
        ),
      ),
    );
  }
}
