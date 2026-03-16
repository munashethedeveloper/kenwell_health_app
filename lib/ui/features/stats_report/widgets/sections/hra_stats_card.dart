import 'package:flutter/material.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import 'screening_stats_helpers.dart';

/// Displays HRA (Health Risk Assessment) aggregate statistics inside a
/// [KenwellFormCard].
class HraStatsCard extends StatelessWidget {
  const HraStatsCard({super.key, required this.stats});

  final HraStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = stats;
    return KenwellFormCard(
      title: 'HRA — Health Risk Assessment  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? buildNoDataWidget(theme)
          : Column(
              children: [
                buildScreeningSectionLabel('BMI Distribution', theme),
                const SizedBox(height: 8),
                Row(
                  children: [
                    buildPillStat(
                        'Underweight', s.underweight, Colors.blue, theme),
                    buildPillStat('Normal', s.normal, Colors.green, theme),
                    buildPillStat(
                        'Overweight', s.overweight, Colors.orange, theme),
                    buildPillStat('Obese', s.obese, Colors.red, theme),
                  ],
                ),
                const Divider(height: 24),
                buildStatRow(Icons.favorite, 'Hypertension', s.hypertension,
                    s.total, Colors.red, theme),
                const Divider(),
                buildStatRow(Icons.bloodtype, 'Elevated Blood Sugar',
                    s.highBloodSugar, s.total, Colors.orange, theme),
                const Divider(),
                buildStatRow(Icons.monitor_heart, 'High Cholesterol',
                    s.highCholesterol, s.total, Colors.deepOrange, theme),
                const Divider(),
                buildStatRow(Icons.smoking_rooms, 'Smokers', s.smokers, s.total,
                    Colors.brown, theme),
                if (s.topConditions.isNotEmpty) ...[
                  const Divider(height: 24),
                  buildScreeningSectionLabel('Top Chronic Conditions', theme),
                  const SizedBox(height: 8),
                  ...s.topConditions.map(
                      (e) => buildConditionRow(e.key, e.value, s.total, theme)),
                ],
              ],
            ),
    );
  }
}
