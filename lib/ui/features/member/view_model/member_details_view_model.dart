import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/utils/validators.dart';

class MemberDetailsViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final screeningSiteController = TextEditingController();
  final dateController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  // final initialsController = TextEditingController();
  final dobController = TextEditingController();
  final idNumberController = TextEditingController();
  final passportNumberController = TextEditingController();
  // nationalityController removed - now using selectedNationality String
  final medicalAidNameController = TextEditingController();
  final medicalAidNumberController = TextEditingController();
  final emailController = TextEditingController();
  final cellNumberController = TextEditingController();
  // final alternateContactNumberController = TextEditingController();
  final personalNumberController = TextEditingController();
  
  // Read-only controller for SA Citizen nationality display
  final sacitizenNationalityController = TextEditingController(text: 'South Africa');

  // Dropdown values
  String? maritalStatus;
  String? gender;
  String idDocumentChoice = 'ID';
  String? medicalAidStatus;
  
  // Citizenship status
  String? citizenshipStatus;

  // NEW: Alternate number
  //String? hasAlternateNumber;
  //final List<String> hasAlternateNumberOptions = ['Yes', 'No'];

  // Dropdown options
  final List<String> maritalStatusOptions = [
    'Single',
    'Widowed',
    'Married',
    'Divorced'
  ];

  final List<String> genderOptions = ['Male', 'Female'];

  final List<String> idDocumentOptions = ['ID', 'Passport'];
  final List<String> medicalAidStatusOptions = ['Yes', 'No'];
  
  final List<String> citizenshipOptions = [
    'SA Citizen',
    'Permanent Resident',
    'Other Nationality'
  ];

  String? selectedNationality;

  void setSelectedNationality(String? value) {
    if (selectedNationality != value) {
      selectedNationality = value;
      //nationalityController.text = value ?? '';
      notifyListeners();
    }
  }
  
  void setCitizenshipStatus(String? value) {
    if (citizenshipStatus != value) {
      citizenshipStatus = value;
      
      // Auto-set nationality for SA Citizen
      if (value == 'SA Citizen') {
        selectedNationality = 'South Africa';
      } else if (value == 'Permanent Resident') {
        // Keep current nationality or allow user to select
      } else if (value == 'Other Nationality') {
        // Clear nationality for user to select
        if (selectedNationality == 'South Africa') {
          selectedNationality = null;
        }
      }
      
      notifyListeners();
    }
  }

  final List<String> nationalityOptions = [
    //List of All Countries in the World
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola",
    "Antigua and Barbuda",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Botswana",
    "Brazil",
    "Brunei",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cabo Verde",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Central African Republic",
    "Chad",
    "Chile",
    "China",
    "Colombia",
    "Comoros",
    "Congo (Congo-Brazzaville)",
    "Costa Rica",
    "Croatia",
    "Cuba",
    "Cyprus",
    "Czechia",
    "Democratic Republic of the Congo",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "Equatorial Guinea",
    "Eritrea",
    "Estonia",
    "Eswatini",
    "Ethiopia",
    "Fiji",
    "Finland",
    "France",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Greece",
    "Grenada",
    "Guatemala",
    "Guinea",
    "Guinea-Bissau",
    "Guyana",
    "Haiti",
    "Honduras",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Jamaica",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kiribati",
    "Kuwait",
    "Kyrgyzstan",
    "Laos",
    "Latvia",
    "Lebanon",
    "Lesotho",
    "Liberia",
    "Libya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Maldives",
    "Mali",
    "Malta",
    "Marshall Islands",
    "Mauritania",
    "Mauritius",
    "Mexico",
    "Micronesia",
    "Moldova",
    "Monaco",
    "Mongolia",
    "Montenegro",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Namibia",
    "Nauru",
    "Nepal",
    "Netherlands",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "North Korea",
    "North Macedonia",
    "Norway",
    "Oman",
    "Pakistan",
    "Palau",
    "Panama",
    "Papua New Guinea",
    "Paraguay",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Qatar",
    "Romania",
    "Russia",
    "Rwanda",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Saint Vincent and the Grenadines",
    "Samoa",
    "San Marino",
    "Sao Tome and Principe",
    "Saudi Arabia",
    "Senegal",
    "Serbia",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "Solomon Islands",
    "Somalia",
    "South Africa",
    "South Korea",
    "South Sudan",
    "Spain",
    "Sri Lanka",
    "Sudan",
    "Suriname",
    "Sweden",
    "Switzerland",
    "Syria",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Timor-Leste",
    "Togo",
    "Tonga",
    "Trinidad and Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Tuvalu",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "United States of America",
    "Uruguay",
    "Uzbekistan",
    "Vanuatu",
    "Vatican City",
    "Venezuela",
    "Vietnam",
    "Yemen",
    "Zambia",
    "Zimbabwe"
  ];

//DATE OF BIRTH PARSING AND AGE CALCULATION
  DateTime? dob; // store parsed DOB

  void setDob(String dobString) {
    try {
      dob = DateFormat('dd/MM/yyyy').parse(dobString);
      dobController.text = dobString;
      notifyListeners();
    } catch (_) {
      // handle or log error
    }
  }

  int get userAge {
    if (dob == null) return 0;

    final today = DateTime.now();
    int age = today.year - dob!.year;

    // Adjust if birthday has not happened yet this year
    if (today.month < dob!.month ||
        (today.month == dob!.month && today.day < dob!.day)) {
      age--;
    }

    return age;
  }

  bool get isMale => gender == "Male";
  bool get isMaleOver40 => isMale && userAge >= 40;

// Submission state
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  MemberDetailsViewModel() {
    idNumberController.addListener(_handleIdNumberInput);
  }

  void _handleIdNumberInput() {
    final id = idNumberController.text;
    if (id.length == 13 && Validators.validateSouthAfricanId(id) == null) {
      dob = Validators.getDateOfBirthFromId(id);
      dobController.text = DateFormat('dd/MM/yyyy').format(dob!);
      gender = Validators.getGenderFromId(id);
      notifyListeners();
    }
  }

  // --- Dropdown setters ---
  void setMaritalStatus(String? value) {
    if (maritalStatus != value) {
      maritalStatus = value;
      notifyListeners();
    }
  }

  void setGender(String? value) {
    if (gender != value) {
      gender = value;
      notifyListeners();
    }
  }

  void setIdDocumentChoice(String? value) {
    if (value == null || idDocumentChoice == value) return;
    idDocumentChoice = value;
    if (idDocumentChoice == 'ID') passportNumberController.clear();
    if (idDocumentChoice == 'Passport') idNumberController.clear();
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

  // NEW: Alternate Number setter
  //void setHasAlternateNumber(String? value) {
  //if (hasAlternateNumber == value) return;
  // hasAlternateNumber = value;

  // if (value == 'No') {
  //   alternateContactNumberController.clear();
  // }

  // notifyListeners();
  //}

  // NEW: Show/hide alternate contact number field
  // bool get showAlternateNumberField => hasAlternateNumber == 'Yes';

  bool get showIdField => idDocumentChoice == 'ID';
  bool get showPassportField => idDocumentChoice == 'Passport';
  bool get showMedicalAidFields => medicalAidStatus == 'Yes';
  bool get showIdentificationFields => citizenshipStatus != null;

  bool get isFormValid =>
      formKey.currentState?.validate() == true &&
      maritalStatus != null &&
      gender != null &&
      medicalAidStatus != null &&
      citizenshipStatus != null &&
      (showIdField
          ? idNumberController.text.isNotEmpty
          : passportNumberController.text.isNotEmpty) &&
      (!showMedicalAidFields ||
          (medicalAidNameController.text.isNotEmpty &&
              medicalAidNumberController.text.isNotEmpty));

  Map<String, dynamic> toMap() => {
        'screeningSite': screeningSiteController.text,
        'date': dateController.text,
        'name': nameController.text,
        'surname': surnameController.text,
        // 'initials': initialsController.text,
        'dateOfBirth': dobController.text,
        'idNumber': idNumberController.text,
        'passportNumber': passportNumberController.text,
        'idDocumentChoice': idDocumentChoice,
        'nationality': citizenshipStatus == 'SA Citizen' 
            ? 'South Africa' 
            : selectedNationality ?? '',
        'citizenshipStatus': citizenshipStatus,
        'medicalAidName': medicalAidNameController.text,
        'medicalAidNumber': medicalAidNumberController.text,
        'medicalAidStatus': medicalAidStatus,
        'email': emailController.text,
        'cellNumber': cellNumberController.text,
        //  'alternateContactNumber': alternateContactNumberController.text,
        'personalNumber': personalNumberController.text,
        'maritalStatus': maritalStatus,
        'gender': gender,
        // 'hasAlternateNumber': hasAlternateNumber,
      };

  Future<void> saveLocally() async {
    _isSubmitting = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var c in [
      screeningSiteController,
      dateController,
      nameController,
      surnameController,
      //initialsController,
      dobController,
      idNumberController,
      passportNumberController,
      // nationalityController removed
      sacitizenNationalityController,
      medicalAidNameController,
      medicalAidNumberController,
      emailController,
      cellNumberController,
      //alternateContactNumberController,
      personalNumberController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
