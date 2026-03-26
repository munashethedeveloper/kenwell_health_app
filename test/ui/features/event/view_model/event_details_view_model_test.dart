import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_details_view_model.dart';

WellnessEvent _buildEvent() => WellnessEvent(
      id: 'ev-1',
      title: 'Health Day 2025',
      date: DateTime(2025, 6, 15),
      venue: 'Hall A',
      address: '1 Main Rd',
      townCity: 'Johannesburg',
      province: 'Gauteng',
      onsiteContactFirstName: 'Alice',
      onsiteContactLastName: 'Smith',
      onsiteContactNumber: '0110001111',
      onsiteContactEmail: 'alice@ex.com',
      aeContactFirstName: 'Bob',
      aeContactLastName: 'Jones',
      aeContactNumber: '0110002222',
      aeContactEmail: 'bob@ex.com',
      servicesRequested: 'HRA',
      expectedParticipation: 100,
      nurses: 2,
      setUpTime: '07:00',
      startTime: '08:00',
      endTime: '16:00',
      strikeDownTime: '17:00',
      mobileBooths: 'No',
      medicalAid: 'Discovery',
    );

void main() {
  late EventDetailsViewModel viewModel;

  setUp(() {
    viewModel = EventDetailsViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('EventDetailsViewModel – initial state', () {
    test('event is null initially', () {
      expect(viewModel.event, isNull);
    });
  });

  group('EventDetailsViewModel – setEvent', () {
    test('sets event and notifies listeners', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setEvent(_buildEvent());

      expect(viewModel.event, isNotNull);
      expect(viewModel.event!.title, 'Health Day 2025');
      expect(notified, isTrue);
    });
  });

  group('EventDetailsViewModel – formatEventDate', () {
    test('returns a human-readable long date string', () {
      final result = viewModel.formatEventDate(DateTime(2025, 6, 15));
      expect(result, contains('2025'));
      expect(result, contains('June'));
    });
  });
}
