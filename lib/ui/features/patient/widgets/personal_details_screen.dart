import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            appBar: AppBar(
              title: const Text(
                'Patient Personal Details',
                style: TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF90C048),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField('Screening Site', vm.screeningSiteController),
                  const SizedBox(height: 12),
                  _buildDateField(context, 'Date', vm.dateController),
                  const SizedBox(height: 12),
                  _buildTextField('Name', vm.nameController),
                  const SizedBox(height: 12),
                  _buildTextField('Surname', vm.surnameController),
                  const SizedBox(height: 12),
                  _buildTextField('Initials', vm.initialsController),
                  const SizedBox(height: 12),
                  _buildTextField('ID Number', vm.idNumberController),
                  const SizedBox(height: 12),
                  _buildTextField('Nationality', vm.nationalityController),
                  const SizedBox(height: 12),
                  _buildTextField(
                      'Medical Aid Name', vm.medicalAidNameController),
                  const SizedBox(height: 12),
                  _buildTextField(
                      'Medical Aid Number', vm.medicalAidNumberController),
                  const SizedBox(height: 12),
                  _buildTextField('Email Address', vm.emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildTextField('Cell Number', vm.cellNumberController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField(
                      'Personal Number', vm.personalNumberController),
                  const SizedBox(height: 12),
                  _buildTextField('Division', vm.divisionController),
                  const SizedBox(height: 12),
                  _buildTextField('Position / Rank', vm.positionController),
                  const SizedBox(height: 12),
                  _buildTextField('Region / Province', vm.regionController),
                  const SizedBox(height: 12),

                  _buildDropdown(
                    'Marital Status',
                    vm.maritalStatus,
                    vm.maritalStatusOptions,
                    vm.setMaritalStatus,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Gender',
                    vm.gender,
                    vm.genderOptions,
                    vm.setGender,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'First Time Tested',
                    vm.firstTimeTested,
                    vm.firstTimeTestedOptions,
                    vm.setFirstTimeTested,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    'Employment Status',
                    vm.employmentStatus,
                    vm.employmentStatusOptions,
                    vm.setEmploymentStatus,
                  ),
                  const SizedBox(height: 24),

                  // --- Navigation Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onPrevious,
                          child: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: vm.isSubmitting
                              ? null
                              : () async {
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF90C048),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: vm.isSubmitting
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text(
                                  'Next',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text =
              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
        }
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
