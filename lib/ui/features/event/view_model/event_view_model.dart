import 'package:flutter/material.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../../data/repositories_dcl/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  EventViewModel({EventRepository? repository})
      : _repository = repository ?? EventRepository() {
    _resetServiceSelections();
    _initializationFuture = _loadPersistedEvents();
  }

  static const List<String> _serviceOptions = ['HRA', 'VCT', 'HIV', 'TB'];
  final EventRepository _repository;
  late final Future<void> _initializationFuture;

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

  Future<void> get initialized => _initializationFuture;

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

  Future<void> addEvent(WellnessEvent event) async {
    _events.add(event);
    notifyListeners();
    await _repository.addEvent(event);
  }

  /// Deletes an event by removing it from the list
  /// Returns the deleted event for potential undo operation
  Future<WellnessEvent?> deleteEvent(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final deletedEvent = _events.removeAt(index);
      notifyListeners();
      await _repository.deleteEvent(eventId);
      return deletedEvent;
    }
    return null;
  }

  /// Updates an existing event in the list
  /// Returns the previous version of the event for potential undo operation
  Future<WellnessEvent?> updateEvent(WellnessEvent updatedEvent) async {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      final previousEvent = _events[index];
      _events[index] = updatedEvent;
      notifyListeners();
      await _repository.updateEvent(updatedEvent);
      return previousEvent;
    }
    return null;
  }

  /// Restores a previously deleted event (undo functionality)
  Future<void> restoreEvent(WellnessEvent event) async {
    final exists = _events.any((e) => e.id == event.id);
    if (!exists) {
      _events.add(event);
      notifyListeners();
    }
    await _repository.upsertEvent(event);
  }

  List<WellnessEvent> getEventsForDate(DateTime date) {
    return _events
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }

  List<WellnessEvent> getUpcomingEvents({DateTime? from}) {
    final reference = from ?? DateTime.now();
    final eventsCopy = _events.where((event) {
      final start = event.startDateTime;
      if (start == null) return false;
      if (event.status == WellnessEventStatus.completed) return false;
      return !start.isBefore(reference.subtract(const Duration(minutes: 30)));
    }).toList();
    eventsCopy.sort(_compareEventsByStartTime);
    return eventsCopy;
  }

  Future<WellnessEvent?> markEventInProgress(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return null;
    final event = _events[index];
    final updated = event.copyWith(
      status: WellnessEventStatus.inProgress,
      actualStartTime: DateTime.now(),
    );
    await updateEvent(updated);
    return updated;
  }

  Future<WellnessEvent?> markEventCompleted(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return null;
    final event = _events[index];
    final updated = event.copyWith(
      status: WellnessEventStatus.completed,
      actualEndTime: DateTime.now(),
    );
    await updateEvent(updated);
    return updated;
  }

  Future<WellnessEvent?> incrementScreened(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) {
      debugPrint('incrementScreened: event $eventId not found');
      return null;
    }
    final event = _events[index];
    final updated = event.copyWith(
      screenedCount: event.screenedCount + 1,
    );
    await updateEvent(updated);
    return updated;
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

  Future<void> _loadPersistedEvents() async {
    try {
      final stored = await _repository.fetchAllEvents();
      _events
        ..clear()
        ..addAll(stored);
      notifyListeners();
    } catch (_) {
      // Ignore and keep in-memory list empty
    }
  }

  int _compareEventsByStartTime(WellnessEvent a, WellnessEvent b) {
    final aStart = a.startDateTime ?? a.date;
    final bStart = b.startDateTime ?? b.date;
    return aStart.compareTo(bStart);
  }
}
