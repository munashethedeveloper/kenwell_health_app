import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/usecases/submit_survey_usecase.dart';
import 'package:kenwell_health_app/ui/features/survey/view_model/survey_view_model.dart';

class MockSubmitSurveyUseCase extends Mock implements SubmitSurveyUseCase {}

void main() {
  late MockSubmitSurveyUseCase mockUseCase;
  late SurveyViewModel viewModel;

  setUp(() {
    mockUseCase = MockSubmitSurveyUseCase();
    viewModel = SurveyViewModel(submitSurveyUseCase: mockUseCase);
  });

  tearDown(() => viewModel.dispose());

  group('SurveyViewModel – initial state', () {
    test('heardAbout is null', () => expect(viewModel.heardAbout, isNull));
    test('province is null', () => expect(viewModel.province, isNull));
    test('contactConsent is null',
        () => expect(viewModel.contactConsent, isNull));
    test('all ratings default to -1', () {
      expect(viewModel.ratings['overallExperience'], -1);
      expect(viewModel.ratings['friendlyStaff'], -1);
    });
    test('isFormValid is false', () => expect(viewModel.isFormValid, isFalse));
  });

  group('SurveyViewModel – update methods', () {
    test('updateHeardAbout sets heardAbout and notifies', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.updateHeardAbout('Intranet');

      expect(viewModel.heardAbout, 'Intranet');
      expect(notified, isTrue);
    });

    test('updateProvince sets province', () {
      viewModel.updateProvince('Gauteng');
      expect(viewModel.province, 'Gauteng');
    });

    test('updateContactConsent sets consent', () {
      viewModel.updateContactConsent('Yes');
      expect(viewModel.contactConsent, 'Yes');
    });

    test('updateRating sets specific rating', () {
      viewModel.updateRating('overallExperience', 5);
      expect(viewModel.ratings['overallExperience'], 5);
    });
  });

  group('SurveyViewModel – isFormValid', () {
    void _fillAllFields() {
      viewModel.updateHeardAbout('Flyer');
      viewModel.updateProvince('Gauteng');
      viewModel.updateContactConsent('Yes');
      for (final key in viewModel.ratings.keys) {
        viewModel.updateRating(key, 4);
      }
    }

    test('returns true when all fields are filled', () {
      _fillAllFields();
      expect(viewModel.isFormValid, isTrue);
    });

    test('returns false when heardAbout is null', () {
      _fillAllFields();
      viewModel.updateHeardAbout(''); // reset to empty (not null)
      // Actually set directly:
      viewModel.heardAbout = null;
      expect(viewModel.isFormValid, isFalse);
    });

    test('returns false when a rating is still -1', () {
      viewModel.updateHeardAbout('Flyer');
      viewModel.updateProvince('Gauteng');
      viewModel.updateContactConsent('Yes');
      // Leave one rating at -1
      viewModel.updateRating('overallExperience', 5);
      expect(viewModel.isFormValid, isFalse);
    });
  });

  group('SurveyViewModel – submitSurvey', () {
    test('calls onValidationFailed when form is invalid', () async {
      String? failMsg;
      await viewModel.submitSurvey(
        onNext: () {},
        onValidationFailed: (msg) => failMsg = msg,
      );
      expect(failMsg, isNotNull);
      verifyNever(() => mockUseCase(
            id: any(named: 'id'),
            data: any(named: 'data'),
          ));
    });

    test('calls onError when member/event ids are not set', () async {
      // Fill form but do not set memberId/eventId
      viewModel.updateHeardAbout('Flyer');
      viewModel.updateProvince('Gauteng');
      viewModel.updateContactConsent('Yes');
      for (final key in viewModel.ratings.keys) {
        viewModel.updateRating(key, 3);
      }

      String? errorMsg;
      await viewModel.submitSurvey(
        onNext: () {},
        onError: (msg) => errorMsg = msg,
      );

      expect(errorMsg, isNotNull);
    });

    test('calls use case and onNext on success', () async {
      viewModel.setMemberAndEventId('m-1', 'e-1');
      viewModel.updateHeardAbout('Email');
      viewModel.updateProvince('Western Cape');
      viewModel.updateContactConsent('No');
      for (final key in viewModel.ratings.keys) {
        viewModel.updateRating(key, 4);
      }
      when(() => mockUseCase(
                id: any(named: 'id'),
                data: any(named: 'data'),
              ))
          .thenAnswer((_) async {});

      var nextCalled = false;
      await viewModel.submitSurvey(onNext: () => nextCalled = true);

      expect(nextCalled, isTrue);
      verify(() => mockUseCase(
            id: any(named: 'id'),
            data: any(named: 'data'),
          )).called(1);
    });
  });
}
