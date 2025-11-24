import 'package:flutter/material.dart';

import '../../../../domain/models/wellness_event.dart';

class EventViewModel extends ChangeNotifier {
  EventViewModel() {
    _resetServiceSelections();
  }

  static const List<String> _serviceOptions = ['HRA', 'VCT', 'HIV', 'TB'];

  // Controllers
  final titleController = TextEditingController();
  final venueController = TextEditingController();
  final addressController = TextEditingController();
  final onsiteContactFirstNameController = TextEditingController();
  final onsiteContactLastNameController = TextEditingController();
  final onsiteNumberController = TextEditingController();
  final onsiteEmailController = TextEditingController();
  final aeContactFirstNameController = TextEditingController();
  final aeContactLastNameController = TextEditingController();
  final aeNumberController = TextEditingController();
  final aeEmailController = TextEditingController();
  final expectedParticipationController = TextEditingController();
  final passportsController = TextEditingController();
  final nursesController = TextEditingController();
  final setUpTimeController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final strikeDownTimeController = TextEditingController();
  //final medicalAidController = TextEditingController();
  final dateController = TextEditingController();

  // Dropdowns
  String nonMembers = 'No';
  String coordinators = 'No';
  String multiplyPromoters = 'No';
  String mobileBooths = 'No';
  String medicalAid = "No";

  // Events
  final List<WellnessEvent> _events = [];
  List<WellnessEvent> get events => _events;

  final Set<String> _selectedServices = {};

  List<String> get availableServiceOptions =>
      List<String>.unmodifiable(_serviceOptions);

  Set<String> get selectedServices =>
      Set<String>.unmodifiable(_selectedServices);

  bool isServiceSelected(String service) => _selectedServices.contains(service);

  void toggleServiceSelection(String service, bool shouldSelect) {
    if (!_serviceOptions.contains(service)) return;
    if (shouldSelect) {
      _selectedServices.add(service);
    } else {
      _selectedServices.remove(service);
    }
    notifyListeners();
  }

  String get servicesRequested =>
      _selectedServices.isEmpty ? '' : _selectedServices.join(', ');

  // Load existing event for editing
  void loadExistingEvent(WellnessEvent? e) {
    if (e == null) return;

    titleController.text = e.title;
    venueController.text = e.venue;
    addressController.text = e.address;
    onsiteContactFirstNameController.text = e.onsiteContactFirstName;
    onsiteContactLastNameController.text = e.onsiteContactLastName;
    onsiteNumberController.text = e.onsiteContactNumber;
    onsiteEmailController.text = e.onsiteContactEmail;
    aeContactFirstNameController.text = e.aeContactFirstName;
    aeContactLastNameController.text = e.aeContactLastName;
    aeNumberController.text = e.aeContactNumber;
    aeEmailController.text = e.aeContactEmail;
    expectedParticipationController.text = e.expectedParticipation.toString();
    passportsController.text = e.passports.toString();
    nursesController.text = e.nurses.toString();
    setUpTimeController.text = e.setUpTime;
    startTimeController.text = e.startTime;
    endTimeController.text = e.endTime;
    strikeDownTimeController.text = e.strikeDownTime;
    //medicalAidController.text = e.medicalAidOption;

    dateController.text =
        "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}";

    nonMembers = e.nonMembers == 1 ? 'Yes' : 'No';
    coordinators = e.coordinators == 1 ? 'Yes' : 'No';
    multiplyPromoters = e.multiplyPromoters == 1 ? 'Yes' : 'No';
    mobileBooths = e.mobileBooths;
    _setServicesFromString(e.servicesRequested);
    medicalAid = e.medicalAid;

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
      // Only use context if the widget is still mounted
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
      onsiteContactFirstName: onsiteContactFirstNameController.text,
      onsiteContactLastName: onsiteContactLastNameController.text,
      onsiteContactNumber: onsiteNumberController.text,
      onsiteContactEmail: onsiteEmailController.text,
      aeContactFirstName: aeContactFirstNameController.text,
      aeContactLastName: aeContactLastNameController.text,
      aeContactNumber: aeNumberController.text,
      aeContactEmail: aeEmailController.text,
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
      //medicalAidOption: medicalAidController.text,
      mobileBooths: mobileBooths,
      medicalAid: medicalAid,
    );
  }

  void addEvent(WellnessEvent event) {
    _events.add(event);
    notifyListeners();
  }

  /// Deletes an event by removing it from the list
  /// Returns the deleted event for potential undo operation
  WellnessEvent? deleteEvent(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final deletedEvent = _events.removeAt(index);
      notifyListeners();
      return deletedEvent;
    }
    return null;
  }

  /// Updates an existing event in the list
  /// Returns the previous version of the event for potential undo operation
  WellnessEvent? updateEvent(WellnessEvent updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      final previousEvent = _events[index];
      _events[index] = updatedEvent;
      notifyListeners();
      return previousEvent;
    }
    return null;
  }

  /// Restores a previously deleted event (undo functionality)
  void restoreEvent(WellnessEvent event) {
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
    onsiteContactFirstNameController.clear();
    onsiteContactLastNameController.clear();
    onsiteNumberController.clear();
    onsiteEmailController.clear();
    aeContactFirstNameController.clear();
    aeContactLastNameController.clear();
    aeNumberController.clear();
    aeEmailController.clear();
    expectedParticipationController.clear();
    passportsController.clear();
    nursesController.clear();
    setUpTimeController.clear();
    startTimeController.clear();
    endTimeController.clear();
    strikeDownTimeController.clear();
    //medicalAidController.clear();
    dateController.clear();
    _resetServiceSelections();
  }

  @override
  void dispose() {
    titleController.dispose();
    venueController.dispose();
    addressController.dispose();
    onsiteContactFirstNameController.dispose();
    onsiteContactLastNameController.dispose();
    onsiteNumberController.dispose();
    onsiteEmailController.dispose();
    aeContactFirstNameController.dispose();
    aeContactLastNameController.dispose();
    aeNumberController.dispose();
    aeEmailController.dispose();
    expectedParticipationController.dispose();
    passportsController.dispose();
    nursesController.dispose();
    setUpTimeController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    strikeDownTimeController.dispose();
    //medicalAidController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _setServicesFromString(String raw) {
    final parsed = raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && _serviceOptions.contains(value));

    _selectedServices
      ..clear()
      ..addAll(parsed);

    if (_selectedServices.isEmpty) {
      _resetServiceSelections();
    }
  }

  void _resetServiceSelections() {
    _selectedServices
      ..clear()
      ..add(_serviceOptions.first);
  }
}
