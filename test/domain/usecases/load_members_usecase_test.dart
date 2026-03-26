import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/usecases/load_members_usecase.dart';

class MockFirestoreMemberRepository extends Mock
    implements FirestoreMemberRepository {}

Member _buildMember(String id) => Member(
      id: id,
      name: 'Jane',
      surname: 'Smith',
      idDocumentType: 'ID',
      idNumber: '9501015009087',
    );

void main() {
  late MockFirestoreMemberRepository mockRepo;
  late LoadMembersUseCase useCase;

  setUp(() {
    mockRepo = MockFirestoreMemberRepository();
    useCase = LoadMembersUseCase(repository: mockRepo);
  });

  group('LoadMembersUseCase', () {
    test('returns the list returned by the repository', () async {
      final members = [_buildMember('m1'), _buildMember('m2')];
      when(() => mockRepo.fetchAllMembers()).thenAnswer((_) async => members);

      final result = await useCase();

      expect(result, equals(members));
      verify(() => mockRepo.fetchAllMembers()).called(1);
    });

    test('returns empty list when no members exist', () async {
      when(() => mockRepo.fetchAllMembers()).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('propagates repository exception to caller', () async {
      when(() => mockRepo.fetchAllMembers())
          .thenThrow(Exception('Firestore unavailable'));

      expect(() => useCase(), throwsException);
    });
  });
}
