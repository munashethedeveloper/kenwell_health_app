import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
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
        builder: (context, vm, _) => Scaffold(
          appBar: const KenwellAppBar(
              title: 'Patient Personal Details',
              automaticallyImplyLeading: false),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
              child: Form(
                key: vm.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KenwellSectionHeader(
                      title: 'Section B: Personal Details',
                      uppercase: true,
                    ),
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
          ),
        ),
      ),
    );
  }

  // ===== Sections =====
  Widget _buildPersonalInfoSection(PersonalDetailsViewModel vm) {
    return Column(
      children: [
        _buildTextField(
          vm.nameController,
          'Name',
          'Enter name',
          inputFormatters:
              AppTextInputFormatters.lettersOnly(allowHyphen: true),
        ),
        _buildTextField(
          vm.surnameController,
          'Surname',
          'Enter surname',
          inputFormatters:
              AppTextInputFormatters.lettersOnly(allowHyphen: true),
        ),
        _buildTextField(
          vm.initialsController,
          'Initials',
          'Enter initials',
          inputFormatters: AppTextInputFormatters.lettersOnly(),
        ),
        _buildDropdownField(vm, 'Marital Status', vm.maritalStatus,
            vm.maritalStatusOptions, vm.setMaritalStatus),
        _buildDropdownField(
            vm, 'Gender', vm.gender, vm.genderOptions, vm.setGender),
        _buildTextField(
          vm.idNumberController,
          'ID Number',
          'Enter ID number',
          inputFormatters: AppTextInputFormatters.numbersOnly(),
        ),
        _buildTextField(
            vm.nationalityController, 'Nationality', 'Enter nationality'),
        _buildTextField(
            vm.emailController, 'Email Address', 'Enter email address',
            keyboardType: TextInputType.emailAddress),
        _buildTextField(
          vm.cellNumberController,
          'Cell Number',
          'Enter cell number',
          keyboardType: TextInputType.phone,
          inputFormatters: AppTextInputFormatters.numbersOnly(),
        ),
      ],
    );
  }

  Widget _buildMedicalAidSection(PersonalDetailsViewModel vm) {
    return Column(
      children: [
        _buildTextField(vm.medicalAidNameController, 'Medical Aid Name',
            'Enter medical aid name'),
        _buildTextField(
          vm.medicalAidNumberController,
          'Medical Aid Number',
          'Enter medical aid number',
          inputFormatters: AppTextInputFormatters.numbersOnly(),
        ),
      ],
    );
  }

  Widget _buildWorkInfoSection(PersonalDetailsViewModel vm) {
    return Column(
      children: [
        _buildTextField(vm.divisionController, 'Division', 'Enter division'),
        _buildTextField(
            vm.positionController, 'Position / Rank', 'Enter position or rank'),
        _buildDropdownField(
            vm, 'Province', vm.provinces, vm.provinceOptions, vm.setProvince),
        _buildDropdownField(vm, 'Employment Status', vm.employmentStatus,
            vm.employmentStatusOptions, vm.setEmploymentStatus),
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

  // ===== Helpers =====
  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false,
      VoidCallback? onTap,
      List<TextInputFormatter>? inputFormatters}) {
    return KenwellTextField(
      label: label,
      hintText: hint,
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      decoration: KenwellFormStyles.decoration(label: label, hint: hint),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdownField<T>(PersonalDetailsViewModel vm, String label,
      T? value, List<T> items, ValueChanged<T?> onChanged) {
    return KenwellDropdownField<T>(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: 'Select $label',
      ),
    );
  }
}
