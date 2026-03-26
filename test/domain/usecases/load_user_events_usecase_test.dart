import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/event_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/user_event_repository.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/domain/usecases/load_user_events_usecase.dart';

class MockUserEventRepository extends Mock implements UserEventRepository {}

class MockEventRepository extends Mock implements EventRepository {}

WellnessEvent _buildEvent(String id) => WellnessEvent(
      title: 'Event $id',
      date: DateTime(2025, 6, 1),
      venue: 'Hall A',
      address: '1 Main St',
      townCity: 'Cape Town',
      province: 'Western Cape',
      onsiteContactFirstName: 'Alice',
      onsiteContactLastName: 'Smith',
      onsiteContactNumber: '0821234567',
      onsiteContactEmail: 'alice@example.com',
      aeContactFirstName: 'Bob',
      aeContactLastName: 'Jones',
      aeContactNumber: '0831234567',
      aeContactEmail: 'bob@example.com',
      servicesRequested: [],
      expectedParticipation: '50',
      nurses: [],
      setUpTime: '07:00',
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: '2',
      medicalAid: 'None',
    );

void main() {
  late MockUserEventRepository mockUserEventRepo;
  late MockEventRepository mockEventRepo;
  late LoadUserEventsUseCase useCase;

  setUp(() {
    mockUserEventRepo = MockUserEventRepository();
    mockEventRepo = MockEventRepository();
    useCase = LoadUserEventsUseCase(
      userEventRepository: mockUserEventRepo,
      eventRepository: mockEventRepo,
    );
    registerFallbackValue('');
  });

  group('LoadUserEventsUseCase.call', () {
    test('resolves event IDs to WellnessEvent objects', () async {
      final event = _buildEvent('e1');
      when(() => mockUserEventRepo.fetchUserEvents('user-1'))
          .thenAnswer((_) async => [
                {'eventId': 'e1'},
              ]);
      when(() => mockEventRepo.fetchEventById('e1'))
          .thenAnswer((_) async => event);

      final result = await useCase('user-1');

      expect(result, [event]);
      verify(() => mockUserEventRepo.fetchUserEvents('user-1')).called(1);
      verify(() => mockEventRepo.fetchEventById('e1')).called(1);
    });

    test('returns empty list when user has no events', () async {
      when(() => mockUserEventRepo.fetchUserEvents('user-1'))
          .thenAnswer((_) async => []);

      final result = await useCase('user-1');

      expect(result, isEmpty);
      verifyNever(() => mockEventRepo.fetchEventById(any()));
    });

    test('skips null eventId entries', () async {
      final event = _buildEvent('e2');
      when(() => mockUserEventRepo.fetchUserEvents('user-1'))
          .thenAnswer((_) async => [
                {'eventId': null},
                {'eventId': 'e2'},
              ]);
      when(() => mockEventRepo.fetchEventById('e2'))
          .thenAnswer((_) async => event);

      final result = await useCase('user-1');

      expect(result, [event]);
    });

    test('skips events that fail to resolve', () async {
      when(() => mockUserEventRepo.fetchUserEvents('user-1'))
          .thenAnswer((_) async => [
                {'eventId': 'missing'},
              ]);
      when(() => mockEventRepo.fetchEventById('missing'))
          .thenThrow(Exception('not found'));

      final result = await useCase('user-1');

      expect(result, isEmpty);
    });

    test('skips events that resolve to null', () async {
      when(() => mockUserEventRepo.fetchUserEvents('user-1'))
          .thenAnswer((_) async => [
                {'eventId': 'ghost'},
              ]);
      when(() => mockEventRepo.fetchEventById('ghost'))
          .thenAnswer((_) async => null);

      final result = await useCase('user-1');

      expect(result, isEmpty);
    });
  });
}
