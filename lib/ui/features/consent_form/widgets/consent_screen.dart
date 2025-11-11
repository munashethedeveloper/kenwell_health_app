import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../view_model/consent_screen_view_model.dart';

class ConsentScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onCancel;
  //final ConsentScreenViewModel viewModel;

  const ConsentScreen({
    super.key,
    required this.onNext,
    required this.onCancel,
    //required this.viewModel
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ConsentScreenViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consent Form',
          style: TextStyle(
            color: Color(0xFF201C58),
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF90C048),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue, Date, Practitioner
            _buildTextField(vm.venueController, 'Venue'),
            const SizedBox(height: 16),
            TextField(
              controller: vm.dateController,
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 16),
            _buildTextField(
                vm.practitionerController, 'Name of Healthcare Practitioner'),
            const SizedBox(height: 24),

            // Information bullets
            const Text(
              'I hereby declare that I have read and understood the information below. By signing, I confirm my understanding of:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildBullet(
                'HIV, glucose, cholesterol, blood pressure, BMI, TB, and stress/psychological screenings may take place.'),
            _buildBullet('The screening process was explained to me.'),
            _buildBullet(
                'These are screening tests and not diagnostic. Further testing may be needed.'),
            _buildBullet(
                'A finger prick will be used for testing and may cause temporary discomfort.'),
            _buildBullet(
                'My privacy will be respected, and I consent to data sharing with relevant health partners.'),
            _buildBullet('Participation is voluntary.'),
            _buildBullet(
                'I have been offered HIV pre- and post-test counselling.'),
            const SizedBox(height: 20),

            const Text(
              'Select applicable screenings:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('HRA'),
              value: vm.hra,
              onChanged: (val) => vm.toggleCheckbox('hra', val),
            ),
            CheckboxListTile(
              title: const Text('VCT'),
              value: vm.vct,
              onChanged: (val) => vm.toggleCheckbox('vct', val),
            ),
            CheckboxListTile(
              title: const Text('TB'),
              value: vm.tb,
              onChanged: (val) => vm.toggleCheckbox('tb', val),
            ),
            CheckboxListTile(
              title: const Text('HIV'),
              value: vm.hiv,
              onChanged: (val) => vm.toggleCheckbox('hiv', val),
            ),
            const SizedBox(height: 20),

            const Text('Signature:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              height: 150,
              child: Signature(
                controller: vm.signatureController,
                backgroundColor: Colors.grey[100]!,
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
            const SizedBox(height: 20),

            // Buttons: Cancel + Next
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
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
                            if (vm.isFormValid) {
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
                      backgroundColor: const Color(0xFF90C048),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
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
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField(
      TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
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
