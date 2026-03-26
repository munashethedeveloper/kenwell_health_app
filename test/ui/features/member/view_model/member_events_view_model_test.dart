import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/usecases/load_member_event_referrals_usecase.dart';
import 'package:kenwell_health_app/ui/features/member/view_model/member_events_view_model.dart';

class MockLoadMemberEventReferralsUseCase extends Mock
    implements LoadMemberEventReferralsUseCase {}

Member _member() => Member(
      id: 'm-1',
      name: 'Alice',
      surname: 'Smith',
      idDocumentType: 'ID',
      idNumber: '9001011234567',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

void main() {
  late MockLoadMemberEventReferralsUseCase mockUseCase;
  late MemberEventsViewModel viewModel;

  setUp(() {
    mockUseCase = MockLoadMemberEventReferralsUseCase();
    viewModel = MemberEventsViewModel(
      member: _member(),
      loadMemberEventReferralsUseCase: mockUseCase,
    );
  });

  tearDown(() => viewModel.dispose());

  group('MemberEventsViewModel – initial state', () {
    test('isLoading is true initially', () {
      expect(viewModel.isLoading, isTrue);
    });

    test('events list is empty initially', () {
      expect(viewModel.events, isEmpty);
    });

    test('errorMessage is null initially', () {
      expect(viewModel.errorMessage, isNull);
    });
  });

  group('MemberEventsViewModel – loadMemberEvents', () {
    test('populates events list on success', () async {
      final events = [
        {'eventId': 'e-1', 'date': '2025-06-01'},
        {'eventId': 'e-2', 'date': '2025-07-01'},
      ];
      when(() => mockUseCase(any())).thenAnswer(
        (_) async => MemberEventReferrals(
          events: events,
          referralSummaries: const {},
        ),
      );

      await viewModel.loadMemberEvents();

      expect(viewModel.events.length, 2);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('sets errorMessage when use case throws', () async {
      when(() => mockUseCase(any())).thenThrow(Exception('network error'));

      await viewModel.loadMemberEvents();

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('populates referral summaries', () async {
      final summary = const EventReferralSummary(status: 'at_risk');
      when(() => mockUseCase(any())).thenAnswer(
        (_) async => MemberEventReferrals(
          events: [
            {'eventId': 'e-1'}
          ],
          referralSummaries: {'e-1': summary},
        ),
      );

      await viewModel.loadMemberEvents();

      expect(viewModel.referralFor('e-1')?.isHighRisk, isTrue);
      expect(viewModel.referralFor('e-99'), isNull);
    });
  });

  group('MemberEventsViewModel – formatDate', () {
    test('formats DateTime correctly', () {
      final result = viewModel.formatDate(DateTime(2025, 6, 15));
      expect(result, '15 Jun 2025');
    });

    test('handles null gracefully', () {
      expect(viewModel.formatDate(null), 'Date not available');
    });

    test('handles ISO string', () {
      final result = viewModel.formatDate('2025-06-15');
      expect(result, contains('2025'));
    });

    test('handles invalid type', () {
      expect(viewModel.formatDate(42), 'Invalid date');
    });
  });
}
