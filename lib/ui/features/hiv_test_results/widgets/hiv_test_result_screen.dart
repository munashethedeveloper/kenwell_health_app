import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_date_picker.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_section_tile.dart';
import '../../../shared/ui/form/custom_text_field.dart';
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
    final vm = context.watch<HIVTestResultViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'HIV Test Results',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------
            // Screening Test Section
            // ---------------------------
            const KenwellSectionTitle('Screening Test'),
            const SizedBox(height: 8),

            KenwellTextField(
              label: 'Name of Test',
              controller: vm.screeningTestNameController,
            ),
            KenwellTextField(
              label: 'Batch No',
              controller: vm.screeningBatchNoController,
            ),
            KenwellDatePickerField(
              label: 'Expiry Date',
              controller: vm.screeningExpiryDateController,
              onDateChanged: (date) =>
                  vm.handleExpiryDateChange(date, isScreening: true),
            ),
            KenwellDropdownField<String>(
              label: 'Test Result',
              value: vm.screeningResult.isEmpty ? null : vm.screeningResult,
              items: const ['Negative', 'Positive'],
              onChanged: (val) {
                if (val != null) vm.setScreeningResult(val);
              },
            ),
            const SizedBox(height: 16),

            // ---------------------------
            // Confirmatory Test Section
            // ---------------------------
            const KenwellSectionTitle('Confirmatory Test'),
            const SizedBox(height: 8),

            KenwellTextField(
              label: 'Name of Test',
              controller: vm.confirmatoryTestNameController,
            ),
            KenwellTextField(
              label: 'Batch No',
              controller: vm.confirmatoryBatchNoController,
            ),
            KenwellDatePickerField(
              label: 'Expiry Date',
              controller: vm.confirmatoryExpiryDateController,
              onDateChanged: (date) =>
                  vm.handleExpiryDateChange(date, isScreening: false),
            ),
            KenwellDropdownField<String>(
              label: 'Test Result',
              value:
                  vm.confirmatoryResult.isEmpty ? null : vm.confirmatoryResult,
              items: const ['Negative', 'Positive'],
              onChanged: (val) {
                if (val != null) vm.setConfirmatoryResult(val);
              },
            ),
            const SizedBox(height: 16),

            // ---------------------------
            // Final Result Section
            // ---------------------------
            const KenwellSectionTitle('Final HIV Test Result'),
            const SizedBox(height: 8),

            KenwellDropdownField<String>(
              label: 'Final Result',
              value: vm.finalResult.isEmpty ? null : vm.finalResult,
              items: const ['Negative', 'Positive'],
              onChanged: (val) {
                if (val != null) vm.setFinalResult(val);
              },
            ),
            const SizedBox(height: 20),

            // ---------------------------
            // Navigation
            // ---------------------------
            KenwellFormNavigation(
              onPrevious: onPrevious,
              onNext: () => vm.submitTestResult(onNext),
              isNextBusy: vm.isSubmitting,
              isNextEnabled: vm.isFormValid && !vm.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
