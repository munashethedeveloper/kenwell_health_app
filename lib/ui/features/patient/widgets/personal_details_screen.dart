import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/forms/kenwell_form_fields.dart';
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
        builder: (context, vm, _) {
          return Scaffold(
            appBar: const KenwellAppBar(
                title: 'Patient Personal Details',
                automaticallyImplyLeading: false),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    KenwellTextField(
                      label: 'Screening Site',
                      controller: vm.screeningSiteController,
                    ),
                    KenwellTextField(
                      label: 'Date',
                      controller: vm.dateController,
                      readOnly: true,
                      onTap: () async {
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
                      },
                    ),
                    KenwellTextField(
                      label: 'Name',
                      controller: vm.nameController,
                    ),
                    KenwellTextField(
                      label: 'Surname',
                      controller: vm.surnameController,
                    ),
                    KenwellTextField(
                      label: 'Initials',
                      controller: vm.initialsController,
                    ),
                    KenwellTextField(
                      label: 'ID Number',
                      controller: vm.idNumberController,
                    ),
                    KenwellTextField(
                      label: 'Nationality',
                      controller: vm.nationalityController,
                    ),
                    KenwellTextField(
                      label: 'Medical Aid Name',
                      controller: vm.medicalAidNameController,
                    ),
                    KenwellTextField(
                      label: 'Medical Aid Number',
                      controller: vm.medicalAidNumberController,
                    ),
                    KenwellTextField(
                      label: 'Email Address',
                      controller: vm.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    KenwellTextField(
                      label: 'Cell Number',
                      controller: vm.cellNumberController,
                      keyboardType: TextInputType.phone,
                    ),
                    KenwellTextField(
                      label: 'Personal Number',
                      controller: vm.personalNumberController,
                    ),
                    KenwellTextField(
                      label: 'Division',
                      controller: vm.divisionController,
                    ),
                    KenwellTextField(
                      label: 'Position / Rank',
                      controller: vm.positionController,
                    ),
                    KenwellTextField(
                      label: 'Region / Province',
                      controller: vm.regionController,
                    ),
                    KenwellDropdownField<String>(
                      label: 'Marital Status',
                      value: vm.maritalStatus,
                      items: vm.maritalStatusOptions,
                      onChanged: vm.setMaritalStatus,
                    ),
                    KenwellDropdownField<String>(
                      label: 'Gender',
                      value: vm.gender,
                      items: vm.genderOptions,
                      onChanged: vm.setGender,
                    ),
                    KenwellDropdownField<String>(
                      label: 'Employment Status',
                      value: vm.employmentStatus,
                      items: vm.employmentStatusOptions,
                      onChanged: vm.setEmploymentStatus,
                    ),
                    const SizedBox(height: 24),

                    // --- Navigation Buttons ---
                    KenwellFormNavigation(
                      onPrevious: onPrevious,
                      onNext: () async {
                        if (vm.isFormValid) {
                          await vm.saveLocally();
                          onNext();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please complete all required fields before proceeding.',
                              ),
                            ),
                          );
                        }
                      },
                      isNextBusy: vm.isSubmitting,
                      isNextEnabled: !vm.isSubmitting,
                    ),
                  ],
                ),
            ),
          );
        },
      ),
    );
  }
}
