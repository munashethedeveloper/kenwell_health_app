import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_cancer_screening_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hra_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_tb_screening_repository.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/domain/usecases/load_member_event_referrals_usecase.dart';

class MockFirestoreMemberRepository extends Mock
    implements FirestoreMemberRepository {}

class MockFirestoreTbScreeningRepository extends Mock
    implements FirestoreTbScreeningRepository {}

class MockFirestoreCancerScreeningRepository extends Mock
    implements FirestoreCancerScreeningRepository {}

class MockFirestoreHraRepository extends Mock
    implements FirestoreHraRepository {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Member _buildMember() => Member(
      id: 'member-1',
      name: 'Alice',
      surname: 'Nkosi',
      idDocumentType: 'ID',
      idNumber: '9501015009087',
    );

final _now = DateTime.now();

TbScreening _buildTbScreening({
  String eventId = 'e1',
  String? nursingReferral,
  String? coughTwoWeeks,
}) =>
    TbScreening(
      id: 'tb-1',
      memberId: 'member-1',
      eventId: eventId,
      nursingReferral: nursingReferral,
      coughTwoWeeks: coughTwoWeeks,
      nurseFirstName: 'Nurse',
      nurseLastName: 'One',
      rank: 'RN',
      sancNumber: '123',
      nurseDate: _now.toIso8601String(),
      createdAt: _now,
      updatedAt: _now,
    );

CancerScreening _buildCancerScreening({
  String eventId = 'e1',
  String? nursingReferral,
}) =>
    CancerScreening(
      id: 'c-1',
      memberId: 'member-1',
      eventId: eventId,
      nursingReferral: nursingReferral,
      createdAt: _now,
      updatedAt: _now,
    );

HraScreening _buildHraScreening({
  String? eventId = 'e1',
  String? bmi,
  String? bloodPressureSystolic,
  String? bloodSugar,
  String? cholesterol,
}) =>
    HraScreening(
      id: 'hra-1',
      memberId: 'member-1',
      eventId: eventId,
      bmi: bmi,
      bloodPressureSystolic: bloodPressureSystolic,
      bloodSugar: bloodSugar,
      cholesterol: cholesterol,
      chronicConditions: {},
    );

// ── Test suite ───────────────────────────────────────────────────────────────

void main() {
  late MockFirestoreMemberRepository mockMemberRepo;
  late MockFirestoreTbScreeningRepository mockTbRepo;
  late MockFirestoreCancerScreeningRepository mockCancerRepo;
  late MockFirestoreHraRepository mockHraRepo;
  late LoadMemberEventReferralsUseCase useCase;

  final member = _buildMember();

  setUp(() {
    mockMemberRepo = MockFirestoreMemberRepository();
    mockTbRepo = MockFirestoreTbScreeningRepository();
    mockCancerRepo = MockFirestoreCancerScreeningRepository();
    mockHraRepo = MockFirestoreHraRepository();

    useCase = LoadMemberEventReferralsUseCase(
      memberRepository: mockMemberRepo,
      tbRepository: mockTbRepo,
      cancerRepository: mockCancerRepo,
      hraRepository: mockHraRepo,
    );

    registerFallbackValue(member);
  });

  void stubScreenings({
    List<TbScreening> tb = const [],
    List<CancerScreening> cancer = const [],
    List<HraScreening> hra = const [],
  }) {
    when(() => mockTbRepo.getTbScreeningsByMember(any()))
        .thenAnswer((_) async => tb);
    when(() => mockCancerRepo.getCancerScreeningsByMember(any()))
        .thenAnswer((_) async => cancer);
    when(() => mockHraRepo.getHraScreeningsByMember(any()))
        .thenAnswer((_) async => hra);
  }

  group('LoadMemberEventReferralsUseCase', () {
    test('returns empty referral map when no events exist', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => []);
      stubScreenings();

      final result = await useCase(member);

      expect(result.events, isEmpty);
      expect(result.referralSummaries, isEmpty);
    });

    test('produces healthy outcome when no screening data exists for event',
        () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      stubScreenings(); // no screening data

      final result = await useCase(member);

      // hasAnyData is false → status is null
      expect(result.referralSummaries['e1']?.status, isNull);
    });

    test('produces healthy when all screenings show no referral', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      stubScreenings(
        tb: [_buildTbScreening(nursingReferral: 'patientNotReferred')],
        cancer: [
          _buildCancerScreening(nursingReferral: 'patientNotReferred')
        ],
      );

      final result = await useCase(member);

      expect(result.referralSummaries['e1']?.isHealthy, isTrue);
    });

    test('produces at_risk when TB nursingReferral is referredToStateClinic',
        () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      stubScreenings(
        tb: [
          _buildTbScreening(
            nursingReferral: 'referredToStateClinic',
            coughTwoWeeks: 'yes',
          )
        ],
      );

      final result = await useCase(member);

      final summary = result.referralSummaries['e1']!;
      expect(summary.isHighRisk, isTrue);
      expect(summary.riskFlags, contains(contains('TB')));
      expect(summary.riskFlags.first, contains('Cough'));
    });

    test('produces at_risk when Cancer is referred', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      stubScreenings(
        cancer: [
          _buildCancerScreening(nursingReferral: 'referredToStateClinic')
        ],
      );

      final result = await useCase(member);

      expect(result.referralSummaries['e1']?.isHighRisk, isTrue);
    });

    test('produces at_risk when HRA shows high blood pressure', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      stubScreenings(
        hra: [
          _buildHraScreening(bloodPressureSystolic: '145'),
        ],
      );

      final result = await useCase(member);

      final summary = result.referralSummaries['e1']!;
      expect(summary.isHighRisk, isTrue);
      expect(
          summary.riskFlags.first, contains('High blood pressure'));
    });

    test('produces at_risk when HRA shows obese BMI', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      stubScreenings(
        hra: [_buildHraScreening(bmi: '32.0')],
      );

      final result = await useCase(member);

      expect(result.referralSummaries['e1']?.isHighRisk, isTrue);
    });

    test('handles multiple events independently', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
                {'eventId': 'e2'},
              ]);
      stubScreenings(
        tb: [
          _buildTbScreening(
              eventId: 'e1',
              nursingReferral: 'referredToStateClinic'),
        ],
        cancer: [
          _buildCancerScreening(
              eventId: 'e2', nursingReferral: 'patientNotReferred'),
        ],
      );

      final result = await useCase(member);

      expect(result.referralSummaries['e1']?.isHighRisk, isTrue);
      expect(result.referralSummaries['e2']?.isHealthy, isTrue);
    });

    test('skips events with null or empty eventId', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': null},
                {'eventId': ''},
              ]);
      stubScreenings();

      final result = await useCase(member);

      expect(result.referralSummaries, isEmpty);
    });

    test('screening errors are swallowed via catchError', () async {
      when(() => mockMemberRepo.fetchMemberEvents(any()))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      when(() => mockTbRepo.getTbScreeningsByMember(any()))
          .thenThrow(Exception('TB fetch failed'));
      when(() => mockCancerRepo.getCancerScreeningsByMember(any()))
          .thenAnswer((_) async => []);
      when(() => mockHraRepo.getHraScreeningsByMember(any()))
          .thenAnswer((_) async => []);

      // Should not throw
      final result = await useCase(member);

      // No data → status null
      expect(result.referralSummaries['e1']?.status, isNull);
    });
  });
}
