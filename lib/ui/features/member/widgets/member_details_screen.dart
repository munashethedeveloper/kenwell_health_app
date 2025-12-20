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
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/member_details_view_model.dart';

class MemberDetailsScreen extends StatelessWidget {
  final MemberDetailsViewModel viewModel;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const MemberDetailsScreen({
    super.key,
    required this.viewModel,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<MemberDetailsViewModel>(
        builder: (context, vm, _) {
          return KenwellFormPage(
            title: 'Personal Details Form',
            sectionTitle: 'Section B: Personal Details',
            formKey: vm.formKey,
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
      //  KenwellTextField(
      //   label: 'Initials',
      //   hintText: 'Enter initials',
      //   controller: vm.initialsController,
      //    inputFormatters: AppTextInputFormatters.lettersOnly(),
      //    validator: (val) =>
      //        (val == null || val.isEmpty) ? 'Please enter Initials' : null,
      //  ),
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

        // 🔥 NEW DROPDOWN + CONDITIONAL TEXTFIELD
        // KenwellDropdownField<String>(
        //   label: 'Do you have an alternative contact number?',
        //   value: vm.hasAlternateNumber,
        //   items: vm.hasAlternateNumberOptions,
        //   onChanged: vm.setHasAlternateNumber,
        //   validator: (val) =>
        //       (val == null || val.isEmpty) ? 'Please select an option' : null,
        // ),

        // if (vm.showAlternateNumberField)
        //   KenwellTextField(
        //     label: 'Alternative Contact Number',
        //     hintText: 'Enter alternative contact number',
        //     controller: vm.alternateContactNumberController,
        //     keyboardType: TextInputType.phone,
        //     inputFormatters: [AppTextInputFormatters.saPhoneNumberFormatter()],
        // validator: Validators.validateSouthAfricanPhoneNumber,
        // ),
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
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('SA Citizen', style: TextStyle(fontSize: 14)),
                value: 'SA Citizen',
                groupValue: vm.citizenshipStatus,
                onChanged: vm.setCitizenshipStatus,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Permanent Resident', 
                    style: TextStyle(fontSize: 14)),
                value: 'Permanent Resident',
                groupValue: vm.citizenshipStatus,
                onChanged: vm.setCitizenshipStatus,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Other Nationality', 
                    style: TextStyle(fontSize: 14)),
                value: 'Other Nationality',
                groupValue: vm.citizenshipStatus,
                onChanged: vm.setCitizenshipStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Show fields only after citizenship status is selected
        if (vm.showIdentificationFields) ...[
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
                  ),
                ),
              ),
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: 'Nationality',
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (value) => vm.setSelectedNationality(value),
              validator: (val) => (val == null || val.isEmpty) 
                  ? 'Please select Nationality' 
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
      onPrevious: onPrevious,
      onNext: () async {
        if (vm.isFormValid) {
          await vm.saveLocally();
          onNext();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Please complete all required fields before proceeding.'),
            ),
          );
        }
      },
      isNextBusy: vm.isSubmitting,
      isNextEnabled: !vm.isSubmitting,
    );
  }
}
