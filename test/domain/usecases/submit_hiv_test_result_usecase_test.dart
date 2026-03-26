import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hiv_result_repository.dart';
import 'package:kenwell_health_app/domain/models/hiv_result.dart';
import 'package:kenwell_health_app/domain/usecases/submit_hiv_test_result_usecase.dart';

class MockFirestoreHivResultRepository extends Mock
    implements FirestoreHivResultRepository {}

HivResult _buildResult({String id = 'result-1'}) => HivResult(
      id: id,
      memberId: 'member-1',
      eventId: 'event-1',
      screeningResult: 'Negative',
    );

void main() {
  late MockFirestoreHivResultRepository mockRepo;
  late SubmitHIVTestResultUseCase useCase;

  setUp(() {
    mockRepo = MockFirestoreHivResultRepository();
    useCase = SubmitHIVTestResultUseCase(repository: mockRepo);
    registerFallbackValue(_buildResult());
  });

  group('SubmitHIVTestResultUseCase', () {
    test('calls addHivResult with the provided result', () async {
      final result = _buildResult();
      when(() => mockRepo.addHivResult(any())).thenAnswer((_) async {});

      await useCase(result);

      verify(() => mockRepo.addHivResult(result)).called(1);
    });

    test('propagates repository exception to caller', () async {
      when(() => mockRepo.addHivResult(any()))
          .thenThrow(Exception('write failed'));

      expect(() => useCase(_buildResult()), throwsException);
    });
  });
}
