import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_hct_result_repository.dart';
import 'package:kenwell_health_app/domain/models/hct_result.dart';
import 'package:kenwell_health_app/domain/usecases/submit_hct_test_result_usecase.dart';

class MockFirestoreHctResultRepository extends Mock
    implements FirestoreHctResultRepository {}

HctResult _buildResult({String id = 'result-1'}) => HctResult(
      id: id,
      memberId: 'member-1',
      eventId: 'event-1',
      screeningResult: 'Negative',
    );

void main() {
  late MockFirestoreHctResultRepository mockRepo;
  late SubmitHCTTestResultUseCase useCase;

  setUp(() {
    mockRepo = MockFirestoreHctResultRepository();
    useCase = SubmitHCTTestResultUseCase(repository: mockRepo);
    registerFallbackValue(_buildResult());
  });

  group('SubmitHCTTestResultUseCase', () {
    test('calls addHctResult with the provided result', () async {
      final result = _buildResult();
      when(() => mockRepo.addHctResult(any())).thenAnswer((_) async {});

      await useCase(result);

      verify(() => mockRepo.addHctResult(result)).called(1);
    });

    test('propagates repository exception to caller', () async {
      when(() => mockRepo.addHctResult(any()))
          .thenThrow(Exception('write failed'));

      expect(() => useCase(_buildResult()), throwsException);
    });
  });
}
