import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/member_registration_view_model.dart';

class MemberDetailsScreen extends StatelessWidget {
  final MemberDetailsViewModel viewModel;
  final VoidCallback onNext;
  final PreferredSizeWidget? appBar;

  const MemberDetailsScreen({
    super.key,
    required this.viewModel,
    required this.onNext,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<MemberDetailsViewModel>(
        builder: (context, vm, _) {
          return KenwellFormPage(
            title: 'Member Registration Form',
            sectionTitle: 'Section A: Member Registration',
            formKey: vm.formKey,
            appBar: appBar,
            children: [
              KenwellFormCard(
                title: 'Basic Information',
                child: _buildPersonalInfoSection(vm),
              ),
              const SizedBox(height: 24),
              KenwellFormCard(
                title: 'Contact Information',
                child: _buildContactInfoSection(vm),
              ),
              const SizedBox(height: 24),
              KenwellFormCard(
                title: 'Identification Information',
                child: _buildIdentificationInfoSection(vm),
              ),
              const SizedBox(height: 24),
              KenwellFormCard(
                title: 'Medical Aid Information',
                child: _buildMedicalAidSection(vm),
              ),
              const SizedBox(height: 24),
              _buildNavigationButtons(context, vm),
            ],
          );
        },
      ),
    );
  }

  // ===== Sections =====
  Widget _buildPersonalInfoSection(MemberDetailsViewModel vm) {
    return Column(children: [
      KenwellTextField(
        label: 'Name',
        hintText: 'Enter name',
        controller: vm.nameController,
        inputFormatters: AppTextInputFormatters.lettersOnly(allowHyphen: true),
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Please enter Name' : null,
      ),
      KenwellTextField(
        label: 'Surname',
        hintText: 'Enter surname',
        controller: vm.surnameController,
        inputFormatters: AppTextInputFormatters.lettersOnly(allowHyphen: true),
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Please enter Surname' : null,
      ),
      KenwellDropdownField<String>(
        label: 'Marital Status',
        value: vm.maritalStatus,
        items: vm.maritalStatusOptions,
        onChanged: vm.setMaritalStatus,
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Select Marital Status' : null,
      ),
    ]);
  }

  Widget _buildContactInfoSection(MemberDetailsViewModel vm) {
    return Column(
      children: [
        KenwellTextField(
          label: 'Email Address',
          hintText: 'Enter email address',
          controller: vm.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        KenwellTextField(
          label: 'Cell Number',
          hintText: 'Enter cell number',
          controller: vm.cellNumberController,
          keyboardType: TextInputType.phone,
          inputFormatters: [AppTextInputFormatters.saPhoneNumberFormatter()],
          validator: Validators.validateSouthAfricanPhoneNumber,
        ),
      ],
    );
  }

  Widget _buildIdentificationInfoSection(MemberDetailsViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radio buttons for citizenship status
        const Text(
          'Citizenship Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            RadioListTile<String>(
              value: 'SA Citizen',
              groupValue: vm.citizenshipStatus,
              onChanged: (value) => vm.setCitizenshipStatus(value),
              title: const Text('SA Citizen'),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              value: 'Permanent Resident',
              groupValue: vm.citizenshipStatus,
              onChanged: (value) => vm.setCitizenshipStatus(value),
              title: const Text('Permanent Resident'),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              value: 'Other Nationality',
              groupValue: vm.citizenshipStatus,
              onChanged: (value) => vm.setCitizenshipStatus(value),
              title: const Text('Other Nationality'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Nationality field - read-only for SA Citizens, editable for others
        if (vm.citizenshipStatus == 'SA Citizen')
          KenwellTextField(
            label: 'Nationality',
            hintText: 'South Africa',
            controller: vm.sacitizenNationalityController,
            readOnly: true,
            enabled: false,
          )
        else
          DropdownSearch<String>(
            items: (filter, infiniteScrollProps) async => vm.nationalityOptions,
            selectedItem: vm.selectedNationality,
            popupProps: const PopupProps.dialog(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Search Nationality',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF757575)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: Color(0xFF201C58),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            decoratorProps: DropDownDecoratorProps(
              decoration: KenwellFormStyles.decoration(
                label: 'Nationality',
                hint: 'Select Nationality',
              ),
            ),
            onChanged: (value) => vm.setSelectedNationality(value),
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please select Nationality'
                : null,
          ),

        const SizedBox(height: 16),

        // Identification fields
        KenwellDropdownField<String>(
          label: 'Identification Type',
          value: vm.idDocumentChoice,
          items: vm.idDocumentOptions,
          onChanged: vm.setIdDocumentChoice,
          validator: (val) => (val == null || val.isEmpty)
              ? 'Select Identification Type'
              : null,
        ),
        if (vm.showIdField)
          KenwellTextField(
            label: 'RSA ID Number',
            hintText: 'Enter RSA ID number',
            controller: vm.idNumberController,
            inputFormatters: [
              AppTextInputFormatters.saIdNumberFormatter(),
            ],
            validator: Validators.validateSouthAfricanId,
          ),
        if (vm.showPassportField)
          KenwellTextField(
            label: 'Passport Number',
            hintText: 'Enter passport number',
            controller: vm.passportNumberController,
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Passport Number'
                : null,
          ),
        const SizedBox(height: 16),
        KenwellDateField(
          label: 'Date of Birth',
          controller: vm.dobController,
          validator: (val) => (val == null || val.isEmpty)
              ? 'Please select Date of Birth'
              : null,
          readOnly: true,
          onChanged: (value) => vm.setDob(value), // <-- Add this
        ),
        KenwellDropdownField<String>(
          label: 'Gender',
          value: vm.gender,
          items: vm.genderOptions,
          onChanged: vm.setGender,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Select Gender' : null,
        ),
      ],
    );
  }

  Widget _buildMedicalAidSection(MemberDetailsViewModel vm) {
    return Column(
      children: [
        KenwellDropdownField<String>(
          label: 'Do you have Medical Aid?',
          value: vm.medicalAidStatus,
          items: vm.medicalAidStatusOptions,
          onChanged: vm.setMedicalAidStatus,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Select Medical Aid status' : null,
        ),
        if (vm.showMedicalAidFields) ...[
          KenwellTextField(
            label: 'Medical Aid Name',
            hintText: 'Enter medical aid name',
            controller: vm.medicalAidNameController,
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Medical Aid Name'
                : null,
          ),
          KenwellTextField(
            label: 'Medical Aid Number',
            hintText: 'Enter medical aid number',
            controller: vm.medicalAidNumberController,
            inputFormatters: AppTextInputFormatters.numbersOnly(),
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Medical Aid Number'
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, MemberDetailsViewModel vm) {
    return KenwellFormNavigation(
      onNext: onNext,
      nextLabel: 'Submit',
      isNextBusy: vm.isSubmitting,
      isNextEnabled: !vm.isSubmitting,
    );
  }
}
