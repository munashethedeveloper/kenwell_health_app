import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/consent_screen_view_model.dart';

class ConsentScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onCancel;

  const ConsentScreen({
    super.key,
    required this.onNext,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ConsentScreenViewModel>(context);

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Consent Form',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: vm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SECTION A: INFORMED CONSENT',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF201C58),
                    ),
              ),
              const SizedBox(height: 16),
              _buildEventInfoCard(context, vm),
              const SizedBox(height: 24),
              _buildInformationSection(),
              const SizedBox(height: 20),
              _buildScreeningSection(vm),
              const SizedBox(height: 20),
              _buildSignatureSection(vm),
              const SizedBox(height: 24),
              _buildActionButtons(context, vm),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Event Info Card =====
  Widget _buildEventInfoCard(BuildContext context, ConsentScreenViewModel vm) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Section B Text =====
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
            ),

            // ===== Venue Field =====
            _buildTextField(vm.venueController, 'Venue'),
            const SizedBox(height: 16),

            // ===== Date Field =====
            _buildTextField(vm.dateController, 'Date', readOnly: true,
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
            }),
            const SizedBox(height: 16),

            // ===== Practitioner Field =====
            _buildTextField(
                vm.practitionerController, 'Name of Healthcare Practitioner'),
          ],
        ),
      ),
    );
  }

  // ===== Information Section =====
  Widget _buildInformationSection() {
    final bullets = [
      'HIV, glucose, cholesterol, blood pressure, BMI, TB, and stress/psychological screenings may take place.',
      'The screening process was explained to me.',
      'These are screening tests and not diagnostic. Further testing may be needed.',
      'A finger prick will be used for testing and may cause temporary discomfort.',
      'My privacy will be respected, and I consent to data sharing with relevant health partners.',
      'Participation is voluntary.',
      'I have been offered HIV pre- and post-test counselling.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I hereby declare that I have read and understood the information below. By signing, I confirm my understanding of:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...bullets.map(_buildBullet).toList(),
      ],
    );
  }

  // ===== Screening Section =====
  Widget _buildScreeningSection(ConsentScreenViewModel vm) {
    final screenings = [
      {'label': 'HRA', 'field': 'hra', 'value': vm.hra},
      {'label': 'VCT', 'field': 'vct', 'value': vm.vct},
      {'label': 'TB', 'field': 'tb', 'value': vm.tb},
      {'label': 'HIV', 'field': 'hiv', 'value': vm.hiv},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select applicable screenings:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Column(
            children: screenings
                .map(
                  (s) => CheckboxListTile(
                    title: Text(s['label'] as String),
                    value: s['value'] as bool,
                    onChanged: (val) =>
                        vm.toggleCheckbox(s['field'] as String, val),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ===== Signature Section =====
  Widget _buildSignatureSection(ConsentScreenViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Signature:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(8),
            height: 160,
            child: Signature(
              controller: vm.signatureController,
              backgroundColor: Colors.grey[100]!,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: vm.clearSignature,
            child: const Text('Clear Signature'),
          ),
        ),
      ],
    );
  }

  // ===== Action Buttons =====
  Widget _buildActionButtons(BuildContext context, ConsentScreenViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: vm.isSubmitting
                ? null
                : () async {
                    if (vm.formKey.currentState!.validate() && vm.isFormValid) {
                      await vm.submitConsent();
                      onNext();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete all fields and sign before proceeding.',
                          ),
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF201C58),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: vm.isSubmitting
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                : const Text(
                    'Next',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // ===== Helpers =====
  static Widget _buildTextField(
      TextEditingController controller, String labelText,
      {bool readOnly = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Enter $labelText',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Please enter $labelText' : null,
    );
  }

  static Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
