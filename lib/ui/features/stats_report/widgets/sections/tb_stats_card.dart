import 'package:flutter/material.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import 'screening_stats_helpers.dart';

/// Displays TB Screening aggregate statistics inside a [KenwellFormCard].
class TbStatsCard extends StatelessWidget {
  const TbStatsCard({super.key, required this.stats});

  final TbStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = stats;
    return KenwellFormCard(
      title: 'TB Screening  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? buildNoDataWidget(theme)
          : Column(
              children: [
                buildStatRow(Icons.coronavirus, 'Symptomatic (≥1 symptom)',
                    s.symptomatic, s.total, Colors.red, theme),
                const Divider(height: 24),
                buildScreeningSectionLabel('Symptom Breakdown', theme),
                const SizedBox(height: 8),
                buildStatRow(Icons.air, 'Cough ≥2 weeks', s.cough, s.total,
                    Colors.orange, theme),
                const Divider(),
                buildStatRow(Icons.water_drop, 'Blood in Sputum',
                    s.bloodInSputum, s.total, Colors.red, theme),
                const Divider(),
                buildStatRow(Icons.trending_down, 'Unexplained Weight Loss',
                    s.weightLoss, s.total, Colors.deepOrange, theme),
                const Divider(),
                buildStatRow(Icons.nightlight, 'Night Sweats', s.nightSweats,
                    s.total, Colors.purple, theme),
                const Divider(height: 24),
                buildStatRow(Icons.history, 'Previous TB Treatment',
                    s.treatedBefore, s.total, Colors.blue, theme),
                const Divider(),
                buildStatRow(Icons.people_alt, 'Known TB Contact',
                    s.contactWithTB, s.total, Colors.teal, theme),
                const Divider(),
                buildStatRow(Icons.local_hospital, 'Referred', s.referred,
                    s.total, Colors.green, theme),
              ],
            ),
    );
  }
}
