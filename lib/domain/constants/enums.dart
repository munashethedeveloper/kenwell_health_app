/// Common enums used throughout the application

/// Yes/No/N/A options for assessment questions
enum YesNoNA {
  na('N/A'),
  yes('Yes'),
  no('No');

  final String label;
  const YesNoNA(this.label);

  static YesNoNA? fromString(String? value) {
    if (value == null) return null;
    return YesNoNA.values.firstWhere(
      (e) => e.label == value,
      orElse: () => YesNoNA.na,
    );
  }
}

/// Yes/No options for binary questions
enum YesNo {
  yes('Yes'),
  no('No');

  final String label;
  const YesNo(this.label);

  static YesNo? fromString(String? value) {
    if (value == null) return null;
    return YesNo.values.firstWhere(
      (e) => e.label == value,
      orElse: () => YesNo.no,
    );
  }
}

/// Gender options
enum Gender {
  male('Male'),
  female('Female');

  final String label;
  const Gender(this.label);

  static Gender? fromString(String? value) {
    if (value == null) return null;
    return Gender.values.firstWhere(
      (e) => e.label == value,
      orElse: () => Gender.male,
    );
  }
}

/// Marital status options
enum MaritalStatus {
  single('Single'),
  widowed('Widowed'),
  married('Married'),
  divorced('Divorced');

  final String label;
  const MaritalStatus(this.label);

  static MaritalStatus? fromString(String? value) {
    if (value == null) return null;
    return MaritalStatus.values.firstWhere(
      (e) => e.label == value,
      orElse: () => MaritalStatus.single,
    );
  }
}

/// ID document type
enum IdDocumentType {
  id('ID'),
  passport('Passport');

  final String label;
  const IdDocumentType(this.label);

  static IdDocumentType? fromString(String? value) {
    if (value == null) return null;
    return IdDocumentType.values.firstWhere(
      (e) => e.label == value,
      orElse: () => IdDocumentType.id,
    );
  }
}

/// Citizenship status
enum CitizenshipStatus {
  saCitizen('SA Citizen'),
  permanentResident('Permanent Resident'),
  otherNationality('Other Nationality');

  final String label;
  const CitizenshipStatus(this.label);

  static CitizenshipStatus? fromString(String? value) {
    if (value == null) return null;
    return CitizenshipStatus.values.firstWhere(
      (e) => e.label == value,
      orElse: () => CitizenshipStatus.saCitizen,
    );
  }
}

/// Follow-up location options
enum FollowUpLocation {
  stateClinic('Referred to State clinic'),
  privateDoctor('Referred to Private doctor'),
  other('Other'),
  noFollowUp('No follow-up needed');

  final String label;
  const FollowUpLocation(this.label);

  static FollowUpLocation? fromString(String? value) {
    if (value == null) return null;
    return FollowUpLocation.values.firstWhere(
      (e) => e.label == value,
      orElse: () => FollowUpLocation.noFollowUp,
    );
  }
}

/// Wellness flow steps
enum WellnessStep {
  memberRegistration('member_registration'),
  currentEventDetails('current_event_details'),
  consent('consent'),
  healthScreeningsMenu('health_screenings_menu'),
  personalDetails('personal_details'),
  riskAssessment('risk_assessment'),
  hivTest('hiv_test'),
  hivResults('hiv_results'),
  tbTest('tb_test'),
  survey('survey');

  final String value;
  const WellnessStep(this.value);

  static WellnessStep? fromString(String? value) {
    if (value == null) return null;
    return WellnessStep.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WellnessStep.memberRegistration,
    );
  }
}

/// Screening identifiers
enum ScreeningType {
  consent('consent'),
  riskAssessment('risk_assessment'),
  hivTest('hiv_test'),
  hivResults('hiv_results'),
  tbTest('tb_test');

  final String value;
  const ScreeningType(this.value);

  static ScreeningType? fromString(String? value) {
    if (value == null) return null;
    return ScreeningType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ScreeningType.consent,
    );
  }
}

/// Extension to convert enum lists to string lists for dropdowns
extension EnumListExtension<T extends Enum> on List<T> {
  List<String> get labels {
    return map((e) {
      final dynamic enumValue = e;
      if (enumValue is YesNoNA) return enumValue.label;
      if (enumValue is YesNo) return enumValue.label;
      if (enumValue is Gender) return enumValue.label;
      if (enumValue is MaritalStatus) return enumValue.label;
      if (enumValue is IdDocumentType) return enumValue.label;
      if (enumValue is CitizenshipStatus) return enumValue.label;
      if (enumValue is FollowUpLocation) return enumValue.label;
      if (enumValue is WellnessStep) return enumValue.value;
      if (enumValue is ScreeningType) return enumValue.value;
      return e.toString();
    }).toList();
  }
}
