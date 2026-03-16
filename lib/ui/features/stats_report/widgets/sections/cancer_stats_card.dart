import 'package:flutter/material.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import 'screening_stats_helpers.dart';

/// Displays Cancer Screening aggregate statistics inside a [KenwellFormCard].
class CancerStatsCard extends StatelessWidget {
  const CancerStatsCard({super.key, required this.stats});

  final CancerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = stats;
    return KenwellFormCard(
      title: 'Cancer Screening  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? buildNoDataWidget(theme)
          : Column(
              children: [
                buildStatRow(Icons.science, 'PAP Smear Collected',
                    s.papCollected, s.total, Colors.purple, theme),
                const Divider(),
                buildStatRow(
                    Icons.warning_amber,
                    'PAP Smear Positive',
                    s.papPositive,
                    screeningDen(s.papCollected, s.total),
                    Colors.deepPurple,
                    theme),
                const Divider(),
                buildStatRow(Icons.biotech, 'PSA Test Done', s.psaDone, s.total,
                    Colors.indigo, theme),
                const Divider(),
                buildStatRow(Icons.error_outline, 'PSA Abnormal', s.psaAbnormal,
                    screeningDen(s.psaDone, s.total), Colors.red, theme),
                const Divider(),
                buildStatRow(Icons.report_problem_outlined, 'Symptomatic',
                    s.symptomatic, s.total, Colors.orange, theme),
                const Divider(),
                buildStatRow(Icons.local_hospital, 'Referred', s.referred,
                    s.total, Colors.teal, theme),
              ],
            ),
    );
  }
}
