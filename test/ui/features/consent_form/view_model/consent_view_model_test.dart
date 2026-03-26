import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/models/consent.dart';
import 'package:kenwell_health_app/domain/usecases/submit_consent_usecase.dart';
import 'package:kenwell_health_app/ui/features/consent_form/view_model/consent_view_model.dart';

class MockSubmitConsentUseCase extends Mock implements SubmitConsentUseCase {}

void main() {
  late MockSubmitConsentUseCase mockUseCase;
  late ConsentScreenViewModel viewModel;

  setUp(() {
    mockUseCase = MockSubmitConsentUseCase();
    viewModel = ConsentScreenViewModel(submitConsentUseCase: mockUseCase);
    registerFallbackValue(
      Consent(
        id: 'c-1',
        memberId: 'm-1',
        eventId: 'e-1',
        venue: 'Hall',
        date: DateTime(2025, 6, 1),
        practitioner: 'Nurse A',
        hra: false,
        hct: true,
        tb: false,
        createdAt: DateTime(2025, 6, 1),
      ),
    );
  });

  tearDown(() => viewModel.dispose());

  group('ConsentScreenViewModel – initial state', () {
    test('isSubmitting is false',
        () => expect(viewModel.isSubmitting, isFalse));
    test('no checkbox is checked', () {
      expect(viewModel.hra, isFalse);
      expect(viewModel.hct, isFalse);
      expect(viewModel.tb, isFalse);
      expect(viewModel.cancer, isFalse);
    });
    test('hasAtLeastOneScreening is false',
        () => expect(viewModel.hasAtLeastOneScreening, isFalse));
    test('selectedScreenings is empty',
        () => expect(viewModel.selectedScreenings, isEmpty));
  });

  group('ConsentScreenViewModel – checkbox state', () {
    test('selecting hra adds it to selectedScreenings', () {
      viewModel.hra = true;
      expect(viewModel.selectedScreenings, contains('hra'));
    });

    test('selecting multiple adds all to selectedScreenings', () {
      viewModel.hra = true;
      viewModel.hct = true;
      viewModel.tb = true;

      expect(viewModel.selectedScreenings,
          containsAll(['hra', 'hct', 'tb']));
      expect(viewModel.selectedScreenings, isNot(contains('cancer')));
    });

    test('hasAtLeastOneScreening is true when any checkbox is selected', () {
      viewModel.cancer = true;
      expect(viewModel.hasAtLeastOneScreening, isTrue);
    });
  });

  group('ConsentScreenViewModel – setRank', () {
    test('updates rankController text', () {
      viewModel.setRank('Professional Nurse');
      expect(viewModel.rankController.text, 'Professional Nurse');
    });

    test('handles null value by setting empty string', () {
      viewModel.setRank(null);
      expect(viewModel.rankController.text, isEmpty);
    });

    test('does not notify when value is unchanged', () {
      viewModel.setRank('Nurse');
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setRank('Nurse');

      expect(notified, isFalse);
    });
  });

  group('ConsentScreenViewModel – isFormValid', () {
    test('returns false when no checkbox selected', () {
      viewModel.venueController.text = 'Hall';
      viewModel.dateController.text = '2025-06-01';
      viewModel.practitionerController.text = 'Nurse A';
      expect(viewModel.isFormValid, isFalse);
    });
  });

  group('ConsentScreenViewModel – initialise', () {
    test('event is null before initialise is called', () {
      expect(viewModel.event, isNull);
    });
  });
}
