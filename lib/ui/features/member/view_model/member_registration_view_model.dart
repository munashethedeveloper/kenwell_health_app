import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/constants/enums.dart';
import 'package:kenwell_health_app/domain/constants/nationalities.dart';
import 'package:kenwell_health_app/domain/usecases/register_member_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/delete_member_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/load_members_usecase.dart';

class MemberDetailsViewModel extends ChangeNotifier {
  MemberDetailsViewModel({
    RegisterMemberUseCase? registerMemberUseCase,
    DeleteMemberUseCase? deleteMemberUseCase,
    LoadMembersUseCase? loadMembersUseCase,
  })  : _registerMemberUseCase =
            registerMemberUseCase ?? RegisterMemberUseCase(),
        _deleteMemberUseCase = deleteMemberUseCase ?? DeleteMemberUseCase(),
        _loadMembersUseCase = loadMembersUseCase ?? LoadMembersUseCase();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RegisterMemberUseCase _registerMemberUseCase;
  final DeleteMemberUseCase _deleteMemberUseCase;
  final LoadMembersUseCase _loadMembersUseCase;

  Member? savedMember;
  String? _eventId; // Store the event ID for linking member to event
  String? _eventTitle; // Store the event title for member_events record
  DateTime? _eventDate; // Store the event date for member_events record
  String? _eventVenue; // Store the event venue for member_events record
  String? _eventLocation; // Store the event location for member_events record

  // Member list management
  List<Member> _members = [];
  List<Member> get members => _members;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    notifyListeners();
  }

  /// Set the event ID for this member registration
  void setEventId(String? eventId) {
    _eventId = eventId;
  }

  /// Set the event ID and full event details for this member registration.
  /// Called from WellnessNavigator before navigating to the registration form
  /// so the resulting member_events record is populated with event metadata.
  void setEventDetails(
    String? eventId, {
    String? eventTitle,
    DateTime? eventDate,
    String? eventVenue,
    String? eventLocation,
  }) {
    _eventId = eventId;
    _eventTitle = eventTitle;
    _eventDate = eventDate;
    _eventVenue = eventVenue;
    _eventLocation = eventLocation;
  }

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
  final sacitizenNationalityController =
      TextEditingController(text: 'South Africa');

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
  final List<String> maritalStatusOptions = MaritalStatus.values.labels;

  final List<String> genderOptions = Gender.values.labels;

  final List<String> idDocumentOptions = IdDocumentType.values.labels;
  final List<String> medicalAidStatusOptions = YesNo.values.labels;

  final List<String> citizenshipOptions = CitizenshipStatus.values.labels;

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

  List<String> get nationalityOptions => Nationalities.all;

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

  //MemberDetailsViewModel(this._authService) {
  // idNumberController.addListener(_handleIdNumberInput);
  //}

  //void _handleIdNumberInput() {
  //final id = idNumberController.text;
  // if (id.length == 13 && Validators.validateSouthAfricanId(id) == null) {
  // dob = Validators.getDateOfBirthFromId(id);
  //dobController.text = DateFormat('dd/MM/yyyy').format(dob!);
  //gender = Validators.getGenderFromId(id);
  //notifyListeners();
  //}
  //}

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

  // Load all members - performs a one-time fetch
  // This is kept for manual refresh functionality
  // The stream subscription (_startListeningToUsers) provides continuous updates
  //Future<void> loadMembers() async {
  // _setLoading(true);
  // _errorMessage = null;

  // try {
  //   final fetchedMembers = await _authService.getAllMembers();
  //  _members = fetchedMembers;
  //  _isLoading = false;
  //   notifyListeners();
  //  } catch (e) {
  //    _setError('Failed to load members. Please try again.');
  //    debugPrint('Load members error: $e');
  //  }
  //}

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

    try {
      final member = Member(
        name: nameController.text,
        surname: surnameController.text,
        idNumber: idDocumentChoice == 'ID' ? idNumberController.text : null,
        passportNumber: idDocumentChoice == 'Passport'
            ? passportNumberController.text
            : null,
        idDocumentType: idDocumentChoice,
        dateOfBirth: dobController.text,
        gender: gender,
        maritalStatus: maritalStatus,
        nationality: citizenshipStatus == 'SA Citizen'
            ? 'South Africa'
            : selectedNationality,
        citizenshipStatus: citizenshipStatus,
        email: emailController.text.isEmpty ? null : emailController.text,
        cellNumber: cellNumberController.text,
        medicalAidStatus: medicalAidStatus,
        medicalAidName:
            medicalAidStatus == 'Yes' ? medicalAidNameController.text : null,
        medicalAidNumber:
            medicalAidStatus == 'Yes' ? medicalAidNumberController.text : null,
        eventId: _eventId,
      );

      // Delegate multi-repo orchestration (local DB + Firestore + member_events)
      // to the use case so this ViewModel only owns form state.
      savedMember = await _registerMemberUseCase(
        member,
        eventId: _eventId,
        eventTitle: _eventTitle,
        eventDate: _eventDate,
        eventVenue: _eventVenue,
        eventLocation: _eventLocation,
      );
    } catch (e) {
      debugPrint('Error saving member: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Load all members
  Future<void> loadMembers() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final fetchedMembers = await _loadMembersUseCase();
      _members = fetchedMembers;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load members. Please try again.');
      debugPrint('Load members error: $e');
    }
  }

  // Delete member
  Future<bool> deleteMember(String memberId, String memberName) async {
    try {
      _setLoading(true);
      await _deleteMemberUseCase(memberId);

      // Remove from local list
      _members.removeWhere((m) => m.id == memberId);

      _setSuccess('$memberName deleted successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete $memberName');
      debugPrint('Delete member error: $e');
      return false;
    }
  }

  // Save member (used by create member section)
  Future<bool> saveMember() async {
    try {
      await saveLocally();
      return true;
    } catch (e) {
      debugPrint('Save member error: $e');
      return false;
    }
  }

  // Reset form
  void resetForm() {
    nameController.clear();
    surnameController.clear();
    dobController.clear();
    idNumberController.clear();
    passportNumberController.clear();
    medicalAidNameController.clear();
    medicalAidNumberController.clear();
    emailController.clear();
    cellNumberController.clear();
    personalNumberController.clear();

    maritalStatus = null;
    gender = null;
    idDocumentChoice = 'ID';
    medicalAidStatus = null;
    citizenshipStatus = null;
    selectedNationality = null;

    notifyListeners();
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Get filtered members
  List<Member> get filteredMembers {
    var filtered = _members;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((member) {
        final fullName = '${member.name} ${member.surname}'.toLowerCase();
        final email = member.email?.toLowerCase() ?? '';
        return fullName.contains(query) || email.contains(query);
      }).toList();
    }

    // Apply gender filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((member) {
        return member.gender == _selectedFilter;
      }).toList();
    }

    return filtered;
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
