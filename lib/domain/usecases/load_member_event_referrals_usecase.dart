import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hra_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_tb_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';

/// Summarises the referral outcome for a single event attendance.
///
/// This value class lives in the domain layer so both use case and UI can
/// reference it without cross-layer coupling.
class EventReferralSummary {
  /// `'healthy'`, `'at_risk'`, or `null` when no referral data is available.
  final String? status;

  /// The screening types and specific metrics that were flagged.
  final List<String> riskFlags;

  const EventReferralSummary({this.status, this.riskFlags = const []});

  bool get isHighRisk => status == 'at_risk';
  bool get isHealthy => status == 'healthy';
}

/// Result returned by [LoadMemberEventReferralsUseCase].
class MemberEventReferrals {
  /// Raw event attendance records from Firestore.
  final List<Map<String, dynamic>> events;

  /// Map of `eventId → [EventReferralSummary]`.
  final Map<String, EventReferralSummary> referralSummaries;

  const MemberEventReferrals({
    required this.events,
    required this.referralSummaries,
  });
}

/// Loads a member's event attendance records and derives per-event referral
/// outcomes by querying TB, Cancer and HRA screening collections in parallel.
///
/// Moving this orchestration out of [MemberEventsViewModel] means the ViewModel
/// only manages UI state while all multi-repository coordination lives here.
class LoadMemberEventReferralsUseCase {
  LoadMemberEventReferralsUseCase({
    FirestoreMemberRepository? memberRepository,
    FirestoreTbScreeningRepository? tbRepository,
    FirestoreCancerScreeningRepository? cancerRepository,
    FirestoreHraRepository? hraRepository,
  })  : _memberRepository = memberRepository ?? FirestoreMemberRepository(),
        _tbRepository = tbRepository ?? FirestoreTbScreeningRepository(),
        _cancerRepository =
            cancerRepository ?? FirestoreCancerScreeningRepository(),
        _hraRepository = hraRepository ?? FirestoreHraRepository();

  final FirestoreMemberRepository _memberRepository;
  final FirestoreTbScreeningRepository _tbRepository;
  final FirestoreCancerScreeningRepository _cancerRepository;
  final FirestoreHraRepository _hraRepository;

  Future<MemberEventReferrals> call(Member member) async {
    // Step 1: fetch attendance records.
    final events = await _memberRepository.fetchMemberEvents(member);

    // Step 2: load all screening records for this member in parallel.
    final results = await Future.wait([
      _tbRepository
          .getTbScreeningsByMember(member.id)
          .catchError((_) => <TbScreening>[]),
      _cancerRepository
          .getCancerScreeningsByMember(member.id)
          .catchError((_) => <CancerScreening>[]),
      _hraRepository
          .getHraScreeningsByMember(member.id)
          .catchError((_) => <HraScreening>[]),
    ]);

    final tbScreenings = results[0] as List<TbScreening>;
    final cancerScreenings = results[1] as List<CancerScreening>;
    final hraScreenings = results[2] as List<HraScreening>;

    // Step 3: derive referral summary per event.
    final summaries = <String, EventReferralSummary>{};
    for (final event in events) {
      final eventId = event['eventId'] as String? ?? '';
      if (eventId.isEmpty) continue;
      summaries[eventId] = _deriveReferral(
        eventId,
        tbScreenings,
        cancerScreenings,
        hraScreenings,
      );
    }

    return MemberEventReferrals(events: events, referralSummaries: summaries);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

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
    final cancer = cancerList.where((s) => s.eventId == eventId).firstOrNull;
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
