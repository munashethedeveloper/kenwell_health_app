import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
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
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SECTION  B',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(child: _buildPersonalInfoSection(context, vm)),
                    const SizedBox(height: 16),
                    _buildCard(child: _buildMedicalAidSection(vm)),
                    const SizedBox(height: 16),
                    _buildCard(child: _buildWorkInfoSection(vm)),
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
  Widget _buildPersonalInfoSection(
      BuildContext context, PersonalDetailsViewModel vm) {
    return Column(
      children: [
        _buildTextField(vm.screeningSiteController, 'Screening Site',
            'Enter screening site'),
        const SizedBox(height: 16),
        _buildTextField(vm.dateController, 'Date', 'Select date',
            readOnly: true, onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            vm.dateController.text =
                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
          }
        }),
        const SizedBox(height: 16),
        _buildTextField(vm.nameController, 'Name', 'Enter name'),
        _buildTextField(vm.surnameController, 'Surname', 'Enter surname'),
        _buildTextField(vm.initialsController, 'Initials', 'Enter initials'),
        _buildTextField(vm.idNumberController, 'ID Number', 'Enter ID number'),
        _buildTextField(
            vm.nationalityController, 'Nationality', 'Enter nationality'),
      ],
    );
  }

  Widget _buildMedicalAidSection(PersonalDetailsViewModel vm) {
    return Column(
      children: [
        _buildTextField(vm.medicalAidNameController, 'Medical Aid Name',
            'Enter medical aid name'),
        _buildTextField(vm.medicalAidNumberController, 'Medical Aid Number',
            'Enter medical aid number'),
        _buildTextField(
            vm.emailController, 'Email Address', 'Enter email address',
            keyboardType: TextInputType.emailAddress),
        _buildTextField(
            vm.cellNumberController, 'Cell Number', 'Enter cell number',
            keyboardType: TextInputType.phone),
        _buildTextField(vm.personalNumberController, 'Personal Number',
            'Enter personal number'),
      ],
    );
  }

  Widget _buildWorkInfoSection(PersonalDetailsViewModel vm) {
    return Column(
      children: [
        _buildTextField(vm.divisionController, 'Division', 'Enter division'),
        _buildTextField(
            vm.positionController, 'Position / Rank', 'Enter position or rank'),
        _buildTextField(vm.regionController, 'Region / Province',
            'Enter region or province'),
        const SizedBox(height: 16),
        _buildDropdownField(vm, 'Marital Status', vm.maritalStatus,
            vm.maritalStatusOptions, vm.setMaritalStatus),
        _buildDropdownField(
            vm, 'Gender', vm.gender, vm.genderOptions, vm.setGender),
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
  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return KenwellTextField(
      label: label,
      hintText: hint,
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
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
    );
  }
}
