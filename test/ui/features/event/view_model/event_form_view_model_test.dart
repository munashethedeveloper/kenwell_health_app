import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/features/event/view_model/event_form_view_model.dart';

void main() {
  late EventFormViewModel viewModel;

  setUp(() {
    viewModel = EventFormViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('EventFormViewModel – initial state', () {
    test('text controllers are empty', () {
      expect(viewModel.titleController.text, isEmpty);
      expect(viewModel.venueController.text, isEmpty);
    });

    test('province is null', () => expect(viewModel.province, isNull));
    test('medicalAid defaults to No', () => expect(viewModel.medicalAid, 'No'));
    test('selectedServices is empty',
        () => expect(viewModel.selectedServices, isEmpty));
    test('selectedAdditionalServices is empty',
        () => expect(viewModel.selectedAdditionalServices, isEmpty));
  });

  group('EventFormViewModel – service selection', () {
    test('toggleServiceSelection selects a service', () {
      viewModel.toggleServiceSelection('Health Risk Assessment', true);
      expect(viewModel.isServiceSelected('Health Risk Assessment'), isTrue);
    });

    test('toggleServiceSelection deselects a previously selected service', () {
      viewModel.toggleServiceSelection('Health Risk Assessment', true);
      viewModel.toggleServiceSelection('Health Risk Assessment', false);
      expect(viewModel.isServiceSelected('Health Risk Assessment'), isFalse);
    });
  });

  group('EventFormViewModel – updateProvince', () {
    test('updates province and notifies', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.updateProvince('Gauteng');

      expect(viewModel.province, 'Gauteng');
      expect(notified, isTrue);
    });
  });

  group('EventFormViewModel – loadExistingEvent', () {
    test('pre-fills controllers from existing event', () {
      final event = WellnessEvent(
        id: 'ev-1',
        title: 'Cape Day',
        date: DateTime(2025, 6, 15),
        venue: 'Hall',
        address: '1 Rd',
        townCity: 'Cape Town',
        province: 'Western Cape',
        onsiteContactFirstName: 'A',
        onsiteContactLastName: 'B',
        onsiteContactNumber: '000',
        onsiteContactEmail: 'a@b.com',
        aeContactFirstName: 'C',
        aeContactLastName: 'D',
        aeContactNumber: '000',
        aeContactEmail: 'c@d.com',
        servicesRequested: 'HRA',
        expectedParticipation: 100,
        nurses: 2,
        setUpTime: '07:00',
        startTime: '08:00',
        endTime: '16:00',
        strikeDownTime: '17:00',
        mobileBooths: 'No',
        medicalAid: 'None',
      );

      viewModel.loadExistingEvent(event);

      expect(viewModel.titleController.text, 'Cape Day');
      expect(viewModel.venueController.text, 'Hall');
      expect(viewModel.province, 'Western Cape');
    });

    test('handles null event gracefully', () {
      expect(() => viewModel.loadExistingEvent(null), returnsNormally);
    });
  });

  group('EventFormViewModel – buildEvent', () {
    test('builds WellnessEvent from form state', () {
      viewModel.titleController.text = 'New Event';
      viewModel.venueController.text = 'Arena';
      viewModel.addressController.text = '5 Street';
      viewModel.townCityController.text = 'Pretoria';
      viewModel.updateProvince('Gauteng');
      viewModel.onsiteContactFirstNameController.text = 'Sam';
      viewModel.onsiteContactLastNameController.text = 'Lee';
      viewModel.onsiteNumberController.text = '0110001111';
      viewModel.onsiteEmailController.text = 'sam@ex.com';
      viewModel.aeContactFirstNameController.text = 'Ann';
      viewModel.aeContactLastNameController.text = 'Kim';
      viewModel.aeNumberController.text = '0110002222';
      viewModel.aeEmailController.text = 'ann@ex.com';
      viewModel.expectedParticipationController.text = '200';
      viewModel.setUpTimeController.text = '07:00';
      viewModel.startTimeController.text = '08:00';
      viewModel.endTimeController.text = '16:00';
      viewModel.strikeDownTimeController.text = '17:00';

      final event = viewModel.buildEvent(DateTime(2025, 9, 1));

      expect(event.title, 'New Event');
      expect(event.province, 'Gauteng');
      expect(event.expectedParticipation, 200);
    });
  });

  group('EventFormViewModel – availableServiceOptions', () {
    test('returns non-empty list', () {
      expect(viewModel.availableServiceOptions, isNotEmpty);
    });
  });
}
