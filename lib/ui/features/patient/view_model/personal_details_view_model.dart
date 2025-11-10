import 'package:flutter/material.dart';

class PersonalDetailsViewModel extends ChangeNotifier {
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
  final regionController = TextEditingController();

  // Dropdown values
  String? maritalStatus;
  String? gender;
  String? firstTimeTested;
  String? employmentStatus;

  final List<String> maritalStatusOptions = [
    'Single',
    'Widowed',
    'Married',
    'Divorced',
  ];
  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> firstTimeTestedOptions = ['Yes', 'No'];
  final List<String> employmentStatusOptions = [
    'Permanent fulltime',
    'Contract – limited duration',
    'Outside contractor',
  ];

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get isFormValid =>
      screeningSiteController.text.isNotEmpty &&
      dateController.text.isNotEmpty &&
      nameController.text.isNotEmpty &&
      surnameController.text.isNotEmpty &&
      initialsController.text.isNotEmpty &&
      idNumberController.text.isNotEmpty &&
      nationalityController.text.isNotEmpty &&
      medicalAidNameController.text.isNotEmpty &&
      medicalAidNumberController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      cellNumberController.text.isNotEmpty &&
      personalNumberController.text.isNotEmpty &&
      divisionController.text.isNotEmpty &&
      positionController.text.isNotEmpty &&
      regionController.text.isNotEmpty &&
      maritalStatus != null &&
      gender != null &&
      firstTimeTested != null &&
      employmentStatus != null;

  /// Convert personal details to a Map for submission
  Map<String, dynamic> toMap() {
    return {
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
      'region': regionController.text,
      'maritalStatus': maritalStatus,
      'gender': gender,
      'firstTimeTested': firstTimeTested,
      'employmentStatus': employmentStatus,
    };
  }

  Future<void> saveLocally() async {
    _isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    screeningSiteController.dispose();
    dateController.dispose();
    nameController.dispose();
    surnameController.dispose();
    initialsController.dispose();
    idNumberController.dispose();
    nationalityController.dispose();
    medicalAidNameController.dispose();
    medicalAidNumberController.dispose();
    emailController.dispose();
    cellNumberController.dispose();
    personalNumberController.dispose();
    divisionController.dispose();
    positionController.dispose();
    regionController.dispose();
    super.dispose();
  }
}
