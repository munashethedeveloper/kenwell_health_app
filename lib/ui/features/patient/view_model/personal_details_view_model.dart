import 'package:flutter/material.dart';

class PersonalDetailsViewModel extends ChangeNotifier {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final screeningSiteController = TextEditingController();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final initialsController = TextEditingController();
  final idNumberController = TextEditingController();
  final nationalityController = TextEditingController();
  final medicalAidNameController = TextEditingController();
  final medicalAidNumberController = TextEditingController();
  final emailController = TextEditingController();
  final cellNumberController = TextEditingController();
  final personalNumberController = TextEditingController();
  final divisionController = TextEditingController();
  final positionController = TextEditingController();
  // final regionController = TextEditingController();

  // Dropdown values
  String? maritalStatus;
  String? gender;
  String? employmentStatus;
  String? provinces;

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

  // Form validation
  bool get isFormValid =>
      formKey.currentState?.validate() == true &&
      maritalStatus != null &&
      gender != null &&
      employmentStatus != null &&
      provinces != null;

  // Convert to Map
  Map<String, dynamic> toMap() => {
        'screeningSite': screeningSiteController.text,
        'date': dateController.text,
        'name': nameController.text,
        'surname': surnameController.text,
        'initials': initialsController.text,
        'idNumber': idNumberController.text,
        'nationality': nationalityController.text,
        'medicalAidName': medicalAidNameController.text,
        'medicalAidNumber': medicalAidNumberController.text,
        'email': emailController.text,
        'cellNumber': cellNumberController.text,
        'personalNumber': personalNumberController.text,
        'division': divisionController.text,
        'position': positionController.text,
        'region': provinces,
        'maritalStatus': maritalStatus,
        'gender': gender,
        'employmentStatus': employmentStatus,
      };

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
      idNumberController,
      nationalityController,
      medicalAidNameController,
      medicalAidNumberController,
      emailController,
      cellNumberController,
      personalNumberController,
      divisionController,
      positionController,
      // regionController,
    ].forEach((c) => c.dispose());
    super.dispose();
  }
}
