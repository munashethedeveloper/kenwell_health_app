import 'package:kenwell_health_app/utils/logger.dart';
import '../../data/repositories_dcl/firestore_cancer_screening_repository.dart';
import '../../data/repositories_dcl/firestore_consent_repository.dart';
import '../../data/repositories_dcl/firestore_hiv_screening_repository.dart';
import '../../data/repositories_dcl/firestore_hra_repository.dart';
import '../../data/repositories_dcl/firestore_survey_repository.dart';
import '../../data/repositories_dcl/firestore_tb_screening_repository.dart';

/// Result object for [LoadWellnessCompletionStatusUseCase].
///
/// Carries every completion / enabled flag for a single member + event so
/// that [WellnessFlowViewModel] can apply them in one atomic update.
class WellnessCompletionStatus {
  const WellnessCompletionStatus({
    required this.consentCompleted,
    required this.hraEnabled,
    required this.hctEnabled,
    required this.tbEnabled,
    required this.cancerEnabled,
    required this.hraCompleted,
    required this.hctCompleted,
    required this.tbCompleted,
    required this.cancerCompleted,
    required this.surveyCompleted,
    this.consentSancNumber,
    this.consentRank,
    this.consentHpSignatureBase64,
  });

  final bool consentCompleted;
  final bool hraEnabled;
  final bool hctEnabled;
  final bool tbEnabled;
  final bool cancerEnabled;
  final bool hraCompleted;
  final bool hctCompleted;
  final bool tbCompleted;
  final bool cancerCompleted;
  final bool surveyCompleted;
  final String? consentSancNumber;
  final String? consentRank;
  final String? consentHpSignatureBase64;
}

/// Use case that loads all wellness-flow completion flags for a member + event
/// from Firestore in parallel, returning a single [WellnessCompletionStatus].
///
/// Responsibilities:
///   - Query each screening collection once.
///   - Determine which screenings were consented to.
///   - Return a plain data object; the caller ([WellnessFlowViewModel]) applies
///     the result to its own state.
class LoadWellnessCompletionStatusUseCase {
  LoadWellnessCompletionStatusUseCase({
    FirestoreConsentRepository? consentRepository,
    FirestoreHraRepository? hraRepository,
    FirestoreHivScreeningRepository? hivRepository,
    FirestoreTbScreeningRepository? tbRepository,
    FirestoreCancerScreeningRepository? cancerRepository,
    FirestoreSurveyRepository? surveyRepository,
  })  : _consentRepo = consentRepository ?? FirestoreConsentRepository(),
        _hraRepo = hraRepository ?? FirestoreHraRepository(),
        _hivRepo = hivRepository ?? FirestoreHivScreeningRepository(),
        _tbRepo = tbRepository ?? FirestoreTbScreeningRepository(),
        _cancerRepo = cancerRepository ?? FirestoreCancerScreeningRepository(),
        _surveyRepo = surveyRepository ?? const FirestoreSurveyRepository();

  final FirestoreConsentRepository _consentRepo;
  final FirestoreHraRepository _hraRepo;
  final FirestoreHivScreeningRepository _hivRepo;
  final FirestoreTbScreeningRepository _tbRepo;
  final FirestoreCancerScreeningRepository _cancerRepo;
  final FirestoreSurveyRepository _surveyRepo;

  /// Fetches all completion flags for [memberId] / [eventId].
  ///
  /// Each Firestore query runs independently; failures are swallowed and
  /// default to `false` so that a single failing collection never blocks
  /// the entire wellness flow.
  Future<WellnessCompletionStatus> call({
    required String memberId,
    required String eventId,
  }) async {
    bool consentCompleted = false;
    bool hraEnabled = false;
    bool hctEnabled = false;
    bool tbEnabled = false;
    bool cancerEnabled = false;
    bool hraCompleted = false;
    bool hctCompleted = false;
    bool tbCompleted = false;
    bool cancerCompleted = false;
    bool surveyCompleted = false;
    String? consentSancNumber;
    String? consentRank;
    String? consentHpSignatureBase64;

    // Consent
    try {
      final consents = await _consentRepo.getConsentsByMember(memberId);
      final matching = consents.where((c) => c.eventId == eventId).toList();
      if (matching.isNotEmpty) {
        consentCompleted = true;
        final consent = matching.first;
        hraEnabled = consent.hra;
        hctEnabled = consent.hct;
        tbEnabled = consent.tb;
        cancerEnabled = consent.cancer;
        consentSancNumber = consent.sancNumber;
        consentRank = consent.rank;
        consentHpSignatureBase64 = consent.hpSignatureData;
      }
    } catch (e) {
      AppLogger.error('LoadWellnessCompletionStatusUseCase: consent query failed', e);
    }

    // Run remaining checks in parallel for speed.
    // Each Future returns a bool; results are indexed in declaration order.
    final parallel = await Future.wait<bool>([
      _hraRepo
          .getHraScreeningsByMember(memberId)
          .then((list) => list.any((h) => h.eventId == eventId))
          .catchError((Object _) => false),
      _hivRepo
          .getHivScreeningsByMember(memberId)
          .then((list) => list.any((h) => h.eventId == eventId))
          .catchError((Object _) => false),
      _tbRepo
          .getTbScreeningsByMember(memberId)
          .then((list) => list.any((t) => t.eventId == eventId))
          .catchError((Object _) => false),
      _cancerRepo
          .getCancerScreeningsByMember(memberId)
          .then((list) => list.any((c) => c.eventId == eventId))
          .catchError((Object _) => false),
      _surveyRepo
          .hasCompletedSurvey(memberId: memberId, eventId: eventId)
          .catchError((Object _) => false),
    ]);

    hraCompleted = parallel[0];
    hctCompleted = parallel[1];
    tbCompleted = parallel[2];
    cancerCompleted = parallel[3];
    surveyCompleted = parallel[4];

    return WellnessCompletionStatus(
      consentCompleted: consentCompleted,
      hraEnabled: hraEnabled,
      hctEnabled: hctEnabled,
      tbEnabled: tbEnabled,
      cancerEnabled: cancerEnabled,
      hraCompleted: hraCompleted,
      hctCompleted: hctCompleted,
      tbCompleted: tbCompleted,
      cancerCompleted: cancerCompleted,
      surveyCompleted: surveyCompleted,
      consentSancNumber: consentSancNumber,
      consentRank: consentRank,
      consentHpSignatureBase64: consentHpSignatureBase64,
    );
  }
}
