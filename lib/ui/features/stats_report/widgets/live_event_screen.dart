import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../../../shared/ui/snackbars/app_snackbar.dart';
import '../../event/view_model/event_view_model.dart';
import 'event_stats_content.dart';
import 'package:kenwell_health_app/routing/app_routes.dart';

/// Displays statistics and a breakdown of events that are currently in-progress.
class LiveEventsScreen extends StatelessWidget {
  const LiveEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KenwellAppBar(
        title: 'KenWell365',
        backgroundColor: KenwellColors.primaryGreenDark,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<EventViewModel>().loadEvents();
              AppSnackbar.showSuccess(context, 'Statistics refreshed',
                  duration: const Duration(seconds: 1));
            },
          ),
          TextButton.icon(
            onPressed: () => context.pushNamed(AppRoutes.help),
            icon: const Icon(Icons.help_outline, color: Colors.white),
            label: const Text('Help', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: const Column(
        children: [
          // ── Gradient section header ─────────────────────────────
          KenwellGradientHeader(
            label: 'LIVE EVENTS',
            title: 'Live\nStatistics',
            subtitle: 'Real-time stats for in-progress events.',
          ),
          // ── Stats content ───────────────────────────────────────
          Expanded(child: EventStatsContent(isLiveTab: true)),
        ],
      ),
    );
  }
}
