import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hra_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_tb_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hiv_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/domain/models/hiv_screening.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_modern_section_header.dart';

/// Displays health-screening-specific statistics for HRA, Cancer, TB and HCT.
///
/// When [eventIds] is provided the stats are scoped to those events.
/// When [eventIds] is null the stats are aggregated across ALL records in the
/// respective Firestore collections.
/// When [eventIds] is an empty list no data is fetched and the section shows
/// an empty-state message.
class HealthScreeningStatsSection extends StatefulWidget {
  /// The wellness event IDs to scope stats to, or null for an aggregate view.
  final List<String>? eventIds;

  /// Optional subtitle override for the section header.
  final String? sectionSubtitle;

  const HealthScreeningStatsSection({
    super.key,
    this.eventIds,
    this.sectionSubtitle,
  });

  @override
  State<HealthScreeningStatsSection> createState() =>
      _HealthScreeningStatsSectionState();
}

class _HealthScreeningStatsSectionState
    extends State<HealthScreeningStatsSection> {
  final _hraRepo = FirestoreHraRepository();
  final _cancerRepo = FirestoreCancerScreeningRepository();
  final _tbRepo = FirestoreTbScreeningRepository();
  final _hivRepo = FirestoreHivScreeningRepository();

  List<HraScreening> _hraScreenings = [];
  List<CancerScreening> _cancerScreenings = [];
  List<TbScreening> _tbScreenings = [];
  List<HivScreening> _hivScreenings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(HealthScreeningStatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when the list of event IDs changes.
    final oldIds = oldWidget.eventIds;
    final newIds = widget.eventIds;
    final changed = oldIds == null
        ? newIds != null
        : newIds == null || !listEquals(oldIds, newIds);
    if (changed) _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    // If an empty list is explicitly passed, clear the data immediately.
    final eventIds = widget.eventIds;
    if (eventIds != null && eventIds.isEmpty) {
      setState(() {
        _hraScreenings = [];
        _cancerScreenings = [];
        _tbScreenings = [];
        _hivScreenings = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final List<Future<dynamic>> futures;
      if (eventIds != null) {
        // Scope to the provided event IDs (Firestore whereIn, max 30).
        futures = [
          _hraRepo.getHraScreeningsByEvents(eventIds),
          _cancerRepo.getCancerScreeningsByEvents(eventIds),
          _tbRepo.getTbScreeningsByEvents(eventIds),
          _hivRepo.getHivScreeningsByEvents(eventIds),
        ];
      } else {
        // Global aggregate – fetch from each collection without event filter.
        futures = [
          _hraRepo.getAllHraScreenings(),
          _cancerRepo.getAllCancerScreenings(),
          _tbRepo.getAllTbScreenings(),
          _hivRepo.getAllHivScreenings(),
        ];
      }
      final results = await Future.wait(futures);
      if (mounted) {
        setState(() {
          _hraScreenings = List<HraScreening>.from(results[0] as List);
          _cancerScreenings = List<CancerScreening>.from(results[1] as List);
          _tbScreenings = List<TbScreening>.from(results[2] as List);
          _hivScreenings = List<HivScreening>.from(results[3] as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  // ── HRA helpers ──────────────────────────────────────────────────────────

  _HraStats get _hraStats {
    final list = _hraScreenings;
    int underweight = 0, normal = 0, overweight = 0, obese = 0;
    int hypertension = 0, highBloodSugar = 0, highCholesterol = 0;
    int smokers = 0;
    final Map<String, int> conditionCounts = {};

    for (final s in list) {
      // BMI
      final bmi = double.tryParse(s.bmi ?? '');
      if (bmi != null) {
        if (bmi < 18.5) {
          underweight++;
        } else if (bmi < 25.0) {
          normal++;
        } else if (bmi < 30.0) {
          overweight++;
        } else {
          obese++;
        }
      }
      // Blood pressure (hypertension: systolic ≥140 OR diastolic ≥90)
      final sys = int.tryParse(s.bloodPressureSystolic ?? '');
      final dia = int.tryParse(s.bloodPressureDiastolic ?? '');
      if ((sys != null && sys >= 140) || (dia != null && dia >= 90)) {
        hypertension++;
      }
      // Blood sugar (diabetic range ≥7.0 mmol/L)
      final sugar = double.tryParse(s.bloodSugar ?? '');
      if (sugar != null && sugar >= 7.0) highBloodSugar++;
      // Cholesterol (borderline ≥5.2 mmol/L)
      final chol = double.tryParse(s.cholesterol ?? '');
      if (chol != null && chol >= 5.2) highCholesterol++;
      // Smoking (dailySmoke present and non-zero)
      final smoke = s.dailySmoke?.trim() ?? '';
      if (smoke.isNotEmpty && smoke != '0') smokers++;
      // Chronic conditions
      s.chronicConditions.forEach((condition, present) {
        if (present && condition != 'None') {
          conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
        }
      });
    }

    // Top 5 chronic conditions by frequency
    final topConditions = conditionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _HraStats(
      total: list.length,
      underweight: underweight,
      normal: normal,
      overweight: overweight,
      obese: obese,
      hypertension: hypertension,
      highBloodSugar: highBloodSugar,
      highCholesterol: highCholesterol,
      smokers: smokers,
      topConditions: topConditions.take(5).toList(),
    );
  }

  // ── Cancer helpers ────────────────────────────────────────────────────────

  _CancerStats get _cancerStats {
    final list = _cancerScreenings;
    int papCollected = 0, papPositive = 0;
    int psaDone = 0, psaAbnormal = 0;
    int referred = 0, symptomatic = 0;

    for (final s in list) {
      if (_isYes(s.papSmearSpecimenCollected)) papCollected++;
      if (s.papSmearResults?.toLowerCase() == 'positive') papPositive++;
      if (s.psaResults != null && s.psaResults!.isNotEmpty) psaDone++;
      final psa = s.psaResults?.toLowerCase() ?? '';
      if (psa == 'elevated' || psa == 'high') psaAbnormal++;
      if (s.referredFacility != null && s.referredFacility!.trim().isNotEmpty) {
        referred++;
      }
      if (_isYes(s.breastLump) ||
          _isYes(s.abnormalBleeding) ||
          _isYes(s.urinaryDifficulty) ||
          _isYes(s.weightLoss) ||
          _isYes(s.persistentPain)) {
        symptomatic++;
      }
    }

    return _CancerStats(
      total: list.length,
      papCollected: papCollected,
      papPositive: papPositive,
      psaDone: psaDone,
      psaAbnormal: psaAbnormal,
      referred: referred,
      symptomatic: symptomatic,
    );
  }

  // ── TB helpers ────────────────────────────────────────────────────────────

  _TbStats get _tbStats {
    final list = _tbScreenings;
    int symptomatic = 0, cough = 0, bloodInSputum = 0;
    int weightLoss = 0, nightSweats = 0;
    int treatedBefore = 0, contactWithTB = 0, referred = 0;

    for (final s in list) {
      if (_isYes(s.coughTwoWeeks)) cough++;
      if (_isYes(s.bloodInSputum)) bloodInSputum++;
      if (_isYes(s.weightLoss)) weightLoss++;
      if (_isYes(s.nightSweats)) nightSweats++;
      if (_isYes(s.coughTwoWeeks) ||
          _isYes(s.bloodInSputum) ||
          _isYes(s.weightLoss) ||
          _isYes(s.nightSweats)) {
        symptomatic++;
      }
      if (_isYes(s.treatedBefore)) treatedBefore++;
      if (_isYes(s.contactWithTB)) contactWithTB++;
      // NursingReferralOption enum names: patientNotReferred | referredToGP | referredToStateClinic
      final ref = s.nursingReferral ?? '';
      if (ref == 'referredToGP' || ref == 'referredToStateClinic') referred++;
    }

    return _TbStats(
      total: list.length,
      symptomatic: symptomatic,
      cough: cough,
      bloodInSputum: bloodInSputum,
      weightLoss: weightLoss,
      nightSweats: nightSweats,
      treatedBefore: treatedBefore,
      contactWithTB: contactWithTB,
      referred: referred,
    );
  }

  // ── HCT helpers ───────────────────────────────────────────────────────────

  _HctStats get _hctStats {
    final list = _hivScreenings;
    int firstTimeTesters = 0, highRisk = 0, knownPositive = 0;

    for (final s in list) {
      if (_isYes(s.firstHivTest)) firstTimeTesters++;
      if (_isYes(s.sharedNeedles) ||
          _isYes(s.unprotectedSex) ||
          _isYes(s.treatedSTI)) {
        highRisk++;
      }
      if (s.lastTestResult?.toLowerCase() == 'positive') knownPositive++;
    }

    return _HctStats(
      total: list.length,
      firstTimeTesters: firstTimeTesters,
      highRisk: highRisk,
      knownPositive: knownPositive,
    );
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  bool _isYes(String? value) => value?.toLowerCase() == 'yes';

  /// Returns [subset] when > 0, otherwise falls back to [total].
  /// Used so rates for sub-groups (e.g. PAP positives) are expressed as a
  /// fraction of the tested sub-group rather than the overall cohort.
  int _den(int subset, int total) => subset > 0 ? subset : total;

  String _pct(int count, int total) =>
      total > 0 ? '${(count / total * 100).toStringAsFixed(1)}%' : 'N/A';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Could not load screening data',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    final hra = _hraStats;
    final cancer = _cancerStats;
    final tb = _tbStats;
    final hct = _hctStats;

    // Nothing to show if no screenings were found at all
    final hasAnyData = hra.total + cancer.total + tb.total + hct.total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KenwellModernSectionHeader(
          label: 'ANALYTICS',
          title: 'Health Screening Analytics',
          subtitle: widget.sectionSubtitle ??
              'Statistics derived from HRA, Cancer, TB and HCT screenings',
        ),
        const SizedBox(height: 16),
        if (!hasAnyData) ...[
          _emptyState(context),
        ] else ...[
          _hraCard(context, hra),
          const SizedBox(height: 16),
          _cancerCard(context, cancer),
          const SizedBox(height: 16),
          _tbCard(context, tb),
          const SizedBox(height: 16),
          _hctCard(context, hct),
        ],
      ],
    );
  }

  // ── HRA Card ──────────────────────────────────────────────────────────────

  Widget _hraCard(BuildContext context, _HraStats s) {
    final theme = Theme.of(context);
    return KenwellFormCard(
      title: 'HRA — Health Risk Assessment  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? _noData(theme)
          : Column(
              children: [
                // BMI Distribution
                _sectionLabel('BMI Distribution', theme),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _pillStat('Underweight', s.underweight, Colors.blue, theme),
                    _pillStat('Normal', s.normal, Colors.green, theme),
                    _pillStat('Overweight', s.overweight, Colors.orange, theme),
                    _pillStat('Obese', s.obese, Colors.red, theme),
                  ],
                ),
                const Divider(height: 24),
                // Key health risks
                _statRow(Icons.favorite, 'Hypertension', s.hypertension,
                    s.total, Colors.red, theme),
                const Divider(),
                _statRow(Icons.bloodtype, 'Elevated Blood Sugar',
                    s.highBloodSugar, s.total, Colors.orange, theme),
                const Divider(),
                _statRow(Icons.monitor_heart, 'High Cholesterol',
                    s.highCholesterol, s.total, Colors.deepOrange, theme),
                const Divider(),
                _statRow(Icons.smoking_rooms, 'Smokers', s.smokers, s.total,
                    Colors.brown, theme),
                if (s.topConditions.isNotEmpty) ...[
                  const Divider(height: 24),
                  _sectionLabel('Top Chronic Conditions', theme),
                  const SizedBox(height: 8),
                  ...s.topConditions.map(
                      (e) => _conditionRow(e.key, e.value, s.total, theme)),
                ],
              ],
            ),
    );
  }

  // ── Cancer Card ───────────────────────────────────────────────────────────

  Widget _cancerCard(BuildContext context, _CancerStats s) {
    final theme = Theme.of(context);
    return KenwellFormCard(
      title: 'Cancer Screening  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? _noData(theme)
          : Column(
              children: [
                _statRow(Icons.science, 'PAP Smear Collected', s.papCollected,
                    s.total, Colors.purple, theme),
                const Divider(),
                _statRow(
                    Icons.warning_amber,
                    'PAP Smear Positive',
                    s.papPositive,
                    _den(s.papCollected, s.total),
                    Colors.deepPurple,
                    theme),
                const Divider(),
                _statRow(Icons.biotech, 'PSA Test Done', s.psaDone, s.total,
                    Colors.indigo, theme),
                const Divider(),
                _statRow(Icons.error_outline, 'PSA Abnormal', s.psaAbnormal,
                    _den(s.psaDone, s.total), Colors.red, theme),
                const Divider(),
                _statRow(Icons.report_problem_outlined, 'Symptomatic',
                    s.symptomatic, s.total, Colors.orange, theme),
                const Divider(),
                _statRow(Icons.local_hospital, 'Referred', s.referred, s.total,
                    Colors.teal, theme),
              ],
            ),
    );
  }

  // ── TB Card ───────────────────────────────────────────────────────────────

  Widget _tbCard(BuildContext context, _TbStats s) {
    final theme = Theme.of(context);
    return KenwellFormCard(
      title: 'TB Screening  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? _noData(theme)
          : Column(
              children: [
                _statRow(Icons.coronavirus, 'Symptomatic (≥1 symptom)',
                    s.symptomatic, s.total, Colors.red, theme),
                const Divider(height: 24),
                _sectionLabel('Symptom Breakdown', theme),
                const SizedBox(height: 8),
                _statRow(Icons.air, 'Cough ≥2 weeks', s.cough, s.total,
                    Colors.orange, theme),
                const Divider(),
                _statRow(Icons.water_drop, 'Blood in Sputum', s.bloodInSputum,
                    s.total, Colors.red, theme),
                const Divider(),
                _statRow(Icons.trending_down, 'Unexplained Weight Loss',
                    s.weightLoss, s.total, Colors.deepOrange, theme),
                const Divider(),
                _statRow(Icons.nightlight, 'Night Sweats', s.nightSweats,
                    s.total, Colors.purple, theme),
                const Divider(height: 24),
                _statRow(Icons.history, 'Previous TB Treatment',
                    s.treatedBefore, s.total, Colors.blue, theme),
                const Divider(),
                _statRow(Icons.people_alt, 'Known TB Contact', s.contactWithTB,
                    s.total, Colors.teal, theme),
                const Divider(),
                _statRow(Icons.local_hospital, 'Referred', s.referred, s.total,
                    Colors.green, theme),
              ],
            ),
    );
  }

  // ── HCT Card ──────────────────────────────────────────────────────────────

  Widget _hctCard(BuildContext context, _HctStats s) {
    final theme = Theme.of(context);
    return KenwellFormCard(
      title: 'HCT — HIV Counselling & Testing  (${s.total})',
      borderColor: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
      child: s.total == 0
          ? _noData(theme)
          : Column(
              children: [
                _statRow(Icons.person_add_alt_1, 'First-Time Testers',
                    s.firstTimeTesters, s.total, Colors.blue, theme),
                const Divider(),
                _statRow(Icons.warning, 'High-Risk Individuals', s.highRisk,
                    s.total, Colors.orange, theme),
                const Divider(),
                _statRow(Icons.medical_information, 'Known Positive History',
                    s.knownPositive, s.total, Colors.red, theme),
              ],
            ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _emptyState(BuildContext context) {
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

  Widget _noData(ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No records for this event',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );

  Widget _sectionLabel(String label, ThemeData theme) => Padding(
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

  Widget _statRow(IconData icon, String label, int count, int total,
      Color color, ThemeData theme) {
    const purple = Color(0xFF6A1B9A);
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final pctString = _pct(count, total);
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

  Widget _pillStat(String label, int count, Color color, ThemeData theme) {
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
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _conditionRow(
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
            '$count (${_pct(count, total)})',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: KenwellColors.secondaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _HraStats {
  final int total;
  final int underweight, normal, overweight, obese;
  final int hypertension, highBloodSugar, highCholesterol, smokers;
  final List<MapEntry<String, int>> topConditions;

  const _HraStats({
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
}

class _CancerStats {
  final int total;
  final int papCollected, papPositive;
  final int psaDone, psaAbnormal;
  final int referred, symptomatic;

  const _CancerStats({
    required this.total,
    required this.papCollected,
    required this.papPositive,
    required this.psaDone,
    required this.psaAbnormal,
    required this.referred,
    required this.symptomatic,
  });
}

class _TbStats {
  final int total;
  final int symptomatic;
  final int cough, bloodInSputum, weightLoss, nightSweats;
  final int treatedBefore, contactWithTB, referred;

  const _TbStats({
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
}

class _HctStats {
  final int total;
  final int firstTimeTesters, highRisk, knownPositive;

  const _HctStats({
    required this.total,
    required this.firstTimeTesters,
    required this.highRisk,
    required this.knownPositive,
  });
}
