import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/international_form_field.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import '../../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_date_field.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../view_model/member_registration_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

/// Create member form section
class CreateMemberSection extends StatefulWidget {
  final VoidCallback? onMemberCreated;

  const CreateMemberSection({super.key, this.onMemberCreated});

  @override
  State<CreateMemberSection> createState() => _CreateMemberSectionState();
}

class _CreateMemberSectionState extends State<CreateMemberSection> {
  Future<void> _submitMember() async {
    final viewModel = context.read<MemberDetailsViewModel>();

    if (!viewModel.formKey.currentState!.validate()) return;

    final success = await viewModel.saveMember();

    if (!mounted) return;

    if (success) {
      AppSnackbar.showSuccess(context, 'Member registered successfully!');
      // Reset form
      viewModel.formKey.currentState?.reset();
      viewModel.resetForm();
      widget.onMemberCreated?.call();
    } else {
      AppSnackbar.showError(context, 'Failed to register member');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberDetailsViewModel>(
      builder: (context, vm, _) {
        //final theme = Theme.of(context);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: vm.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  /* const Text(
                    'New Member Registration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF201C58),
                    ),
                  ),
                  const SizedBox(height: 24), */
                  KenwellFormCard(
                    title: 'Basic Information',
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildPersonalInfoSection(vm),
                  ),
                  KenwellFormCard(
                    title: 'Contact Information',
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildContactInfoSection(vm),
                  ),
                  KenwellFormCard(
                    title: 'Identification Information',
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildIdentificationInfoSection(vm),
                  ),
                  KenwellFormCard(
                    title: 'Medical Aid Information',
                    margin: const EdgeInsets.only(bottom: 24),
                    child: _buildMedicalAidSection(vm),
                  ),
                  CustomPrimaryButton(
                    label: "Register Member",
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      //color: KenwellColors.secondaryNavy,
                      color: Colors.white,
                    ),
                    onPressed: _submitMember,
                    isBusy: vm.isSubmitting,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
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
      const SizedBox(height: 8),
      KenwellTextField(
        label: 'Surname',
        hintText: 'Enter surname',
        controller: vm.surnameController,
        inputFormatters: AppTextInputFormatters.lettersOnly(allowHyphen: true),
        validator: (val) =>
            (val == null || val.isEmpty) ? 'Please enter Surname' : null,
      ),
      const SizedBox(height: 8),
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
          validator: Validators.validateOptionalEmail,
        ),
        const SizedBox(height: 8),
        InternationalPhoneField(
          label: 'Cell Number',
          controller: vm.cellNumberController,
          padding: EdgeInsets.zero,
          validator: Validators.validateInternationalPhoneNumber,
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
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: vm.citizenshipStatus,
          onChanged: (value) => vm.setCitizenshipStatus(value),
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'SA Citizen',
                title: const Text('SA Citizen'),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                value: 'Permanent Resident',
                title: const Text('Permanent Resident'),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                value: 'Other Nationality',
                title: const Text('Other Nationality'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

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
          Column(
            children: [
              const SizedBox(height: 8),
              KenwellTextField(
                label: 'RSA ID Number',
                hintText: 'Enter RSA ID number',
                controller: vm.idNumberController,
                inputFormatters: [
                  AppTextInputFormatters.saIdNumberFormatter(),
                ],
                validator: Validators.validateSouthAfricanId,
              ),
            ],
          ),
        if (vm.showPassportField)
          Column(
            children: [
              const SizedBox(height: 8),
              KenwellTextField(
                label: 'Passport Number',
                hintText: 'Enter passport number',
                controller: vm.passportNumberController,
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter Passport Number'
                    : null,
              ),
            ],
          ),
        const SizedBox(height: 8),
        KenwellDateField(
          label: 'Date of Birth',
          controller: vm.dobController,
          validator: (val) => (val == null || val.isEmpty)
              ? 'Please select Date of Birth'
              : null,
          readOnly: true,
          onChanged: (value) => vm.setDob(value),
        ),
        const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          KenwellTextField(
            label: 'Medical Aid Name',
            hintText: 'Enter medical aid name',
            controller: vm.medicalAidNameController,
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Medical Aid Name'
                : null,
          ),
          const SizedBox(height: 8),
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
}
