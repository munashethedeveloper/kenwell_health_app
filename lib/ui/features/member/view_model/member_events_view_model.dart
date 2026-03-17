import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import '../../../../data/repositories_dcl/firestore_tb_screening_repository.dart';
import '../../../../data/repositories_dcl/firestore_cancer_screening_repository.dart';
import '../../../../data/repositories_dcl/firestore_hra_repository.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/models/tb_screening.dart';
import '../../../../domain/models/cander_screening.dart';
import '../../../../domain/models/hra_screening.dart';

/// Summarises the referral outcome for a single event attendance.
class EventReferralSummary {
  /// `'healthy'`, `'at_risk'`, or `null` when no referral data is available.
  final String? status;

  /// The screening types and specific metrics that were flagged.
  final List<String> riskFlags;

  const EventReferralSummary({this.status, this.riskFlags = const []});

  bool get isHighRisk => status == 'at_risk';
  bool get isHealthy => status == 'healthy';
}

/// ViewModel for [MemberEventsScreen].
///
/// Owns the [FirestoreMemberRepository] dependency and all data-loading logic,
/// so the screen itself is a pure UI widget.
class MemberEventsViewModel extends ChangeNotifier {
  MemberEventsViewModel({
    required Member member,
    FirestoreMemberRepository? repository,
  })  : _member = member,
        _repository = repository ?? FirestoreMemberRepository();

  final Member _member;
  final FirestoreMemberRepository _repository;
  final _tbRepo = FirestoreTbScreeningRepository();
  final _cancerRepo = FirestoreCancerScreeningRepository();
  final _hraRepo = FirestoreHraRepository();

  // ── State ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// Map of eventId → referral summary, populated after loadMemberEvents().
  Map<String, EventReferralSummary> _referralSummaries = {};

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns the referral summary for [eventId], or null if not available.
  EventReferralSummary? referralFor(String eventId) =>
      _referralSummaries[eventId];

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Loads the events attended by [_member] from Firestore, then derives
  /// per-event referral outcomes from the individual screening collections.
  Future<void> loadMemberEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load member_events records.
      _events = await _repository.fetchMemberEvents(_member);

      // Load all screening records for this member in parallel (one query per
      // collection instead of one per event card).
      final results = await Future.wait([
        _tbRepo
            .getTbScreeningsByMember(_member.id)
            .catchError((_) => <TbScreening>[]),
        _cancerRepo
            .getCancerScreeningsByMember(_member.id)
            .catchError((_) => <CancerScreening>[]),
        _hraRepo
            .getHraScreeningsByMember(_member.id)
            .catchError((_) => <HraScreening>[]),
      ]);

      final tbScreenings = results[0] as List<TbScreening>;
      final cancerScreenings = results[1] as List<CancerScreening>;
      final hraScreenings = results[2] as List<HraScreening>;

      // Build a map of eventId → referral summary.
      final summaries = <String, EventReferralSummary>{};
      for (final event in _events) {
        final eventId = event['eventId'] as String? ?? '';
        if (eventId.isEmpty) continue;
        summaries[eventId] =
            _deriveReferral(eventId, tbScreenings, cancerScreenings, hraScreenings);
      }
      _referralSummaries = summaries;
    } catch (e) {
      _errorMessage = 'Failed to load events: $e';
      debugPrint('MemberEventsViewModel.loadMemberEvents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Formats a Firestore [Timestamp], [String], or [DateTime] date value for
  /// display.
  String formatDate(dynamic date) {
    if (date == null) return 'Date not available';
    try {
      final DateTime dt;
      if (date is Timestamp) {
        dt = date.toDate();
      } else if (date is String) {
        dt = DateTime.parse(date);
      } else if (date is DateTime) {
        dt = date;
      } else {
        return 'Invalid date';
      }
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return 'Date format error';
    }
  }

  /// Derives the referral outcome for a single event from the available
  /// screening records.
  ///
  /// Rules:
  /// - If any screening shows `nursingReferral == 'referredToStateClinic'`
  ///   → at_risk with a list of flagged areas.
  /// - If all present screenings show `nursingReferral == 'patientNotReferred'`
  ///   → healthy.
  /// - If HRA metrics indicate risk even without an explicit referral flag,
  ///   the member is still considered at_risk for those metrics.
  /// - If no screening data exists for this event → null.
  EventReferralSummary _deriveReferral(
    String eventId,
    List<TbScreening> tbList,
    List<CancerScreening> cancerList,
    List<HraScreening> hraList,
  ) {
    final flags = <String>[];
    bool hasAnyData = false;
    bool anyAtRisk = false;

    bool isYes(String? v) =>
        v?.toLowerCase() == 'yes' || v?.toLowerCase() == 'true';

    // ── TB ────────────────────────────────────────────────────────────────
    final tb = tbList.where((s) => s.eventId == eventId).firstOrNull;
    if (tb != null) {
      hasAnyData = true;
      if (tb.nursingReferral == 'referredToStateClinic') {
        anyAtRisk = true;
        // List flagged TB symptoms
        final symptoms = <String>[];
        if (isYes(tb.coughTwoWeeks)) symptoms.add('Cough (2+ weeks)');
        if (isYes(tb.bloodInSputum)) symptoms.add('Blood in sputum');
        if (isYes(tb.weightLoss)) symptoms.add('Weight loss');
        if (isYes(tb.nightSweats)) symptoms.add('Night sweats');
        final label =
            symptoms.isNotEmpty ? 'TB (${symptoms.join(', ')})' : 'TB';
        flags.add(label);
      }
    }

    // ── Cancer ────────────────────────────────────────────────────────────
    final cancer =
        cancerList.where((s) => s.eventId == eventId).firstOrNull;
    if (cancer != null) {
      hasAnyData = true;
      if (cancer.nursingReferral == 'referredToStateClinic') {
        anyAtRisk = true;
        final areas = <String>[];
        if (cancer.papSmearResults != null &&
            cancer.papSmearResults!.isNotEmpty) {
          areas.add('Pap smear');
        }
        if (cancer.breastLightExamFindings != null &&
            cancer.breastLightExamFindings!.isNotEmpty) {
          areas.add('Breast exam');
        }
        if (cancer.psaResults != null) {
          final psa = double.tryParse(cancer.psaResults!);
          if (psa != null && psa > 4.0) areas.add('PSA');
        }
        final label = areas.isNotEmpty
            ? 'Cancer (${areas.join(', ')})'
            : 'Cancer screening';
        flags.add(label);
      }
    }

    // ── HRA ───────────────────────────────────────────────────────────────
    final hra = hraList.where((s) => s.eventId == eventId).firstOrNull;
    if (hra != null) {
      hasAnyData = true;
      final hraFlags = <String>[];
      final bmi = double.tryParse(hra.bmi ?? '');
      if (bmi != null && (bmi < 18.5 || bmi >= 30.0)) {
        hraFlags.add(bmi < 18.5 ? 'Underweight (BMI)' : 'Obese (BMI)');
      } else if (bmi != null && bmi >= 25.0) {
        hraFlags.add('Overweight (BMI)');
      }
      final sys = int.tryParse(hra.bloodPressureSystolic ?? '');
      final dia = int.tryParse(hra.bloodPressureDiastolic ?? '');
      if ((sys != null && sys >= 140) || (dia != null && dia >= 90)) {
        hraFlags.add('High blood pressure');
      }
      final sugar = double.tryParse(hra.bloodSugar ?? '');
      if (sugar != null && sugar >= 7.0) hraFlags.add('High blood sugar');
      final chol = double.tryParse(hra.cholesterol ?? '');
      if (chol != null && chol >= 5.2) hraFlags.add('High cholesterol');

      if (hraFlags.isNotEmpty) {
        anyAtRisk = true;
        flags.add('HRA (${hraFlags.join(', ')})');
      }
    }

    if (!hasAnyData) return const EventReferralSummary();

    if (anyAtRisk) {
      return EventReferralSummary(status: 'at_risk', riskFlags: flags);
    }
    return const EventReferralSummary(status: 'healthy');
  }
}
