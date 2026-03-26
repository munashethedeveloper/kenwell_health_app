import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/enums/service_type.dart';
import '../../../../domain/enums/additional_service_type.dart';
import '../../../../utils/extensions.dart';

/// ViewModel that owns all *form* state for the Add / Edit Event screen.
///
/// Responsibilities:
///   - Holding the [TextEditingController]s for every form field.
///   - Tracking dropdown / option selections (province, medicalAid, etc.).
///   - Pre-populating the form when editing an existing [WellnessEvent].
///   - Building a [WellnessEvent] from the current form state.
///
/// This class is intentionally separate from [EventViewModel] which manages
/// the *list* of events and their CRUD operations.  Keeping these two
/// concerns in separate ViewModels honours the Single Responsibility Principle
/// and makes both classes easier to test independently.
class EventFormViewModel extends ChangeNotifier {
  // ── Form keys ─────────────────────────────────────────────────────────────
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ── Text controllers ──────────────────────────────────────────────────────
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
  final nursesController = TextEditingController();
  final setUpTimeController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final strikeDownTimeController = TextEditingController();
  final dateController = TextEditingController();

  // ── Dropdown / option fields ──────────────────────────────────────────────
  String medicalAid = 'No';
  String? province;
  String coordinatorsOption = 'No';
  int coordinatorsCount = 0;
  String mobileBoothsOption = 'No';
  int mobileBoothsCount = 0;
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

  // ── Service selections ────────────────────────────────────────────────────
  final Set<ServiceType> _selectedServices = {};
  final Set<AdditionalServiceType> _selectedAdditionalServices = {};

  List<String> get availableServiceOptions =>
      ServiceTypeExtension.allDisplayNames;
  List<String> get availableAdditionalServiceOptions =>
      AdditionalServiceTypeExtension.allDisplayNames;

  Set<String> get selectedServices =>
      _selectedServices.map((e) => e.displayName).toSet();
  Set<String> get selectedAdditionalServices =>
      _selectedAdditionalServices.map((e) => e.displayName).toSet();

  bool isServiceSelected(String service) =>
      _selectedServices.any((s) => s.displayName == service);

  bool isAdditionalServiceSelected(String service) =>
      _selectedAdditionalServices.any((s) => s.displayName == service);

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

  String get servicesRequested =>
      ServiceTypeConverter.toStorageString(_selectedServices);
  String get additionalServicesRequested =>
      AdditionalServiceTypeConverter.toStorageString(
          _selectedAdditionalServices);

  // ── Backward-compat getters ───────────────────────────────────────────────
  String get coordinators => coordinatorsOption;
  String get mobileBooths => mobileBoothsOption;

  // ── Province ──────────────────────────────────────────────────────────────
  void updateProvince(String value) {
    province = value;
    notifyListeners();
  }

  // ── Time setter ───────────────────────────────────────────────────────────
  void setTime(TextEditingController controller, TimeOfDay time) {
    controller.text = time.toHHmm();
    notifyListeners();
  }

  // ── Pre-populate from an existing event ───────────────────────────────────
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
        '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
    mobileBoothsOption = e.mobileBooths;
    nursesCount = e.nurses;
    nursesOption = e.nurses > 0 ? 'Yes' : 'No';
    _setServicesFromString(e.servicesRequested);
    medicalAid = e.medicalAid;
    notifyListeners();
  }

  // ── Build a WellnessEvent from form state ─────────────────────────────────
  WellnessEvent buildEvent(DateTime date) {
    return WellnessEvent(
      title: _sanitize(titleController.text),
      date: date,
      townCity: _sanitize(townCityController.text),
      venue: _sanitize(venueController.text),
      address: _sanitize(addressController.text),
      province: _sanitize(province),
      onsiteContactFirstName: _sanitize(onsiteContactFirstNameController.text),
      onsiteContactLastName: _sanitize(onsiteContactLastNameController.text),
      onsiteContactNumber: _sanitize(onsiteNumberController.text),
      onsiteContactEmail: _sanitize(onsiteEmailController.text),
      aeContactFirstName: _sanitize(aeContactFirstNameController.text),
      aeContactLastName: _sanitize(aeContactLastNameController.text),
      aeContactNumber: _sanitize(aeNumberController.text),
      aeContactEmail: _sanitize(aeEmailController.text),
      servicesRequested: servicesRequested,
      expectedParticipation: _parseInt(expectedParticipationController.text),
      nurses: nursesCount,
      setUpTime: _sanitize(setUpTimeController.text),
      startTime: _sanitize(startTimeController.text),
      endTime: _sanitize(endTimeController.text),
      strikeDownTime: _sanitize(strikeDownTimeController.text),
      mobileBooths: mobileBoothsOption,
      medicalAid: medicalAid,
    );
  }

  // ── Check if any field is filled (unsaved-changes guard) ──────────────────
  bool get hasUnsavedChanges =>
      titleController.text.isNotEmpty ||
      venueController.text.isNotEmpty ||
      addressController.text.isNotEmpty ||
      onsiteContactFirstNameController.text.isNotEmpty ||
      aeContactFirstNameController.text.isNotEmpty;

  // ── Clear / reset ─────────────────────────────────────────────────────────
  void clearForm() {
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
    _selectedServices.clear();
    _selectedAdditionalServices.clear();
    medicalAid = 'No';
    province = null;
    mobileBoothsOption = 'No';
    nursesOption = 'No';
    nursesCount = 0;
    notifyListeners();
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
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

  // ── Private helpers ───────────────────────────────────────────────────────
  String _sanitize(String? input) => input?.trim() ?? '';

  int _parseInt(String? input, {int defaultValue = 0}) {
    if (input == null || input.isEmpty) return defaultValue;
    return int.tryParse(input.trim()) ?? defaultValue;
  }

  void _setServicesFromString(String raw) {
    _selectedServices.clear();
    _selectedServices.addAll(ServiceTypeConverter.fromStorageString(raw));
  }
}
