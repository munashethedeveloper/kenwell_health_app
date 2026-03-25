import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_consent_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_survey_repository.dart';
import 'package:kenwell_health_app/domain/models/consent.dart';
import 'package:kenwell_health_app/domain/usecases/submit_consent_usecase.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockFirestoreConsentRepository extends Mock
    implements FirestoreConsentRepository {}

class MockFirestoreSurveyRepository extends Mock
    implements FirestoreSurveyRepository {}

// ── Helpers ───────────────────────────────────────────────────────────────────

Consent _buildConsent({String id = 'consent-1'}) => Consent(
      id: id,
      memberId: 'member-1',
      eventId: 'event-1',
      venue: 'Main Hall',
      date: DateTime(2025, 6, 1),
      practitioner: 'Nurse Smith',
      hra: true,
      hct: false,
      tb: false,
      cancer: false,
      createdAt: DateTime(2025, 6, 1),
    );

void main() {
  late MockFirestoreConsentRepository mockConsentRepo;
  late MockFirestoreSurveyRepository mockSurveyRepo;
  late SubmitConsentUseCase useCase;

  setUp(() {
    mockConsentRepo = MockFirestoreConsentRepository();
    mockSurveyRepo = MockFirestoreSurveyRepository();

    useCase = SubmitConsentUseCase(
      consentRepository: mockConsentRepo,
      surveyRepository: mockSurveyRepo,
    );

    registerFallbackValue(_buildConsent());
  });

  group('SubmitConsentUseCase', () {
    test('writes consent and survey_results when both succeed', () async {
      final consent = _buildConsent();
      when(() => mockConsentRepo.addConsent(any())).thenAnswer((_) async {});
      when(() => mockSurveyRepo.saveSurveyResult(
            id: any(named: 'id'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});

      await useCase(consent);

      verify(() => mockConsentRepo.addConsent(any())).called(1);
      verify(() => mockSurveyRepo.saveSurveyResult(
            id: any(named: 'id'),
            data: any(named: 'data'),
          )).called(1);
    });

    test('completes without error when survey_results write fails (non-fatal)',
        () async {
      final consent = _buildConsent(id: 'consent-2');
      when(() => mockConsentRepo.addConsent(any())).thenAnswer((_) async {});
      when(() => mockSurveyRepo.saveSurveyResult(
            id: any(named: 'id'),
            data: any(named: 'data'),
          )).thenThrow(Exception('quota exceeded'));

      // Should complete without throwing.
      await expectLater(useCase(consent), completes);
      verify(() => mockConsentRepo.addConsent(any())).called(1);
    });

    test('propagates exception when primary consent write fails (fatal)',
        () async {
      final consent = _buildConsent(id: 'consent-3');
      when(() => mockConsentRepo.addConsent(any()))
          .thenThrow(Exception('permission denied'));

      expect(() => useCase(consent), throwsException);
      verifyNever(() => mockSurveyRepo.saveSurveyResult(
            id: any(named: 'id'),
            data: any(named: 'data'),
          ));
    });
  });
}
