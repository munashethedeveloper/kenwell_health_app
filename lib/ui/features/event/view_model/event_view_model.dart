import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';

class EventViewModel extends ChangeNotifier {
  // Controllers
  final titleController = TextEditingController();
  final venueController = TextEditingController();
  final addressController = TextEditingController();
  final onsiteContactController = TextEditingController();
  final onsiteNumberController = TextEditingController();
  final onsiteEmailController = TextEditingController();
  final aeContactController = TextEditingController();
  final aeNumberController = TextEditingController();
  final expectedParticipationController = TextEditingController();
  final passportsController = TextEditingController();
  final nursesController = TextEditingController();
  final setUpTimeController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final strikeDownTimeController = TextEditingController();
  final medicalAidController = TextEditingController();
  final dateController = TextEditingController();

  // Dropdowns
  String nonMembers = 'No';
  String coordinators = 'No';
  String multiplyPromoters = 'No';
  String mobileBooths = 'No';
  String servicesRequested = 'HRA';

  // Events
  final List<WellnessEvent> _events = [];
  List<WellnessEvent> get events => _events;

  EventViewModel();

  // Load existing event for editing
  void loadExistingEvent(WellnessEvent? e) {
    if (e == null) return;

    titleController.text = e.title;
    venueController.text = e.venue;
    addressController.text = e.address;
    onsiteContactController.text = e.onsiteContactPerson;
    onsiteNumberController.text = e.onsiteContactNumber;
    onsiteEmailController.text = e.onsiteContactEmail;
    aeContactController.text = e.aeContactPerson;
    aeNumberController.text = e.aeContactNumber;
    expectedParticipationController.text = e.expectedParticipation.toString();
    passportsController.text = e.passports.toString();
    nursesController.text = e.nurses.toString();
    setUpTimeController.text = e.setUpTime;
    startTimeController.text = e.startTime;
    endTimeController.text = e.endTime;
    strikeDownTimeController.text = e.strikeDownTime;
    medicalAidController.text = e.medicalAidOption;

    dateController.text =
        "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}";

    nonMembers = e.nonMembers == 1 ? 'Yes' : 'No';
    coordinators = e.coordinators == 1 ? 'Yes' : 'No';
    multiplyPromoters = e.multiplyPromoters == 1 ? 'Yes' : 'No';
    mobileBooths = e.mobileBooths;
    servicesRequested = e.servicesRequested;

    notifyListeners();
  }

  // Set time in controller (UI calls this)
  void setTime(
      TextEditingController controller, TimeOfDay time, BuildContext context) {
    controller.text = time.format(context);
    notifyListeners();
  }

  Future<void> pickTime(
      BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      if (!context.mounted) return;
      controller.text = picked.format(context);
      notifyListeners();
    }
  }

  // Build event model
  WellnessEvent buildEvent(DateTime date) {
    return WellnessEvent(
      title: titleController.text,
      date: date,
      venue: venueController.text,
      address: addressController.text,
      onsiteContactPerson: onsiteContactController.text,
      onsiteContactNumber: onsiteNumberController.text,
      onsiteContactEmail: onsiteEmailController.text,
      aeContactPerson: aeContactController.text,
      aeContactNumber: aeNumberController.text,
      servicesRequested: servicesRequested,
      expectedParticipation:
          int.tryParse(expectedParticipationController.text) ?? 0,
      nonMembers: nonMembers == 'Yes' ? 1 : 0,
      passports: int.tryParse(passportsController.text) ?? 0,
      nurses: int.tryParse(nursesController.text) ?? 0,
      coordinators: coordinators == 'Yes' ? 1 : 0,
      multiplyPromoters: multiplyPromoters == 'Yes' ? 1 : 0,
      setUpTime: setUpTimeController.text,
      startTime: startTimeController.text,
      endTime: endTimeController.text,
      strikeDownTime: strikeDownTimeController.text,
      medicalAidOption: medicalAidController.text,
      mobileBooths: mobileBooths,
    );
  }

  void addEvent(WellnessEvent event) {
    _events.add(event);
    notifyListeners();
  }

  List<WellnessEvent> getEventsForDate(DateTime date) {
    return _events
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }

  void clearControllers() {
    titleController.clear();
    venueController.clear();
    addressController.clear();
    onsiteContactController.clear();
    onsiteNumberController.clear();
    onsiteEmailController.clear();
    aeContactController.clear();
    aeNumberController.clear();
    expectedParticipationController.clear();
    passportsController.clear();
    nursesController.clear();
    setUpTimeController.clear();
    startTimeController.clear();
    endTimeController.clear();
    strikeDownTimeController.clear();
    medicalAidController.clear();
    dateController.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    venueController.dispose();
    addressController.dispose();
    onsiteContactController.dispose();
    onsiteNumberController.dispose();
    onsiteEmailController.dispose();
    aeContactController.dispose();
    aeNumberController.dispose();
    expectedParticipationController.dispose();
    passportsController.dispose();
    nursesController.dispose();
    setUpTimeController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    strikeDownTimeController.dispose();
    medicalAidController.dispose();
    dateController.dispose();
    super.dispose();
  }
}
