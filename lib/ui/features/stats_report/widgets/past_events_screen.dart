import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../../../shared/ui/snackbars/app_snackbar.dart';
import '../../event/view_model/event_view_model.dart';
import 'event_stats_content.dart';

/// Displays statistics and a breakdown of events that have been completed.
class PastEventsScreen extends StatelessWidget {
  const PastEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KenwellAppBar(
        title: 'KenWell365',
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
            onPressed: () => context.pushNamed('help'),
            icon: const Icon(Icons.help_outline, color: Colors.white),
            label: const Text('Help', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: const Column(
        children: [
          // ── Gradient section header ─────────────────────────────
          KenwellGradientHeader(
            label: 'PAST EVENTS',
            title: 'Past Event\nStatistics',
            subtitle: 'Outcomes from completed wellness events.',
          ),
          // ── Stats content ───────────────────────────────────────
          Expanded(child: EventStatsContent(isLiveTab: false)),
        ],
      ),
    );
  }
}
