import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_consent_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hct_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hra_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_survey_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_tb_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/domain/models/consent.dart';
import 'package:kenwell_health_app/domain/models/hct_screening.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/domain/usecases/load_wellness_completion_status_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────────

class MockConsentRepo extends Mock implements FirestoreConsentRepository {}

class MockHraRepo extends Mock implements FirestoreHraRepository {}

class MockHctRepo extends Mock implements FirestoreHctScreeningRepository {}

class MockTbRepo extends Mock implements FirestoreTbScreeningRepository {}

class MockCancerRepo extends Mock
    implements FirestoreCancerScreeningRepository {}

class MockSurveyRepo extends Mock implements FirestoreSurveyRepository {}

// ── Helpers ────────────────────────────────────────────────────────────────────

const _memberId = 'member-1';
const _eventId = 'event-1';
const _otherEventId = 'event-other';

Consent _buildConsent({
  bool hra = true,
  bool hct = false,
  bool tb = false,
  bool cancer = false,
  String? eventId = _eventId,
}) =>
    Consent(
      id: 'consent-1',
      memberId: _memberId,
      eventId: eventId,
      venue: 'Venue',
      date: DateTime(2025, 6, 1),
      practitioner: 'Dr Smith',
      hra: hra,
      hct: hct,
      tb: tb,
      cancer: cancer,
      createdAt: DateTime(2025, 6, 1),
    );

HraScreening _buildHraScreening({String? eventId = _eventId}) => HraScreening(
      id: 'hra-1',
      memberId: _memberId,
      eventId: eventId,
      chronicConditions: const {},
    );

HctScreening _buildHctScreening({String? eventId = _eventId}) => HctScreening(
      id: 'hiv-1',
      memberId: _memberId,
      eventId: eventId,
      createdAt: DateTime(2025, 6, 1),
      updatedAt: DateTime(2025, 6, 1),
    );

TbScreening _buildTbScreening({String eventId = _eventId}) => TbScreening(
      id: 'tb-1',
      memberId: _memberId,
      eventId: eventId,
      nurseFirstName: 'Nurse',
      nurseLastName: 'Smith',
      rank: 'RN',
      sancNumber: '12345',
      nurseDate: '2025-06-01',
    );

CancerScreening _buildCancerScreening({String eventId = _eventId}) =>
    CancerScreening(
      id: 'cancer-1',
      memberId: _memberId,
      eventId: eventId,
    );

LoadWellnessCompletionStatusUseCase _buildUseCase({
  required MockConsentRepo consent,
  required MockHraRepo hra,
  required MockHctRepo hct,
  required MockTbRepo tb,
  required MockCancerRepo cancer,
  required MockSurveyRepo survey,
}) =>
    LoadWellnessCompletionStatusUseCase(
      consentRepository: consent,
      hraRepository: hra,
      hctRepository: hct,
      tbRepository: tb,
      cancerRepository: cancer,
      surveyRepository: survey,
    );

void main() {
  late MockConsentRepo mockConsent;
  late MockHraRepo mockHra;
  late MockHctRepo mockHct;
  late MockTbRepo mockTb;
  late MockCancerRepo mockCancer;
  late MockSurveyRepo mockSurvey;

  setUp(() {
    mockConsent = MockConsentRepo();
    mockHra = MockHraRepo();
    mockHct = MockHctRepo();
    mockTb = MockTbRepo();
    mockCancer = MockCancerRepo();
    mockSurvey = MockSurveyRepo();
  });

  group('LoadWellnessCompletionStatusUseCase – no consent', () {
    test('all flags false when no consent exists for the event', () async {
      when(() => mockConsent.getConsentsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockHra.getHraScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => false);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );
      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.consentCompleted, isFalse);
      expect(result.hraEnabled, isFalse);
      expect(result.hctEnabled, isFalse);
      expect(result.tbEnabled, isFalse);
      expect(result.cancerEnabled, isFalse);
      expect(result.hraCompleted, isFalse);
      expect(result.hctCompleted, isFalse);
      expect(result.tbCompleted, isFalse);
      expect(result.cancerCompleted, isFalse);
      expect(result.surveyCompleted, isFalse);
    });
  });

  group('LoadWellnessCompletionStatusUseCase – with consent', () {
    test('consent flags reflect consented services', () async {
      final consent =
          _buildConsent(hra: true, hct: true, tb: false, cancer: false);
      when(() => mockConsent.getConsentsByMember(any()))
          .thenAnswer((_) async => [consent]);
      when(() => mockHra.getHraScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => false);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );
      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.consentCompleted, isTrue);
      expect(result.hraEnabled, isTrue);
      expect(result.hctEnabled, isTrue);
      expect(result.tbEnabled, isFalse);
      expect(result.cancerEnabled, isFalse);
    });

    test('ignores consents for other events', () async {
      // Consent for a DIFFERENT event should not set consentCompleted.
      final otherConsent = _buildConsent(eventId: _otherEventId);
      when(() => mockConsent.getConsentsByMember(any()))
          .thenAnswer((_) async => [otherConsent]);
      when(() => mockHra.getHraScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => false);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );
      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.consentCompleted, isFalse);
    });
  });

  group('LoadWellnessCompletionStatusUseCase – screening completion', () {
    test('all screenings marked completed when records match the event',
        () async {
      when(() => mockConsent.getConsentsByMember(any())).thenAnswer((_) async =>
          [_buildConsent(hra: true, hct: true, tb: true, cancer: true)]);
      when(() => mockHra.getHraScreeningsByMember(any()))
          .thenAnswer((_) async => [_buildHraScreening()]);
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => [_buildHctScreening()]);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => [_buildTbScreening()]);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => [_buildCancerScreening()]);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => true);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );
      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.hraCompleted, isTrue);
      expect(result.hctCompleted, isTrue);
      expect(result.tbCompleted, isTrue);
      expect(result.cancerCompleted, isTrue);
      expect(result.surveyCompleted, isTrue);
    });

    test('screenings for other events do not set completion flags', () async {
      when(() => mockConsent.getConsentsByMember(any()))
          .thenAnswer((_) async => []);
      // HRA record exists but for a DIFFERENT event.
      when(() => mockHra.getHraScreeningsByMember(any())).thenAnswer(
          (_) async => [_buildHraScreening(eventId: _otherEventId)]);
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => false);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );
      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.hraCompleted, isFalse);
    });
  });

  group('LoadWellnessCompletionStatusUseCase – resilience', () {
    test('returns partial result when a single repo throws (non-fatal)',
        () async {
      // Consent succeeds.
      when(() => mockConsent.getConsentsByMember(any()))
          .thenAnswer((_) async => [_buildConsent(hra: true)]);
      // HRA throws — should default to false.
      when(() => mockHra.getHraScreeningsByMember(any()))
          .thenThrow(Exception('Firestore unavailable'));
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => false);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );

      // Should not throw, should complete gracefully.
      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.consentCompleted, isTrue);
      expect(result.hraCompleted, isFalse); // defaulted to false
    });

    test('returns all-false result when consent repo throws', () async {
      when(() => mockConsent.getConsentsByMember(any()))
          .thenThrow(Exception('network timeout'));
      when(() => mockHra.getHraScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => false);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );

      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.consentCompleted, isFalse);
      expect(result.hraEnabled, isFalse);
    });

    test('propagates consentSancNumber and consentRank from consent record',
        () async {
      final consent = Consent(
        id: 'c-sancnum',
        memberId: _memberId,
        eventId: _eventId,
        venue: 'Venue',
        date: DateTime(2025, 6, 1),
        practitioner: 'Nurse Jones',
        hra: true,
        hct: false,
        tb: false,
        cancer: false,
        sancNumber: 'SANC-999',
        rank: 'Sister',
        createdAt: DateTime(2025, 6, 1),
      );
      when(() => mockConsent.getConsentsByMember(any()))
          .thenAnswer((_) async => [consent]);
      when(() => mockHra.getHraScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockHct.getHctScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockTb.getTbScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockCancer.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockSurvey.hasCompletedSurvey(
            memberId: any(named: 'memberId'),
            eventId: any(named: 'eventId'),
          )).thenAnswer((_) async => false);

      final uc = _buildUseCase(
        consent: mockConsent,
        hra: mockHra,
        hct: mockHct,
        tb: mockTb,
        cancer: mockCancer,
        survey: mockSurvey,
      );
      final result = await uc(memberId: _memberId, eventId: _eventId);

      expect(result.consentSancNumber, 'SANC-999');
      expect(result.consentRank, 'Sister');
    });
  });
}
