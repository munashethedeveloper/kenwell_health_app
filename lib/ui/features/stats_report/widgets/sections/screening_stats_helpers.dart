import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

// ── Data classes shared by all four screening-stats cards ────────────────────

class HraStats {
  const HraStats({
    required this.total,
    required this.underweight,
    required this.normal,
    required this.overweight,
    required this.obese,
    required this.hypertension,
    required this.highBloodSugar,
    required this.highCholesterol,
    required this.smokers,
    required this.topConditions,
  });

  final int total;
  final int underweight, normal, overweight, obese;
  final int hypertension, highBloodSugar, highCholesterol, smokers;
  final List<MapEntry<String, int>> topConditions;
}

class CancerStats {
  const CancerStats({
    required this.total,
    required this.papCollected,
    required this.papPositive,
    required this.psaDone,
    required this.psaAbnormal,
    required this.symptomatic,
    required this.referred,
  });

  final int total;
  final int papCollected, papPositive, psaDone, psaAbnormal;
  final int symptomatic, referred;
}

class TbStats {
  const TbStats({
    required this.total,
    required this.symptomatic,
    required this.cough,
    required this.bloodInSputum,
    required this.weightLoss,
    required this.nightSweats,
    required this.treatedBefore,
    required this.contactWithTB,
    required this.referred,
  });

  final int total;
  final int symptomatic, cough, bloodInSputum, weightLoss, nightSweats;
  final int treatedBefore, contactWithTB, referred;
}

class HctStats {
  const HctStats({
    required this.total,
    required this.firstTimeTesters,
    required this.highRisk,
    required this.knownPositive,
  });

  final int total;
  final int firstTimeTesters, highRisk, knownPositive;
}

// ── Shared UI helpers ─────────────────────────────────────────────────────────

/// Denominator helper: returns [subset] when non-zero, else [total].
/// Used so rates for sub-groups are expressed as a fraction of the tested
/// sub-group rather than the overall cohort.
int screeningDen(int subset, int total) => subset > 0 ? subset : total;

String screeningPct(int count, int total) =>
    total > 0 ? '${(count / total * 100).toStringAsFixed(1)}%' : 'N/A';

/// Standard row: icon · label · count · % · progress bar
Widget buildStatRow(
  IconData icon,
  String label,
  int count,
  int total,
  Color color,
  ThemeData theme,
) {
  const purple = Color(0xFF6A1B9A);
  final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
  final pctString = screeningPct(count, total);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: KenwellColors.secondaryNavyDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              count.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: KenwellColors.secondaryNavy,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($pctString)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 4,
            backgroundColor: purple.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              purple.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Small pill stat used for BMI distribution.
Widget buildPillStat(
    String label, int count, Color color, ThemeData theme) {
  const purple = Color(0xFF6A1B9A);
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: KenwellColors.secondaryNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

/// Bullet row for chronic conditions list.
Widget buildConditionRow(
    String condition, int count, int total, ThemeData theme) {
  const purple = Color(0xFF6A1B9A);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(condition, style: theme.textTheme.bodyMedium),
        ),
        Text(
          '$count (${screeningPct(count, total)})',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: KenwellColors.secondaryNavy,
          ),
        ),
      ],
    ),
  );
}

/// Sub-section label used inside cards (e.g. "BMI Distribution").
Widget buildScreeningSectionLabel(String label, ThemeData theme) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6A1B9A),
          ),
        ),
      ),
    );

/// Small "no data" placeholder shown inside a card when no records exist.
Widget buildNoDataWidget(ThemeData theme) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'No records for this event',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );

/// Full empty-state used when no screenings at all were found.
Widget buildScreeningEmptyState(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.insert_chart_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No health screening data recorded yet',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
