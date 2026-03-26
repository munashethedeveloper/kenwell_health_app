import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/domain/usecases/submit_cancer_screening_usecase.dart';
import 'package:kenwell_health_app/ui/features/cancer/view_model/cancer_view_model.dart';

class MockSubmitCancerScreeningUseCase extends Mock
    implements SubmitCancerScreeningUseCase {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockSubmitCancerScreeningUseCase mockUseCase;
  late MockAuthService mockAuthService;
  late CancerScreeningViewModel viewModel;

  setUp(() {
    mockUseCase = MockSubmitCancerScreeningUseCase();
    mockAuthService = MockAuthService();

    when(() => mockAuthService.getCurrentUser())
        .thenAnswer((_) async => null);

    registerFallbackValue(
      CancerScreening(
        id: 'cs-1',
        memberId: 'm-1',
        eventId: 'e-1',
        chronicConditions: const {},
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ),
    );

    viewModel = CancerScreeningViewModel(
      submitCancerScreeningUseCase: mockUseCase,
      authService: mockAuthService,
    );
  });

  tearDown(() => viewModel.dispose());

  group('CancerScreeningViewModel – initial state', () {
    test('cancer sub-types empty (show all)', () {
      expect(viewModel.showBreastScreening, isTrue);
      expect(viewModel.showPapSmear, isTrue);
      expect(viewModel.showPsa, isTrue);
      expect(viewModel.hasSpecificSubTypes, isFalse);
    });

    test('previousCancerDiagnosis is null',
        () => expect(viewModel.previousCancerDiagnosis, isNull));
    test('familyHistoryOfCancer is null',
        () => expect(viewModel.familyHistoryOfCancer, isNull));
  });

  group('CancerScreeningViewModel – setCancerSubTypes', () {
    test('restricts visible sections to configured sub-types', () {
      viewModel.setCancerSubTypes({'Breast Screening'});

      expect(viewModel.showBreastScreening, isTrue);
      expect(viewModel.showPapSmear, isFalse);
      expect(viewModel.showPsa, isFalse);
      expect(viewModel.hasSpecificSubTypes, isTrue);
    });

    test('shows all sections when types are cleared', () {
      viewModel.setCancerSubTypes({'Breast Screening'});
      viewModel.setCancerSubTypes({});

      expect(viewModel.showBreastScreening, isTrue);
      expect(viewModel.showPapSmear, isTrue);
      expect(viewModel.showPsa, isTrue);
    });
  });

  group('CancerScreeningViewModel – setters', () {
    test('setPreviousCancerDiagnosis updates value and notifies', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setPreviousCancerDiagnosis('Yes');

      expect(viewModel.previousCancerDiagnosis, 'Yes');
      expect(notified, isTrue);
    });

    test('setPreviousCancerDiagnosis does not notify for same value', () {
      viewModel.setPreviousCancerDiagnosis('No');
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setPreviousCancerDiagnosis('No');

      expect(notified, isFalse);
    });

    test('setFamilyHistoryOfCancer updates value', () {
      viewModel.setFamilyHistoryOfCancer('Yes');
      expect(viewModel.familyHistoryOfCancer, 'Yes');
    });
  });

  group('CancerScreeningViewModel – setMemberAndEventId', () {
    test('stores ids without error', () {
      expect(() => viewModel.setMemberAndEventId('m-1', 'e-1'),
          returnsNormally);
    });
  });

  group('CancerScreeningViewModel – initialize', () {
    test('does not throw when getCurrentUser returns null', () async {
      when(() => mockAuthService.getCurrentUser())
          .thenAnswer((_) async => null);
      await expectLater(viewModel.initialize(), completes);
    });
  });
}
