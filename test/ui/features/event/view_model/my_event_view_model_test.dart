import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/event_repository.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/domain/usecases/get_events_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/load_user_events_usecase.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_view_model.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/my_event_view_model.dart';

class MockAuthService extends Mock implements AuthService {}

class MockLoadUserEventsUseCase extends Mock
    implements LoadUserEventsUseCase {}

class MockEventRepository extends Mock implements EventRepository {}

class MockGetEventsUseCase extends Mock implements GetEventsUseCase {}

WellnessEvent _buildEvent({
  String id = 'ev-1',
  String status = 'scheduled',
  DateTime? date,
  String startTime = '08:00',
}) =>
    WellnessEvent(
      id: id,
      title: 'Health Day',
      date: date ?? DateTime.now(),
      venue: 'Hall',
      address: '1 Road',
      townCity: 'City',
      province: 'Gauteng',
      onsiteContactFirstName: 'A',
      onsiteContactLastName: 'B',
      onsiteContactNumber: '000',
      onsiteContactEmail: 'a@b.com',
      aeContactFirstName: 'C',
      aeContactLastName: 'D',
      aeContactNumber: '000',
      aeContactEmail: 'c@d.com',
      servicesRequested: 'HRA',
      expectedParticipation: 50,
      nurses: 2,
      setUpTime: '07:00',
      startTime: startTime,
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'None',
      status: status,
    );

UserModel _user() => UserModel(
      id: 'u-1',
      email: 'nurse@ex.com',
      role: 'nurse',
      phoneNumber: '0821234567',
      firstName: 'Alice',
      lastName: 'Smith',
      emailVerified: true,
    );

void main() {
  late MockAuthService mockAuthService;
  late MockLoadUserEventsUseCase mockLoadUseCase;
  late EventViewModel eventViewModel;

  setUp(() {
    mockAuthService = MockAuthService();
    mockLoadUseCase = MockLoadUserEventsUseCase();

    final mockRepo = MockEventRepository();
    final mockGetUC = MockGetEventsUseCase();
    when(() => mockGetUC()).thenAnswer((_) async => []);
    when(() => mockRepo.watchAllEvents()).thenAnswer((_) => const Stream.empty());

    eventViewModel = EventViewModel(
      repository: mockRepo,
      getEventsUseCase: mockGetUC,
    );

    registerFallbackValue(_buildEvent());
  });

  tearDown(() => eventViewModel.dispose());

  group('MyEventViewModel – initial state', () {
    test('userEvents is empty initially', () {
      final vm = MyEventViewModel(
        eventViewModel: eventViewModel,
        authService: mockAuthService,
        loadUserEventsUseCase: mockLoadUseCase,
      );
      expect(vm.userEvents, isEmpty);
      expect(vm.startingEventId, isNull);
      vm.dispose();
    });
  });

  group('MyEventViewModel – loadUserEvents', () {
    test('populates userEvents when user is authenticated', () async {
      when(() => mockAuthService.getCurrentUser())
          .thenAnswer((_) async => _user());
      final events = [_buildEvent(id: 'e-1'), _buildEvent(id: 'e-2')];
      when(() => mockLoadUseCase(any())).thenAnswer((_) async => events);
      when(() => mockLoadUseCase.watch(any()))
          .thenAnswer((_) => const Stream.empty());

      final vm = MyEventViewModel(
        eventViewModel: eventViewModel,
        authService: mockAuthService,
        loadUserEventsUseCase: mockLoadUseCase,
      );

      await vm.loadUserEvents();

      expect(vm.userEvents.length, 2);
      vm.dispose();
    });

    test('leaves userEvents empty when user is null', () async {
      when(() => mockAuthService.getCurrentUser())
          .thenAnswer((_) async => null);

      final vm = MyEventViewModel(
        eventViewModel: eventViewModel,
        authService: mockAuthService,
        loadUserEventsUseCase: mockLoadUseCase,
      );

      await vm.loadUserEvents();

      expect(vm.userEvents, isEmpty);
      vm.dispose();
    });
  });

  group('MyEventViewModel – canStartEvent', () {
    test('returns true for in_progress event', () {
      final vm = MyEventViewModel(
        eventViewModel: eventViewModel,
        authService: mockAuthService,
        loadUserEventsUseCase: mockLoadUseCase,
      );

      final event = _buildEvent(status: 'in_progress');
      expect(vm.canStartEvent(event), isTrue);
      vm.dispose();
    });

    test('returns false for completed event', () {
      final vm = MyEventViewModel(
        eventViewModel: eventViewModel,
        authService: mockAuthService,
        loadUserEventsUseCase: mockLoadUseCase,
      );

      final event = _buildEvent(status: 'completed');
      expect(vm.canStartEvent(event), isFalse);
      vm.dispose();
    });

    test('returns false for future scheduled event', () {
      final vm = MyEventViewModel(
        eventViewModel: eventViewModel,
        authService: mockAuthService,
        loadUserEventsUseCase: mockLoadUseCase,
      );

      final event = _buildEvent(
        status: 'scheduled',
        date: DateTime.now().add(const Duration(days: 5)),
      );
      expect(vm.canStartEvent(event), isFalse);
      vm.dispose();
    });
  });

  group('MyEventViewModel – eventDay', () {
    test('returns midnight of the event date', () {
      final vm = MyEventViewModel(
        eventViewModel: eventViewModel,
        authService: mockAuthService,
        loadUserEventsUseCase: mockLoadUseCase,
      );

      final event = _buildEvent(date: DateTime(2025, 6, 15, 10, 30));
      final day = vm.eventDay(event);

      expect(day.hour, 0);
      expect(day.minute, 0);
      expect(day.day, 15);
      vm.dispose();
    });
  });
}
