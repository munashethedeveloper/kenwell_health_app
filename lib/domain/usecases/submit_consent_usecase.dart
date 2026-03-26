import 'package:kenwell_health_app/data/repositories_dcl/firestore_consent_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_survey_repository.dart';
import 'package:kenwell_health_app/data/services/app_performance.dart';
import 'package:kenwell_health_app/domain/models/consent.dart';
import 'package:kenwell_health_app/utils/logger.dart';

/// Use case that persists a completed [Consent] to two Firestore collections:
///
///  1. **`consents`** — the primary record, referenced by the wellness flow.
///  2. **`survey_results`** — a secondary analytics record; failure is
///     non-fatal so a bad write here never blocks the consent step.
///
/// Separating this from [ConsentScreenViewModel] means the ViewModel only
/// manages form state, while this class owns the persistence strategy and
/// the survey-data transformation.
class SubmitConsentUseCase {
  SubmitConsentUseCase({
    FirestoreConsentRepository? consentRepository,
    FirestoreSurveyRepository? surveyRepository,
  })  : _consentRepo = consentRepository ?? FirestoreConsentRepository(),
        _surveyRepo = surveyRepository ?? const FirestoreSurveyRepository();

  final FirestoreConsentRepository _consentRepo;
  final FirestoreSurveyRepository _surveyRepo;

  /// Saves [consent] to both Firestore collections.
  ///
  /// The primary `consents` write is fatal — callers should `rethrow` on
  /// failure.  The secondary `survey_results` write is best-effort.
  Future<void> call(Consent consent) async {
    return AppPerformance.traceAsync(
      AppPerformance.kSubmitConsent,
      () => _execute(consent),
    );
  }

  Future<void> _execute(Consent consent) async {
    // 1. Primary save — fatal on failure.
    await _consentRepo.addConsent(consent);
    AppLogger.info('SubmitConsentUseCase: consent saved to consents collection');

    // 2. Secondary analytics save — non-fatal.
    try {
      await _surveyRepo.saveSurveyResult(
        id: consent.id,
        data: _toSurveyData(consent),
      );
      AppLogger.info(
          'SubmitConsentUseCase: consent saved to survey_results collection');
    } catch (e) {
      AppLogger.error(
          'SubmitConsentUseCase: survey_results save failed (non-fatal)', e);
    }
  }

  /// Maps a [Consent] to the survey-results document shape.
  Map<String, dynamic> _toSurveyData(Consent consent) => {
        'id': consent.id,
        'memberId': consent.memberId,
        'eventId': consent.eventId,
        'type': 'consent',
        'venue': consent.venue,
        'date': consent.date.toIso8601String(),
        'practitioner': consent.practitioner,
        'screenings': {
          'hra': consent.hra,
          'hct': consent.hct,
          'tb': consent.tb,
          'cancer': consent.cancer,
        },
        'signatureProvided': consent.signatureData != null,
        'createdAt': consent.createdAt.toIso8601String(),
      };
}
