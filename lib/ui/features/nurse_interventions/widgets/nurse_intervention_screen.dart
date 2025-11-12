import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/date_picker_field.dart';
import '../../../shared/ui/form/signature_pad.dart';
import '../view_model/nurse_intervention_view_model.dart';

class NurseInterventionScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const NurseInterventionScreen({
    super.key,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NurseInterventionViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
          title: 'Health Risk Asessessment Nurse Intervention',
          automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Window Period & Other Initial Fields ---
            _buildDropdown(
              'Window period risk assessment',
              viewModel.windowPeriod,
              viewModel.windowPeriodOptions,
              viewModel.setWindowPeriod,
            ),

            const SizedBox(height: 12),
            _buildDropdown(
              'Follow-up test location',
              viewModel.followUpLocation,
              viewModel.followUpLocationOptions,
              viewModel.setFollowUpLocation,
            ),
            if (viewModel.followUpLocation == 'Other')
              _buildTextField(
                'Other location detail',
                viewModel.followUpOtherController,
              ),
            const SizedBox(height: 12),
            DatePickerField(
              controller: viewModel.followUpDateController,
              label: 'Follow-up test date',
              displayFormat: DateFormat('dd/MM/yyyy'),
            ),

            const SizedBox(height: 24),

            // --- Nurse Details ---
            const Text(
              'Nurse Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTextField(
                'HIV Testing Nurse', viewModel.hivTestingNurseController),
            const SizedBox(height: 12),
            _buildTextField('Rank', viewModel.rankController),
            const SizedBox(height: 12),

            // --- Signature ---
            const Text('Signature',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SignaturePad(
              // If you later add a SignatureController to the view model,
              // pass it here as controller: viewModel.signatureController
              height: 150,
              onSave: (bytes) async {
                // optionally forward saved bytes to viewModel
              },
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                if (onPrevious != null) ...[
                  ElevatedButton(onPressed: onPrevious, child: const Text('Previous')), 
                  const SizedBox(width: 12),
                ],
                ElevatedButton(onPressed: onNext, child: const Text('Next')), 
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}