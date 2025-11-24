import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/personal_details_view_model.dart';

class PersonalDetailsScreen extends StatelessWidget {
  final PersonalDetailsViewModel viewModel;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PersonalDetailsScreen({
    super.key,
    required this.viewModel,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PersonalDetailsViewModel>(
        builder: (context, vm, _) => KenwellFormPage(
          title: 'Personal Details Form',
          sectionTitle: 'Section B: Personal Details',
          formKey: vm.formKey,
          children: [
            KenwellFormCard(
              title: 'Personal Information',
              child: _buildPersonalInfoSection(vm),
            ),
            const SizedBox(height: 24),
            KenwellFormCard(
              title: 'Medical Aid Information',
              child: _buildMedicalAidSection(vm),
            ),
            const SizedBox(height: 24),
            KenwellFormCard(
              title: 'Employment Details',
              child: _buildWorkInfoSection(vm),
            ),
            const SizedBox(height: 24),
            _buildNavigationButtons(context, vm),
          ],
        ),
      ),
    );
  }

  // ===== Sections =====
  Widget _buildPersonalInfoSection(PersonalDetailsViewModel vm) {
    return Column(
      children: [
        KenwellTextField(
          label: 'Name',
          hintText: 'Enter name',
          controller: vm.nameController,
          inputFormatters:
              AppTextInputFormatters.lettersOnly(allowHyphen: true),
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter Name' : null,
        ),
        KenwellTextField(
          label: 'Surname',
          hintText: 'Enter surname',
          controller: vm.surnameController,
          inputFormatters:
              AppTextInputFormatters.lettersOnly(allowHyphen: true),
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter Surname' : null,
        ),
        KenwellTextField(
          label: 'Initials',
          hintText: 'Enter initials',
          controller: vm.initialsController,
          inputFormatters: AppTextInputFormatters.lettersOnly(),
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter Initials' : null,
        ),
        KenwellDateField(
          label: 'Date of Birth',
          controller: vm.dobController,
          validator: (val) => (val == null || val.isEmpty)
              ? 'Please select Date of Birth'
              : null,
        ),
        KenwellDropdownField<String>(
          label: 'Marital Status',
          value: vm.maritalStatus,
          items: vm.maritalStatusOptions,
          onChanged: vm.setMaritalStatus,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Select Marital Status' : null,
        ),
        KenwellDropdownField<String>(
          label: 'Gender',
          value: vm.gender,
          items: vm.genderOptions,
          onChanged: vm.setGender,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Select Gender' : null,
        ),
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
            label: 'ID Number',
            hintText: 'Enter ID number',
            controller: vm.idNumberController,
            inputFormatters: AppTextInputFormatters.numbersOnly(),
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter ID Number' : null,
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
        KenwellTextField(
          label: 'Nationality',
          hintText: 'Enter nationality',
          controller: vm.nationalityController,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter Nationality' : null,
        ),
        KenwellTextField(
          label: 'Email Address',
          hintText: 'Enter email address',
          controller: vm.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (val) => (val == null || val.isEmpty)
              ? 'Please enter Email Address'
              : null,
        ),
        KenwellTextField(
          label: 'Cell Number',
          hintText: 'Enter cell number',
          controller: vm.cellNumberController,
          keyboardType: TextInputType.phone,
          inputFormatters: AppTextInputFormatters.numbersOnly(),
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter Cell Number' : null,
        ),
        KenwellTextField(
          label: 'Alternate Contact Number',
          hintText: 'Enter alternate contact number',
          controller: vm.alternateContactNumberController,
          keyboardType: TextInputType.phone,
          inputFormatters: AppTextInputFormatters.numbersOnly(),
          validator: (val) => (val == null || val.isEmpty)
              ? 'Please enter Alternate Contact Number'
              : null,
        ),
      ],
    );
  }

  Widget _buildMedicalAidSection(PersonalDetailsViewModel vm) {
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

  Widget _buildWorkInfoSection(PersonalDetailsViewModel vm) {
    return Column(
      children: [
        KenwellTextField(
          label: 'Division',
          hintText: 'Enter division',
          controller: vm.divisionController,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Please enter Division' : null,
        ),
        KenwellTextField(
          label: 'Position / Rank',
          hintText: 'Enter position or rank',
          controller: vm.positionController,
          validator: (val) => (val == null || val.isEmpty)
              ? 'Please enter Position / Rank'
              : null,
        ),
        KenwellTextField(
          label: 'Employee Number',
          hintText: 'Enter employee number',
          controller: vm.employeeNumberController,
          validator: (val) => (val == null || val.isEmpty)
              ? 'Please enter Employee Number'
              : null,
        ),
        KenwellDropdownField<String>(
          label: 'Province',
          value: vm.provinces,
          items: vm.provinceOptions,
          onChanged: vm.setProvince,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Select Province' : null,
        ),
        KenwellDropdownField<String>(
          label: 'Employment Status',
          value: vm.employmentStatus,
          items: vm.employmentStatusOptions,
          onChanged: vm.setEmploymentStatus,
          validator: (val) =>
              (val == null || val.isEmpty) ? 'Select Employment Status' : null,
        ),
      ],
    );
  }

  // ===== Navigation Buttons =====
  Widget _buildNavigationButtons(
      BuildContext context, PersonalDetailsViewModel vm) {
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
