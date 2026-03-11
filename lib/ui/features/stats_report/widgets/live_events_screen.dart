import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import 'event_stats_content.dart';

/// Displays statistics and a breakdown of events that are currently in-progress.
class LiveEventsScreen extends StatelessWidget {
  const LiveEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KenwellAppBar(
        title: 'KenWell365',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => context.pushNamed('help'),
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
