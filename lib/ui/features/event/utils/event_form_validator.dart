import '../../../../utils/validators.dart';
import '../view_model/event_view_model.dart';

/// Validator for Event form fields
class EventFormValidator {
  /// Validates all required fields in the event form
  /// Returns a list of invalid field names, or empty list if all valid
  static List<String> validateEventForm(EventViewModel viewModel) {
    final invalidFields = <String>[];

    // Basic Info
    if (_isEmpty(viewModel.titleController.text)) {
      invalidFields.add('Event Title');
    }
    if (_isEmpty(viewModel.venueController.text)) {
      invalidFields.add('Venue');
    }
    if (_isEmpty(viewModel.addressController.text)) {
      invalidFields.add('Address');
    }

    // Onsite Contact
    if (_isEmpty(viewModel.onsiteContactFirstNameController.text)) {
      invalidFields.add('Onsite Contact First Name');
    }
    if (_isEmpty(viewModel.onsiteContactLastNameController.text)) {
      invalidFields.add('Onsite Contact Last Name');
    }
    if (Validators.validateSouthAfricanPhoneNumber(
            viewModel.onsiteNumberController.text) !=
        null) {
      invalidFields.add('Onsite Contact Number');
    }
    if (Validators.validateEmail(viewModel.onsiteEmailController.text) !=
        null) {
      invalidFields.add('Onsite Contact Email');
    }

    // AE Contact
    if (_isEmpty(viewModel.aeContactFirstNameController.text)) {
      invalidFields.add('AE Contact First Name');
    }
    if (_isEmpty(viewModel.aeContactLastNameController.text)) {
      invalidFields.add('AE Contact Last Name');
    }
    if (Validators.validateSouthAfricanPhoneNumber(
            viewModel.aeNumberController.text) !=
        null) {
      invalidFields.add('AE Contact Number');
    }
    if (Validators.validateEmail(viewModel.aeEmailController.text) != null) {
      invalidFields.add('AE Contact Email');
    }

    // Options
    if (_isEmpty(viewModel.medicalAid)) {
      invalidFields.add('Medical Aid');
    }
    if (_isEmpty(viewModel.coordinatorsOption)) {
      invalidFields.add('Coordinators');
    }
    if (_isEmpty(viewModel.mobileBoothsOption)) {
      invalidFields.add('Mobile Booths');
    }

    // Services
    if (viewModel.selectedServices.isEmpty) {
      invalidFields.add('Services Requested');
    }

    // Time Details
    if (_isEmpty(viewModel.setUpTimeController.text)) {
      invalidFields.add('Setup Time');
    }
    if (_isEmpty(viewModel.startTimeController.text)) {
      invalidFields.add('Start Time');
    }
    if (_isEmpty(viewModel.endTimeController.text)) {
      invalidFields.add('End Time');
    }
    if (_isEmpty(viewModel.strikeDownTimeController.text)) {
      invalidFields.add('Strike Down Time');
    }

    return invalidFields;
  }

  // Checks if a string is null or empty
  static bool _isEmpty(String? value) {
    return value == null || value.isEmpty;
  }
}
