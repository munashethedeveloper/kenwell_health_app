import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/user_event_repository.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/allocate_event_view_model.dart';

class MockUserEventRepository extends Mock implements UserEventRepository {}

WellnessEvent _buildEvent({String id = 'ev-1'}) => WellnessEvent(
      id: id,
      title: 'Health Day',
      date: DateTime(2025, 6, 1),
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
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'None',
    );

UserModel _buildUser({String id = 'u-1'}) => UserModel(
      id: id,
      email: 'nurse@ex.com',
      role: 'nurse',
      phoneNumber: '0821234567',
      firstName: 'Alice',
      lastName: 'Smith',
      emailVerified: true,
    );

void main() {
  late MockUserEventRepository mockRepo;
  late AllocateEventViewModel viewModel;

  setUp(() {
    mockRepo = MockUserEventRepository();
    viewModel = AllocateEventViewModel(
      event: _buildEvent(),
      repository: mockRepo,
    );
  });

  tearDown(() => viewModel.dispose());

  group('AllocateEventViewModel – initial state', () {
    test('assignedUserIds is empty', () {
      expect(viewModel.assignedUserIds, isEmpty);
    });
    test('isLoading is false', () => expect(viewModel.isLoading, isFalse));
    test('error is null', () => expect(viewModel.error, isNull));
    test('assignedCount is 0', () => expect(viewModel.assignedCount, 0));
  });

  group('AllocateEventViewModel – loadAssignedUsers', () {
    test('populates assignedUserIds on success', () async {
      when(() => mockRepo.fetchAssignedUserIds(any()))
          .thenAnswer((_) async => {'u-1', 'u-2'});

      await viewModel.loadAssignedUsers();

      expect(viewModel.assignedUserIds, containsAll(['u-1', 'u-2']));
      expect(viewModel.assignedCount, 2);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('sets error when repository throws', () async {
      when(() => mockRepo.fetchAssignedUserIds(any()))
          .thenThrow(Exception('db error'));

      await viewModel.loadAssignedUsers();

      expect(viewModel.error, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('AllocateEventViewModel – isAssigned', () {
    test('returns true for assigned user', () async {
      when(() => mockRepo.fetchAssignedUserIds(any()))
          .thenAnswer((_) async => {'u-1'});
      await viewModel.loadAssignedUsers();

      expect(viewModel.isAssigned('u-1'), isTrue);
      expect(viewModel.isAssigned('u-99'), isFalse);
    });
  });

  group('AllocateEventViewModel – unassignUser', () {
    test('calls repository and reloads assigned users', () async {
      when(() => mockRepo.removeUserEvent(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRepo.fetchAssignedUserIds(any()))
          .thenAnswer((_) async => {});

      await viewModel.unassignUser(_buildUser());

      verify(() => mockRepo.removeUserEvent(any(), any())).called(1);
      expect(viewModel.isLoading, isFalse);
    });

    test('sets error when removeUserEvent throws', () async {
      when(() => mockRepo.removeUserEvent(any(), any()))
          .thenThrow(Exception('remove error'));

      await viewModel.unassignUser(_buildUser());

      expect(viewModel.error, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });
  });
}
