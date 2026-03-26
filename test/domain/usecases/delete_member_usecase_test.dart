import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/member_repository.dart';
import 'package:kenwell_health_app/domain/usecases/delete_member_usecase.dart';

class MockFirestoreMemberRepository extends Mock
    implements FirestoreMemberRepository {}

class MockMemberRepository extends Mock implements MemberRepository {}

void main() {
  late MockFirestoreMemberRepository mockFirestore;
  late MockMemberRepository mockLocal;
  late DeleteMemberUseCase useCase;

  setUp(() {
    mockFirestore = MockFirestoreMemberRepository();
    mockLocal = MockMemberRepository();
    useCase = DeleteMemberUseCase(
      firestoreRepository: mockFirestore,
      localRepository: mockLocal,
    );
  });

  group('DeleteMemberUseCase', () {
    test('deletes from Firestore then local when both succeed', () async {
      when(() => mockFirestore.deleteMember(any()))
          .thenAnswer((_) async {});
      when(() => mockLocal.deleteMember(any())).thenAnswer((_) async {});

      await useCase('member-1');

      verify(() => mockFirestore.deleteMember('member-1')).called(1);
      verify(() => mockLocal.deleteMember('member-1')).called(1);
    });

    test('propagates exception when Firestore delete fails', () async {
      when(() => mockFirestore.deleteMember(any()))
          .thenThrow(Exception('network error'));
      when(() => mockLocal.deleteMember(any())).thenAnswer((_) async {});

      expect(() => useCase('member-1'), throwsException);
      verifyNever(() => mockLocal.deleteMember(any()));
    });

    test('propagates exception when local delete fails', () async {
      when(() => mockFirestore.deleteMember(any()))
          .thenAnswer((_) async {});
      when(() => mockLocal.deleteMember(any()))
          .thenThrow(Exception('db error'));

      expect(() => useCase('member-1'), throwsException);
    });
  });
}
