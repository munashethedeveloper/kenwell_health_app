import 'package:flutter/material.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../../data/repositories_dcl/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  EventViewModel({EventRepository? repository})
      : _repository = repository ?? EventRepository() {
    _resetServiceSelections();
    _initializationFuture = _loadPersistedEvents();
  }

  static const List<String> _serviceOptions = [
    'Breast Screening',
    'Dental Screening',
    'Eye Test',
    'HCT',
    'HIV Test',
    'HRA',
    'Pap Smear',
    'Psychological Assessment',
    'Posture Screening',
    'PSA',
    'Psychological Screening',
    'TB Test',
  ];

  static const List<String> _additionalServiceOptions = [
    'Massage Therapy',
    'Pediatric Care',
    'Smoothie Bar',
    'Event Setup Assistance',
    'Event Management',
  ];

  final EventRepository _repository;
  late final Future<void> _initializationFuture;

  // Controllers
  final titleController = TextEditingController();
  final venueController = TextEditingController();
  final townCityController = TextEditingController();
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
  final nursesController = TextEditingController(); //nurses
  final setUpTimeController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final strikeDownTimeController = TextEditingController();
  final dateController = TextEditingController();

  // Dropdowns
  String coordinators = 'No';
  String mobileBooths = 'No';
  String medicalAid = "No";

  String? province;

  //Healthcare Professional Dropdowns
  //Nurses
  String nurses = 'No';
  String nursesOption = 'No';
  int nursesCount = 0;

  //occupational Therapists
  String occupationalTherapists = 'No';
  String occupationalTherapistsOption = 'No';
  int occupationalTherapistsCount = 0;

  //Dietician
  String dieticians = 'No';
  String dieticiansOption = 'No';
  int dieticiansCount = 0;

  //Psychologists
  String psychologists = 'No';
  String psychologistsOption = 'No';
  int psychologistsCount = 0;

  //Optometrist
  String optometrists = 'No';
  String optometristsOption = 'No';
  int optometristsCount = 0;

  //Dental Hygenists
  String dentalHygenists = 'No';
  String dentalHygenistsOption = 'No';
  int dentalHygenistsCount = 0;

  // NEW: Coordinators dropdown + number
  String coordinatorsOption = 'No';
  int coordinatorsCount = 0;

// NEW: Mobile Booths dropdown + number
  String mobileBoothsOption = 'No';
  int mobileBoothsCount = 0;

  // Events
  final List<WellnessEvent> _events = [];
  List<WellnessEvent> get events => _events;

  Future<void> get initialized => _initializationFuture;

//Services Selection
  final Set<String> _selectedServices = {};
  final Set<String> _selectedAdditionalServices = {};

  List<String> get availableServiceOptions =>
      List<String>.unmodifiable(_serviceOptions);
  List<String> get availableAdditionalServiceOptions =>
      List<String>.unmodifiable(_additionalServiceOptions);

  Set<String> get selectedServices =>
      Set<String>.unmodifiable(_selectedServices);
  Set<String> get selectedAdditionalServices =>
      Set<String>.unmodifiable(_selectedAdditionalServices);

  bool isServiceSelected(String service) => _selectedServices.contains(service);
  bool isAdditionalServiceSelected(String service) =>
      _selectedAdditionalServices.contains(service);

  void toggleServiceSelection(String service, bool shouldSelect) {
    if (!_serviceOptions.contains(service)) return;
    if (shouldSelect) {
      _selectedServices.add(service);
    } else {
      _selectedServices.remove(service);
    }
    notifyListeners();
  }

  void toggleAdditionalServiceSelection(String service, bool shouldSelect) {
    if (!_additionalServiceOptions.contains(service)) return;
    if (shouldSelect) {
      _selectedAdditionalServices.add(service);
    } else {
      _selectedAdditionalServices.remove(service);
    }
    notifyListeners();
  }

  String get servicesRequested =>
      _selectedServices.isEmpty ? '' : _selectedServices.join(', ');
  String get additionalServicesRequested => _selectedAdditionalServices.isEmpty
      ? ''
      : _selectedAdditionalServices.join(', ');

  // Load existing event for editing
  void loadExistingEvent(WellnessEvent? e) {
    if (e == null) return;

    titleController.text = e.title;
    venueController.text = e.venue;
    addressController.text = e.address;
    townCityController.text = e.townCity;
    onsiteContactFirstNameController.text = e.onsiteContactFirstName;
    onsiteContactLastNameController.text = e.onsiteContactLastName;
    onsiteNumberController.text = e.onsiteContactNumber;
    onsiteEmailController.text = e.onsiteContactEmail;
    aeContactFirstNameController.text = e.aeContactFirstName;
    aeContactLastNameController.text = e.aeContactLastName;
    aeNumberController.text = e.aeContactNumber;
    aeEmailController.text = e.aeContactEmail;
    expectedParticipationController.text = e.expectedParticipation.toString();
    nursesController.text = e.nurses.toString();
    setUpTimeController.text = e.setUpTime;
    startTimeController.text = e.startTime;
    endTimeController.text = e.endTime;
    strikeDownTimeController.text = e.strikeDownTime;

    dateController.text =
        "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}";
    coordinators = e.coordinators == 1 ? 'Yes' : 'No';
    mobileBooths = e.mobileBooths;
    _setServicesFromString(e.servicesRequested);
    _setAdditionalServicesFromString(e.additionalServicesRequested);
    medicalAid = e.medicalAid;

    notifyListeners();
  }

  // Set time in controller (UI calls this)
  void setTime(
      TextEditingController controller, TimeOfDay time, BuildContext context) {
    controller.text = time.format(context);
    notifyListeners();
  }

  void updateProvince(String value) {
    province = value;
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
      townCity: townCityController.text,
      venue: venueController.text,
      address: addressController.text,
      province: province ?? '',
      onsiteContactFirstName: onsiteContactFirstNameController.text,
      onsiteContactLastName: onsiteContactLastNameController.text,
      onsiteContactNumber: onsiteNumberController.text,
      onsiteContactEmail: onsiteEmailController.text,
      aeContactFirstName: aeContactFirstNameController.text,
      aeContactLastName: aeContactLastNameController.text,
      aeContactNumber: aeNumberController.text,
      aeContactEmail: aeEmailController.text,
      servicesRequested: servicesRequested,
      additionalServicesRequested: additionalServicesRequested,
      expectedParticipation:
          int.tryParse(expectedParticipationController.text) ?? 0,
      nurses: int.tryParse(nursesController.text) ?? 0,
      coordinators: coordinators == 'Yes' ? 1 : 0,
      setUpTime: setUpTimeController.text,
      startTime: startTimeController.text,
      endTime: endTimeController.text,
      strikeDownTime: strikeDownTimeController.text,
      mobileBooths: mobileBooths,
      medicalAid: medicalAid,
    );
  }

  Future<void> incrementScreened(String eventId) async {
    try {
      // Find the event in memory (adjust to your storage if different)
      final idx = _events.indexWhere((e) => e.id == eventId);
      if (idx == -1) {
        debugPrint('incrementScreened: event not found: $eventId');
        return;
      }

      final existing = _events[idx];
      final current = existing.screenedCount ?? 0;
      final updated = existing.copyWith(screenedCount: current + 1);

      // Persist the update using your existing updateEvent(...) method so data source is consistent
      await updateEvent(updated);

      // Ensure local list is updated if updateEvent doesn't update the in-memory list
      _events[idx] = updated;
      notifyListeners();
    } catch (e, st) {
      debugPrint('incrementScreened failed for $eventId: $e\n$st');
    }
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
      // Don't show completed events
      if (event.status == WellnessEventStatus.completed) return false;

      // Keep events until strike down time has elapsed
      final strikeDown = event.strikeDownDateTime;
      if (strikeDown != null && reference.isAfter(strikeDown)) {
        return false;
      }

      // Show all events that haven't passed their strike down time
      return true;
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

  void clearControllers() {
    titleController.clear();
    venueController.clear();
    addressController.clear();
    townCityController.clear();
    onsiteContactFirstNameController.clear();
    onsiteContactLastNameController.clear();
    onsiteNumberController.clear();
    onsiteEmailController.clear();
    aeContactFirstNameController.clear();
    aeContactLastNameController.clear();
    aeNumberController.clear();
    aeEmailController.clear();
    expectedParticipationController.clear();
    nursesController.clear();
    setUpTimeController.clear();
    startTimeController.clear();
    endTimeController.clear();
    strikeDownTimeController.clear();
    dateController.clear();
    _resetServiceSelections();
    _resetAdditionalServiceSelections();
  }

  @override
  void dispose() {
    titleController.dispose();
    venueController.dispose();
    addressController.dispose();
    townCityController.dispose();
    onsiteContactFirstNameController.dispose();
    onsiteContactLastNameController.dispose();
    onsiteNumberController.dispose();
    onsiteEmailController.dispose();
    aeContactFirstNameController.dispose();
    aeContactLastNameController.dispose();
    aeNumberController.dispose();
    aeEmailController.dispose();
    expectedParticipationController.dispose();
    nursesController.dispose();
    setUpTimeController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    strikeDownTimeController.dispose();
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

  void _setAdditionalServicesFromString(String raw) {
    final parsed = raw.split(',').map((value) => value.trim()).where((value) =>
        value.isNotEmpty && _additionalServiceOptions.contains(value));

    _selectedAdditionalServices
      ..clear()
      ..addAll(parsed);

    if (_selectedAdditionalServices.isEmpty) {
      _resetAdditionalServiceSelections();
    }
  }

  void _resetServiceSelections() {
    _selectedServices
      ..clear()
      ..add(_serviceOptions.first);
  }

  void _resetAdditionalServiceSelections() {
    _selectedAdditionalServices
      ..clear()
      ..add(_additionalServiceOptions.first);
  }

  Future<void> _loadPersistedEvents() async {
    try {
      final stored = await _repository.fetchAllEvents();
      _events
        ..clear()
        ..addAll(stored);
      notifyListeners();
      debugPrint('EventViewModel: Loaded ${stored.length} events from repository');
    } catch (e) {
      // Log error but keep in-memory list empty
      debugPrint('EventViewModel: Error loading events: $e');
    }
  }

  /// Reload events from repository (useful when returning to screens)
  Future<void> reloadEvents() async {
    debugPrint('EventViewModel: Reloading events...');
    await _loadPersistedEvents();
  }

  int _compareEventsByStartTime(WellnessEvent a, WellnessEvent b) {
    final aStart = a.startDateTime ?? a.date;
    final bStart = b.startDateTime ?? b.date;
    return aStart.compareTo(bStart);
  }
}
