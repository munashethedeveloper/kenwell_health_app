import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(
        title: const Text(
          'HIV Test Result',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Screening Test'),
            const SizedBox(height: 8),
            _buildTextField(
                'Name of Test', viewModel.screeningTestNameController),
            const SizedBox(height: 8),
            _buildTextField(
                'Batch No', viewModel.screeningBatchNoController),
            const SizedBox(height: 8),
            _buildTextField(
                'Expiry Date', viewModel.screeningExpiryDateController,
                readOnly: true,
                onTap: () =>
                    viewModel.pickExpiryDate(context, isScreening: true)),
            const SizedBox(height: 8),
            _buildDropdown(
              'Test Result',
              ['Negative', 'Positive'],
              viewModel.screeningResult,
              viewModel.setScreeningResult,
            ),
            const SizedBox(height: 16),
            _sectionTitle('Confirmatory Test'),
            const SizedBox(height: 8),
            _buildTextField(
                'Name of Test', viewModel.confirmatoryTestNameController),
            const SizedBox(height: 8),
            _buildTextField(
                'Batch No', viewModel.confirmatoryBatchNoController),
            const SizedBox(height: 8),
            _buildTextField(
                'Expiry Date', viewModel.confirmatoryExpiryDateController,
                readOnly: true,
                onTap: () =>
                    viewModel.pickExpiryDate(context, isScreening: false)),
            const SizedBox(height: 8),
            _buildDropdown(
              'Test Result',
              ['Negative', 'Positive'],
              viewModel.confirmatoryResult,
              viewModel.setConfirmatoryResult,
            ),
            const SizedBox(height: 16),
            _sectionTitle('Final HIV Test Result'),
            const SizedBox(height: 8),
            _buildDropdown(
              'Final Result',
              ['Negative', 'Positive'],
              viewModel.finalResult,
              viewModel.setFinalResult,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onPrevious,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Back'),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.isFormValid && !viewModel.isSubmitting
                        ? () => viewModel.submitTestResult(onNext)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF201C58),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14)),
                    child: viewModel.isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          )
                        : const Text(
                            'Submit & Continue',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}
