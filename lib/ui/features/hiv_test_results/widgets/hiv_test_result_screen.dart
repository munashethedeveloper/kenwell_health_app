import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/hiv_test_result_view_model.dart';

class HIVTestResultScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const HIVTestResultScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HIVTestResultViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'HIV Test Results',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KenwellSectionHeader(
                title: 'Section G: HIV Test Results',
                uppercase: true,
              ),
              KenwellFormCard(
                title: 'Screening Test',
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Name of Test',
                      controller: viewModel.screeningTestNameController,
                      hint: 'Enter test name',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Batch No',
                      controller: viewModel.screeningBatchNoController,
                      hint: 'Enter batch number',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Expiry Date',
                      controller: viewModel.screeningExpiryDateController,
                      readOnly: true,
                      hint: 'Select expiry date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () =>
                          viewModel.pickExpiryDate(context, isScreening: true),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'Test Result',
                      ['Negative', 'Positive'],
                      viewModel.screeningResult,
                      viewModel.setScreeningResult,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              KenwellFormCard(
                title: 'Confirmatory Test',
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Name of Test',
                      controller: viewModel.confirmatoryTestNameController,
                      hint: 'Enter test name',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Batch No',
                      controller: viewModel.confirmatoryBatchNoController,
                      hint: 'Enter batch number',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Expiry Date',
                      controller: viewModel.confirmatoryExpiryDateController,
                      readOnly: true,
                      hint: 'Select expiry date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      onTap: () =>
                          viewModel.pickExpiryDate(context, isScreening: false),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'Test Result',
                      ['Negative', 'Positive'],
                      viewModel.confirmatoryResult,
                      viewModel.setConfirmatoryResult,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              KenwellFormCard(
                title: 'Final HIV Test Result',
                child: _buildDropdown(
                  'Final Result',
                  ['Negative', 'Positive'],
                  viewModel.finalResult,
                  viewModel.setFinalResult,
                ),
              ),
              const SizedBox(height: 24),
              KenwellFormNavigation(
                onPrevious: onPrevious,
                onNext: () => viewModel.submitTestResult(onNext),
                isNextBusy: viewModel.isSubmitting,
                isNextEnabled: viewModel.isFormValid && !viewModel.isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildCard({required String title, required Widget child}) {
  // return Card(
  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //   elevation: 3,
  //   shadowColor: Colors.grey.shade300,
  //   color: Colors.white,
  //   child: Padding(
  //     padding: const EdgeInsets.all(16),
  //    child: Column(
  //    crossAxisAlignment: CrossAxisAlignment.start,
  //    children: [
  //      Text(title,
  //          style: const TextStyle(
  //              fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF201C58))),
  //        const SizedBox(height: 12),
  //        child,
  //      ],
  //    ),
  //  ),
  //  );
  //}

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return KenwellTextField(
      label: label,
      hintText: hint,
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: hint,
        suffixIcon: suffixIcon,
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      void Function(String) onChanged) {
    return KenwellDropdownField<String>(
      label: label,
      value: value,
      items: items,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: 'Select $label',
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'This field is required' : null,
    );
  }
}
