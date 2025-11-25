import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/wellness_event.dart';

class PersonalDetailsViewModel extends ChangeNotifier {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final screeningSiteController = TextEditingController();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final initialsController = TextEditingController();
  final dobController = TextEditingController();
  final idNumberController = TextEditingController();
  final passportNumberController = TextEditingController();
  final nationalityController = TextEditingController();
  final medicalAidNameController = TextEditingController();
  final medicalAidNumberController = TextEditingController();
  final emailController = TextEditingController();
  final cellNumberController = TextEditingController();
  final alternateContactNumberController = TextEditingController();
  final personalNumberController = TextEditingController();
  final divisionController = TextEditingController();
  final positionController = TextEditingController();
  final employeeNumberController = TextEditingController();
  // final regionController = TextEditingController();

  // Dropdown values
  String? maritalStatus;
  String? gender;
  String? employmentStatus;
  String? provinces;
  String idDocumentChoice = 'ID';
  String? medicalAidStatus;

  // Dropdown options
  final List<String> maritalStatusOptions = [
    'Single',
    'Widowed',
    'Married',
    'Divorced'
  ];

  final List<String> provinceOptions = [
    'Gauteng',
    'Western Cape',
    'KwaZulu-Natal',
    'Eastern Cape',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Free State',
    'Northern Cape'
  ];

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> employmentStatusOptions = [
    'Permanent fulltime',
    'Contract – limited duration',
    'Outside contractor'
  ];
  final List<String> idDocumentOptions = ['ID', 'Passport'];
  final List<String> medicalAidStatusOptions = ['Yes', 'No'];

  // Submission state
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Setters with notify
  void setMaritalStatus(String? value) {
    if (maritalStatus != value) {
      maritalStatus = value;
      notifyListeners();
    }
  }

  void setProvince(String? value) {
    if (provinces != value) {
      provinces = value;
      notifyListeners();
    }
  }

  void setGender(String? value) {
    if (gender != value) {
      gender = value;
      notifyListeners();
    }
  }

  void setEmploymentStatus(String? value) {
    if (employmentStatus != value) {
      employmentStatus = value;
      notifyListeners();
    }
  }

  void setIdDocumentChoice(String? value) {
    if (value == null || idDocumentChoice == value) return;
    idDocumentChoice = value;
    if (idDocumentChoice == 'ID') {
      passportNumberController.clear();
    } else {
      idNumberController.clear();
    }
    notifyListeners();
  }

  void setMedicalAidStatus(String? value) {
    if (medicalAidStatus == value) return;
    medicalAidStatus = value;
    if (medicalAidStatus == 'No') {
      medicalAidNameController.clear();
      medicalAidNumberController.clear();
    }
    notifyListeners();
  }

  bool get showIdField => idDocumentChoice == 'ID';
  bool get showPassportField => idDocumentChoice == 'Passport';
  bool get showMedicalAidFields => medicalAidStatus == 'Yes';

  // Form validation
  bool get isFormValid =>
      formKey.currentState?.validate() == true &&
      maritalStatus != null &&
      gender != null &&
      employmentStatus != null &&
      provinces != null &&
      medicalAidStatus != null &&
      (showIdField
          ? idNumberController.text.isNotEmpty
          : passportNumberController.text.isNotEmpty) &&
      (!showMedicalAidFields ||
          (medicalAidNameController.text.isNotEmpty &&
              medicalAidNumberController.text.isNotEmpty));

  // Convert to Map
  Map<String, dynamic> toMap() => {
        'screeningSite': screeningSiteController.text,
        'date': dateController.text,
        'name': nameController.text,
        'surname': surnameController.text,
        'initials': initialsController.text,
        'dateOfBirth': dobController.text,
        'idNumber': idNumberController.text,
        'passportNumber': passportNumberController.text,
        'idDocumentChoice': idDocumentChoice,
        'nationality': nationalityController.text,
        'medicalAidName': medicalAidNameController.text,
        'medicalAidNumber': medicalAidNumberController.text,
        'medicalAidStatus': medicalAidStatus,
        'email': emailController.text,
        'cellNumber': cellNumberController.text,
        'alternateContactNumber': alternateContactNumberController.text,
        'personalNumber': personalNumberController.text,
        'division': divisionController.text,
        'position': positionController.text,
        'employeeNumber': employeeNumberController.text,
        'region': provinces,
        'maritalStatus': maritalStatus,
        'gender': gender,
        'employmentStatus': employmentStatus,
      };

  void prefillFromEvent(WellnessEvent event) {
    screeningSiteController.text = event.venue;
    dateController.text = DateFormat('yyyy-MM-dd').format(event.date);
    nameController.text = event.onsiteContactFirstName;
    surnameController.text = event.onsiteContactLastName;
    cellNumberController.text = event.onsiteContactNumber;
    alternateContactNumberController.text = event.aeContactNumber;
    emailController.text = event.onsiteContactEmail;
    medicalAidStatus = event.medicalAid.isEmpty ? null : event.medicalAid;
    medicalAidNameController.text =
        event.medicalAid == 'Yes' ? event.medicalAid : '';
    medicalAidNumberController.text = '';
    notifyListeners();
  }

  void reset() {
    for (final controller in [
      screeningSiteController,
      dateController,
      nameController,
      surnameController,
      initialsController,
      dobController,
      idNumberController,
      passportNumberController,
      nationalityController,
      medicalAidNameController,
      medicalAidNumberController,
      emailController,
      cellNumberController,
      alternateContactNumberController,
      personalNumberController,
      divisionController,
      positionController,
      employeeNumberController,
    ]) {
      controller.clear();
    }
    maritalStatus = null;
    provinces = null;
    gender = null;
    employmentStatus = null;
    medicalAidStatus = null;
    idDocumentChoice = 'ID';
    notifyListeners();
  }

  // Simulate saving
  Future<void> saveLocally() async {
    _isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    [
      screeningSiteController,
      dateController,
      nameController,
      surnameController,
      initialsController,
      dobController,
      idNumberController,
      passportNumberController,
      nationalityController,
      medicalAidNameController,
      medicalAidNumberController,
      emailController,
      cellNumberController,
      alternateContactNumberController,
      personalNumberController,
      divisionController,
      positionController,
      employeeNumberController,
      // regionController,
    ].forEach((c) => c.dispose());
    super.dispose();
  }
}
