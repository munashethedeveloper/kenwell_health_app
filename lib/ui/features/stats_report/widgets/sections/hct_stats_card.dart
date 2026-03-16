import 'package:flutter/material.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import 'screening_stats_helpers.dart';

/// Displays HCT (HIV Counselling & Testing) aggregate statistics inside a
/// [KenwellFormCard].
class HctStatsCard extends StatelessWidget {
  const HctStatsCard({super.key, required this.stats});

  final HctStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = stats;
    return KenwellFormCard(
      title: 'HCT — HIV Counselling & Testing  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? buildNoDataWidget(theme)
          : Column(
              children: [
                buildStatRow(Icons.person_add_alt_1, 'First-Time Testers',
                    s.firstTimeTesters, s.total, Colors.blue, theme),
                const Divider(),
                buildStatRow(Icons.warning, 'High-Risk Individuals', s.highRisk,
                    s.total, Colors.orange, theme),
                const Divider(),
                buildStatRow(Icons.medical_information, 'Known Positive History',
                    s.knownPositive, s.total, Colors.red, theme),
              ],
            ),
    );
  }
}
