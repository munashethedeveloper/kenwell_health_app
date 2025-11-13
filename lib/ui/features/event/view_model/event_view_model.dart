import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';

class EventViewModel extends ChangeNotifier {
  // Controllers
  final dateController = TextEditingController();
  final titleController = TextEditingController();
  final venueController = TextEditingController();
  final addressController = TextEditingController();
  final onsiteContactController = TextEditingController();
  final onsiteNumberController = TextEditingController();
  final onsiteEmailController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  // Dropdowns
  String medicalAid = 'No';
  String nonMembers = 'No';
  String servicesRequested = 'HRA';

  DateTime? selectedDate;

  void loadEvent(WellnessEvent event) {
    selectedDate = event.date;
    dateController.text = DateFormat('yyyy-MM-dd').format(event.date);
    titleController.text = event.title;
    venueController.text = event.venue;
    addressController.text = event.address;
    onsiteContactController.text = event.onsiteContact;
    onsiteNumberController.text = event.onsiteNumber;
    onsiteEmailController.text = event.onsiteEmail;
    startTimeController.text = event.startTime;
    endTimeController.text = event.endTime;
    medicalAid = event.medicalAid;
    nonMembers = event.nonMembers;
    servicesRequested = event.servicesRequested;
    notifyListeners();
  }

  void setMedicalAid(String value) {
    medicalAid = value;
    notifyListeners();
  }

  void setNonMembers(String value) {
    nonMembers = value;
    notifyListeners();
  }

  void setServicesRequested(String value) {
    servicesRequested = value;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time, BuildContext context) {
    startTimeController.text = time.format(context);
    notifyListeners();
  }

  void setEndTime(TimeOfDay time, BuildContext context) {
    endTimeController.text = time.format(context);
    notifyListeners();
  }

  void saveEvent() {
    final event = WellnessEvent(
      date: DateTime.tryParse(dateController.text) ?? DateTime.now(),
      title: titleController.text,
      venue: venueController.text,
      address: addressController.text,
      onsiteContact: onsiteContactController.text,
      onsiteNumber: onsiteNumberController.text,
      onsiteEmail: onsiteEmailController.text,
      startTime: startTimeController.text,
      endTime: endTimeController.text,
      medicalAid: medicalAid,
      nonMembers: nonMembers,
      servicesRequested: servicesRequested,
    );

    // Here you can call your repository to persist the event
    // For example: _eventRepository.saveEvent(event);

    notifyListeners();
  }

  @override
  void dispose() {
    dateController.dispose();
    titleController.dispose();
    venueController.dispose();
    addressController.dispose();
    onsiteContactController.dispose();
    onsiteNumberController.dispose();
    onsiteEmailController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}
