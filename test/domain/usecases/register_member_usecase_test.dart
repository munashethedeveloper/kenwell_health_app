import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_event_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/member_repository.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/models/member_event.dart';
import 'package:kenwell_health_app/domain/usecases/register_member_usecase.dart';

// ── Fakes & mocks ────────────────────────────────────────────────────────────

class MockMemberRepository extends Mock implements MemberRepository {}

class MockFirestoreMemberRepository extends Mock
    implements FirestoreMemberRepository {}

class MockFirestoreMemberEventRepository extends Mock
    implements FirestoreMemberEventRepository {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Member _buildMember({String id = 'member-1'}) => Member(
      id: id,
      name: 'John',
      surname: 'Doe',
      idDocumentType: 'ID',
      idNumber: '9001015009087',
    );

void main() {
  late MockMemberRepository mockLocalRepo;
  late MockFirestoreMemberRepository mockFirestoreRepo;
  late MockFirestoreMemberEventRepository mockMemberEventRepo;
  late RegisterMemberUseCase useCase;

  setUp(() {
    mockLocalRepo = MockMemberRepository();
    mockFirestoreRepo = MockFirestoreMemberRepository();
    mockMemberEventRepo = MockFirestoreMemberEventRepository();

    useCase = RegisterMemberUseCase(
      memberRepository: mockLocalRepo,
      firestoreMemberRepository: mockFirestoreRepo,
      memberEventRepository: mockMemberEventRepo,
    );

    // Register fallback values required by mocktail for non-primitive types.
    registerFallbackValue(_buildMember());
    registerFallbackValue(
      MemberEvent(memberId: 'x', eventId: 'y', eventTitle: 'T'),
    );
  });

  group('RegisterMemberUseCase', () {
    test('returns saved member when all three writes succeed', () async {
      final member = _buildMember();
      when(() => mockLocalRepo.createMember(any()))
          .thenAnswer((_) async => member);
      when(() => mockFirestoreRepo.addMember(any())).thenAnswer((_) async {});
      when(() => mockMemberEventRepo.addMemberEvent(any()))
          .thenAnswer((_) async {});

      final result = await useCase(
        member,
        eventId: 'event-1',
        eventTitle: 'Health Day',
        eventDate: DateTime(2025, 6, 1),
      );

      expect(result.id, member.id);
      verify(() => mockLocalRepo.createMember(any())).called(1);
      verify(() => mockFirestoreRepo.addMember(any())).called(1);
      verify(() => mockMemberEventRepo.addMemberEvent(any())).called(1);
    });

    test('still returns member when Firestore member write fails (non-fatal)',
        () async {
      final member = _buildMember(id: 'member-2');
      when(() => mockLocalRepo.createMember(any()))
          .thenAnswer((_) async => member);
      when(() => mockFirestoreRepo.addMember(any()))
          .thenThrow(Exception('Firestore unavailable'));
      when(() => mockMemberEventRepo.addMemberEvent(any()))
          .thenAnswer((_) async {});

      final result = await useCase(member, eventId: 'event-1');

      expect(result.id, member.id);
      verify(() => mockLocalRepo.createMember(any())).called(1);
    });

    test(
        'still returns member when Firestore member_events write fails (non-fatal)',
        () async {
      final member = _buildMember(id: 'member-3');
      when(() => mockLocalRepo.createMember(any()))
          .thenAnswer((_) async => member);
      when(() => mockFirestoreRepo.addMember(any())).thenAnswer((_) async {});
      when(() => mockMemberEventRepo.addMemberEvent(any()))
          .thenThrow(Exception('timeout'));

      final result = await useCase(member, eventId: 'event-1');

      expect(result.id, member.id);
    });

    test('propagates exception when local SQLite write fails (fatal)',
        () async {
      final member = _buildMember(id: 'member-4');
      when(() => mockLocalRepo.createMember(any()))
          .thenThrow(Exception('disk full'));

      expect(() => useCase(member), throwsException);
    });

    test('skips member_events write when no eventId provided', () async {
      final member = _buildMember(id: 'member-5');
      when(() => mockLocalRepo.createMember(any()))
          .thenAnswer((_) async => member);
      when(() => mockFirestoreRepo.addMember(any())).thenAnswer((_) async {});

      await useCase(member); // no eventId

      verifyNever(() => mockMemberEventRepo.addMemberEvent(any()));
    });
  });
}
