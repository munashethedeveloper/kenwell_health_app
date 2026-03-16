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
import 'sections/screening_stats_helpers.dart';
import 'sections/hra_stats_card.dart';
import 'sections/cancer_stats_card.dart';
import 'sections/tb_stats_card.dart';
import 'sections/hct_stats_card.dart';

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
    final oldIds = oldWidget.eventIds;
    final newIds = widget.eventIds;
    final changed = oldIds == null
        ? newIds != null
        : newIds == null || !listEquals(oldIds, newIds);
    if (changed) _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

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
        futures = [
          _hraRepo.getHraScreeningsByEvents(eventIds),
          _cancerRepo.getCancerScreeningsByEvents(eventIds),
          _tbRepo.getTbScreeningsByEvents(eventIds),
          _hivRepo.getHivScreeningsByEvents(eventIds),
        ];
      } else {
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

  // ── Aggregate calculators ─────────────────────────────────────────────────

  HraStats get _hraStats {
    final list = _hraScreenings;
    int underweight = 0, normal = 0, overweight = 0, obese = 0;
    int hypertension = 0, highBloodSugar = 0, highCholesterol = 0;
    int smokers = 0;
    final Map<String, int> conditionCounts = {};

    for (final s in list) {
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
      final sys = int.tryParse(s.bloodPressureSystolic ?? '');
      final dia = int.tryParse(s.bloodPressureDiastolic ?? '');
      if ((sys != null && sys >= 140) || (dia != null && dia >= 90)) {
        hypertension++;
      }
      final sugar = double.tryParse(s.bloodSugar ?? '');
      if (sugar != null && sugar >= 7.0) highBloodSugar++;
      final chol = double.tryParse(s.cholesterol ?? '');
      if (chol != null && chol >= 5.2) highCholesterol++;
      final smoke = s.dailySmoke?.trim() ?? '';
      if (smoke.isNotEmpty && smoke != '0') smokers++;
      s.chronicConditions.forEach((condition, present) {
        if (present && condition != 'None') {
          conditionCounts[condition] = (conditionCounts[condition] ?? 0) + 1;
        }
      });
    }

    final topConditions = conditionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return HraStats(
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

  CancerStats get _cancerStats {
    final list = _cancerScreenings;
    int papCollected = 0, papPositive = 0;
    int psaDone = 0, psaAbnormal = 0;
    int symptomatic = 0, referred = 0;

    for (final s in list) {
      final papResult = s.papSmearResults?.toLowerCase();
      if (s.papSmearSpecimenCollected?.toLowerCase() == 'yes') papCollected++;
      if (papResult != null &&
          (papResult.contains('positive') || papResult.contains('abnormal'))) {
        papPositive++;
      }
      if (s.psaResults != null && s.psaResults!.isNotEmpty) psaDone++;
      if (double.tryParse(s.psaResults ?? '') != null &&
          double.parse(s.psaResults!) > 4.0) {
        psaAbnormal++;
      }
      final symptoms = [
        s.breastLightExamFindings,
      ].where((f) => f != null && f.isNotEmpty);
      if (symptoms.isNotEmpty) symptomatic++;
      if (s.nursingReferral != null && s.nursingReferral!.isNotEmpty)
        referred++;
    }

    return CancerStats(
      total: list.length,
      papCollected: papCollected,
      papPositive: papPositive,
      psaDone: psaDone,
      psaAbnormal: psaAbnormal,
      symptomatic: symptomatic,
      referred: referred,
    );
  }

  TbStats get _tbStats {
    final list = _tbScreenings;
    int symptomatic = 0, cough = 0, bloodInSputum = 0;
    int weightLoss = 0, nightSweats = 0;
    int treatedBefore = 0, contactWithTB = 0, referred = 0;

    bool isYes(String? v) =>
        v?.toLowerCase() == 'yes' || v?.toLowerCase() == 'true';

    for (final s in list) {
      final hasCough = isYes(s.coughTwoWeeks);
      final hasBlood = isYes(s.bloodInSputum);
      final hasWeightLoss = isYes(s.weightLoss);
      final hasNightSweats = isYes(s.nightSweats);
      if (hasCough) cough++;
      if (hasBlood) bloodInSputum++;
      if (hasWeightLoss) weightLoss++;
      if (hasNightSweats) nightSweats++;
      if (hasCough || hasBlood || hasWeightLoss || hasNightSweats) {
        symptomatic++;
      }
      if (isYes(s.treatedBefore)) treatedBefore++;
      if (isYes(s.contactWithTB)) contactWithTB++;
      if (s.nursingReferral?.toLowerCase() == 'yes') referred++;
    }

    return TbStats(
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

  HctStats get _hctStats {
    final list = _hivScreenings;
    int firstTimeTesters = 0, highRisk = 0, knownPositive = 0;

    for (final s in list) {
      if (s.firstHivTest?.toLowerCase() == 'yes') firstTimeTesters++;
      if (s.sharedNeedles?.toLowerCase() == 'yes' ||
          s.unprotectedSex?.toLowerCase() == 'yes') highRisk++;
      if (s.lastTestResult?.toLowerCase() == 'positive') knownPositive++;
    }

    return HctStats(
      total: list.length,
      firstTimeTesters: firstTimeTesters,
      highRisk: highRisk,
      knownPositive: knownPositive,
    );
  }

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

    final hasAnyData = hra.total + cancer.total + tb.total + hct.total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Health Screening Analytics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF201C58),
          ),
        ),
        const SizedBox(height: 16),
        if (!hasAnyData) ...[
          buildScreeningEmptyState(context),
        ] else ...[
          HraStatsCard(stats: hra),
          const SizedBox(height: 16),
          CancerStatsCard(stats: cancer),
          const SizedBox(height: 16),
          TbStatsCard(stats: tb),
          const SizedBox(height: 16),
          HctStatsCard(stats: hct),
        ],
      ],
    );
  }
}
