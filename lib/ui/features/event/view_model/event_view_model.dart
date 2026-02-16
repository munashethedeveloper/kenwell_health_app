import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../data/repositories_dcl/event_repository.dart';
import '../../../../domain/enums/service_type.dart';
import '../../../../domain/enums/additional_service_type.dart';
import '../../../../domain/constants/provinces.dart';

/// ViewModel for managing wellness events
class EventViewModel extends ChangeNotifier {
  /// Constructor
  EventViewModel({EventRepository? repository})
      : _repository = repository ?? EventRepository() {
    _initializationFuture = _loadPersistedEvents();
  }

  // Repository
  final EventRepository _repository;
  // Initialization Future
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
  String medicalAid = "No";
  String? province;

  // Coordinators
  String coordinatorsOption = 'No';
  int coordinatorsCount = 0;

  // Mobile Booths
  String mobileBoothsOption = 'No';
  int mobileBoothsCount = 0;

  // Healthcare Professionals
  String nursesOption = 'No';
  int nursesCount = 0;

  String occupationalTherapistsOption = 'No';
  int occupationalTherapistsCount = 0;

  String dieticiansOption = 'No';
  int dieticiansCount = 0;

  String psychologistsOption = 'No';
  int psychologistsCount = 0;

  String optometristsOption = 'No';
  int optometristsCount = 0;

  String dentalHygenistsOption = 'No';
  int dentalHygenistsCount = 0;

  // Getters for backward compatibility
  String get coordinators => coordinatorsOption;
  String get mobileBooths => mobileBoothsOption;

  // Events
  final List<WellnessEvent> _events = [];
  List<WellnessEvent> get events => _events;

  Future<void> get initialized => _initializationFuture;

  // Loading and Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // State Management Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Input Validation and Sanitization
  String _sanitizeString(String? input) {
    return input?.trim() ?? '';
  }

  int _sanitizeInt(String? input, {int defaultValue = 0}) {
    if (input == null || input.isEmpty) return defaultValue;
    return int.tryParse(input.trim()) ?? defaultValue;
  }

  // Validation helpers (available for future use)
  // ignore: unused_element
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // ignore: unused_element
  bool _isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
  }

  // Services Selection (using enums)
  final Set<ServiceType> _selectedServices = {};
  final Set<AdditionalServiceType> _selectedAdditionalServices = {};

  // Getters for available options
  List<String> get availableServiceOptions =>
      ServiceTypeExtension.allDisplayNames;
  List<String> get availableAdditionalServiceOptions =>
      AdditionalServiceTypeExtension.allDisplayNames;

  // Getters for selected services
  Set<String> get selectedServices =>
      _selectedServices.map((e) => e.displayName).toSet();
  Set<String> get selectedAdditionalServices =>
      _selectedAdditionalServices.map((e) => e.displayName).toSet();

  // Check if service is selected
  bool isServiceSelected(String service) {
    return _selectedServices.any((s) => s.displayName == service);
  }

  // Check if additional service is selected
  bool isAdditionalServiceSelected(String service) {
    return _selectedAdditionalServices.any((s) => s.displayName == service);
  }

  // Toggle service selection
  void toggleServiceSelection(String service, bool shouldSelect) {
    final serviceType = ServiceTypeExtension.fromString(service);
    if (serviceType == null) return;

    if (shouldSelect) {
      _selectedServices.add(serviceType);
    } else {
      _selectedServices.remove(serviceType);
    }
    notifyListeners();
  }

  // Toggle additional service selection
  void toggleAdditionalServiceSelection(String service, bool shouldSelect) {
    final serviceType = AdditionalServiceTypeExtension.fromString(service);
    if (serviceType == null) return;

    if (shouldSelect) {
      _selectedAdditionalServices.add(serviceType);
    } else {
      _selectedAdditionalServices.remove(serviceType);
    }
    notifyListeners();
  }

  // Getters for storage strings
  String get servicesRequested =>
      ServiceTypeConverter.toStorageString(_selectedServices);
  String get additionalServicesRequested =>
      AdditionalServiceTypeConverter.toStorageString(
          _selectedAdditionalServices);

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
    coordinatorsOption = e.coordinators > 0 ? 'Yes' : 'No';
    coordinatorsCount = e.coordinators;
    mobileBoothsOption = e.mobileBooths;
    nursesCount = e.nurses;
    nursesOption = e.nurses > 0 ? 'Yes' : 'No';
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

  // Update province
  void updateProvince(String value) {
    province = value;
    notifyListeners();
  }

  // Set province without notifying listeners
  // Used by geocodeAddress to batch state changes and trigger single notification
  void _setProvince(String value) {
    province = value;
  }

  /// Geocode address and auto-fill town/city and province
  Future<void> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return;

    try {
      // Get locations from address
      final locations = await locationFromAddress(address);
      
      if (locations.isEmpty) {
        debugPrint('EventViewModel: No locations found for address: $address');
        return;
      }

      // Get placemarks from coordinates
      final placemarks = await placemarkFromCoordinates(
        locations.first.latitude,
        locations.first.longitude,
      );

      if (placemarks.isEmpty) {
        debugPrint('EventViewModel: No placemarks found for coordinates');
        return;
      }

      final placemark = placemarks.first;
      bool fieldsUpdated = false;
      
      // Auto-fill town/city
      // Locality (e.g., "Johannesburg") is the primary city/town name
      // SubAdministrativeArea is used as fallback when locality is unavailable
      // This handles cases where geocoding services return different levels of detail
      final city = placemark.locality ?? placemark.subAdministrativeArea ?? '';
      if (city.isNotEmpty && townCityController.text.isEmpty) {
        townCityController.text = city;
        fieldsUpdated = true;
      }

      // Auto-fill province - match to our province list
      final provinceName = placemark.administrativeArea ?? '';
      final hasNoProvince = province == null || province!.isEmpty;
      
      if (provinceName.isNotEmpty && hasNoProvince) {
        // Try to match the geocoded province to our list
        final matchedProvince = SouthAfricanProvinces.match(provinceName);
        if (matchedProvince != null) {
          _setProvince(matchedProvince);
          fieldsUpdated = true;
          debugPrint('EventViewModel: Geocoded - City: $city, Province: $matchedProvince');
        } else {
          debugPrint('EventViewModel: Could not match province "$provinceName" to known provinces');
        }
      }

      if (fieldsUpdated) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('EventViewModel: Error geocoding address: $e');
      // Silently fail - don't show error to user as this is a convenience feature
    }
  }

  // Pick time using TimePicker
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
      title: _sanitizeString(titleController.text),
      date: date,
      townCity: _sanitizeString(townCityController.text),
      venue: _sanitizeString(venueController.text),
      address: _sanitizeString(addressController.text),
      province: _sanitizeString(province),
      onsiteContactFirstName:
          _sanitizeString(onsiteContactFirstNameController.text),
      onsiteContactLastName:
          _sanitizeString(onsiteContactLastNameController.text),
      onsiteContactNumber: _sanitizeString(onsiteNumberController.text),
      onsiteContactEmail: _sanitizeString(onsiteEmailController.text),
      aeContactFirstName: _sanitizeString(aeContactFirstNameController.text),
      aeContactLastName: _sanitizeString(aeContactLastNameController.text),
      aeContactNumber: _sanitizeString(aeNumberController.text),
      aeContactEmail: _sanitizeString(aeEmailController.text),
      servicesRequested: servicesRequested,
      additionalServicesRequested: additionalServicesRequested,
      expectedParticipation: _sanitizeInt(expectedParticipationController.text),
      nurses: nursesCount,
      coordinators: coordinatorsOption == 'Yes' ? coordinatorsCount : 0,
      setUpTime: _sanitizeString(setUpTimeController.text),
      startTime: _sanitizeString(startTimeController.text),
      endTime: _sanitizeString(endTimeController.text),
      strikeDownTime: _sanitizeString(strikeDownTimeController.text),
      mobileBooths: mobileBoothsOption,
      medicalAid: medicalAid,
    );
  }

  // Increment screened count
  Future<void> incrementScreened(String eventId) async {
    try {
      final idx = _events.indexWhere((e) => e.id == eventId);
      if (idx == -1) {
        debugPrint('incrementScreened: event not found: $eventId');
        _setError('Event not found');
        return;
      }

      final existing = _events[idx];
      final current = existing.screenedCount;
      final updated = existing.copyWith(screenedCount: current + 1);

      await updateEvent(updated);

      _events[idx] = updated;
      notifyListeners();
    } catch (e, st) {
      debugPrint('incrementScreened failed for $eventId: $e\n$st');
      _setError('Failed to update screened count: ${e.toString()}');
      rethrow;
    }
  }

  /// Adds a new event to the list and persists it
  Future<void> addEvent(WellnessEvent event) async {
    _setLoading(true);
    _setError(null);
    try {
      debugPrint('EventViewModel: Adding event "${event.title}"');
      _events.add(event);
      notifyListeners();
      await _repository.addEvent(event);
      debugPrint('EventViewModel: Event added successfully');
    } catch (e, stackTrace) {
      debugPrint('EventViewModel: ERROR adding event: $e');
      debugPrintStack(stackTrace: stackTrace);
      _setError('Failed to add event: ${e.toString()}');
      // Remove from local list if save failed
      _events.removeWhere((ev) => ev.id == event.id);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes an event by removing it from the list
  /// Returns the deleted event for potential undo operation
  Future<WellnessEvent?> deleteEvent(String eventId) async {
    _setLoading(true);
    _setError(null);
    try {
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final deletedEvent = _events.removeAt(index);
        notifyListeners();
        await _repository.deleteEvent(eventId);
        return deletedEvent;
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('EventViewModel: ERROR deleting event: $e');
      debugPrintStack(stackTrace: stackTrace);
      _setError('Failed to delete event: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing event in the list
  /// Returns the previous version of the event for potential undo operation
  Future<WellnessEvent?> updateEvent(WellnessEvent updatedEvent) async {
    _setLoading(true);
    _setError(null);
    try {
      final index = _events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        final previousEvent = _events[index];
        _events[index] = updatedEvent;
        notifyListeners();
        await _repository.updateEvent(updatedEvent);
        return previousEvent;
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('EventViewModel: ERROR updating event: $e');
      debugPrintStack(stackTrace: stackTrace);
      _setError('Failed to update event: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
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

  /// Retrieves events for a specific date
  List<WellnessEvent> getEventsForDate(DateTime date) {
    return _events
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }

  /// Retrieves upcoming events from a specific date
  List<WellnessEvent> getUpcomingEvents({DateTime? from}) {
    // Show all events that are not completed
    // The conduct_event_screen will filter by week range
    final eventsCopy = _events.where((event) {
      // Only filter out completed events
      return event.status != WellnessEventStatus.completed;
    }).toList();
    eventsCopy.sort(_compareEventsByStartTime);
    return eventsCopy;
  }

  /// Marks an event as in-progress
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

  /// Marks an event as completed
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

  // Clear all controllers
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

  // Dispose controllers
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

  // Helper to set services from storage string
  void _setServicesFromString(String raw) {
    _selectedServices.clear();
    _selectedServices.addAll(ServiceTypeConverter.fromStorageString(raw));
  }

  // Helper to set additional services from storage string
  void _setAdditionalServicesFromString(String raw) {
    _selectedAdditionalServices.clear();
    _selectedAdditionalServices
        .addAll(AdditionalServiceTypeConverter.fromStorageString(raw));
  }

  // Reset selections
  void _resetServiceSelections() {
    _selectedServices.clear();
  }

  // Reset additional selections
  void _resetAdditionalServiceSelections() {
    _selectedAdditionalServices.clear();
  }

  /// Load persisted events from repository
  Future<void> _loadPersistedEvents() async {
    _setLoading(true);
    _setError(null);
    try {
      final stored = await _repository.fetchAllEvents();
      _events
        ..clear()
        ..addAll(stored);
      notifyListeners();
      debugPrint(
          'EventViewModel: Loaded ${stored.length} events from repository');
    } catch (e, stackTrace) {
      debugPrint('EventViewModel: Error loading events: $e');
      debugPrintStack(stackTrace: stackTrace);
      _setError('Failed to load events: ${e.toString()}');
      // Keep in-memory list empty on error
    } finally {
      _setLoading(false);
    }
  }

  /// Reload events from repository (useful when returning to screens)
  Future<void> reloadEvents() async {
    debugPrint('EventViewModel: Reloading events...');
    try {
      await _loadPersistedEvents();
    } catch (e) {
      debugPrint('EventViewModel: Error reloading events: $e');
      _setError('Failed to reload events: ${e.toString()}');
    }
  }

  // Comparator for sorting events by start time
  int _compareEventsByStartTime(WellnessEvent a, WellnessEvent b) {
    final aStart = a.startDateTime ?? a.date;
    final bStart = b.startDateTime ?? b.date;
    return aStart.compareTo(bStart);
  }

  // ------------------ Formatting Methods ------------------
  String formatEventDateLong(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  String formatDateRange(DateTime start, DateTime end) {
    return '${formatEventDateLong(start)} - ${formatEventDateLong(end)}';
  }
}
