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
                      KenwellTextField(
                        label: 'Name of Test',
                        hintText: 'Enter test name',
                        controller: viewModel.screeningTestNameController,
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      KenwellTextField(
                        label: 'Batch No',
                        hintText: 'Enter batch number',
                        controller: viewModel.screeningBatchNoController,
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      KenwellTextField(
                        label: 'Expiry Date',
                        hintText: 'Select expiry date',
                        controller: viewModel.screeningExpiryDateController,
                        readOnly: true,
                        suffixIcon: const Icon(Icons.calendar_today),
                        onTap: () =>
                            viewModel.pickExpiryDate(context, isScreening: true),
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      KenwellDropdownField<String>(
                        label: 'Test Result',
                        value: viewModel.screeningResult,
                        items: const ['Negative', 'Positive'],
                        onChanged: (val) {
                          if (val != null) viewModel.setScreeningResult(val);
                        },
                        validator: _requiredField,
                      ),
                    ],
                ),
              ),
              const SizedBox(height: 24),
              KenwellFormCard(
                title: 'Confirmatory Test',
                child: Column(
                  children: [
                      KenwellTextField(
                        label: 'Name of Test',
                        hintText: 'Enter test name',
                        controller: viewModel.confirmatoryTestNameController,
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      KenwellTextField(
                        label: 'Batch No',
                        hintText: 'Enter batch number',
                        controller: viewModel.confirmatoryBatchNoController,
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      KenwellTextField(
                        label: 'Expiry Date',
                        hintText: 'Select expiry date',
                        controller: viewModel.confirmatoryExpiryDateController,
                        readOnly: true,
                        suffixIcon: const Icon(Icons.calendar_today),
                        onTap: () =>
                            viewModel.pickExpiryDate(context, isScreening: false),
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 12),
                      KenwellDropdownField<String>(
                        label: 'Test Result',
                        value: viewModel.confirmatoryResult,
                        items: const ['Negative', 'Positive'],
                        onChanged: (val) {
                          if (val != null) viewModel.setConfirmatoryResult(val);
                        },
                        validator: _requiredField,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              KenwellFormCard(
                title: 'Final HIV Test Result',
                  child: KenwellDropdownField<String>(
                    label: 'Final Result',
                    value: viewModel.finalResult,
                    items: const ['Negative', 'Positive'],
                    onChanged: (val) {
                      if (val != null) viewModel.setFinalResult(val);
                    },
                    validator: _requiredField,
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

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.grey.shade300,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF201C58))),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

    String? _requiredField(String? value) =>
        value == null || value.isEmpty ? 'This field is required' : null;
}
