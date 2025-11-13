import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_checkbox_field.dart';
import '../../../shared/ui/form/custom_date_picker.dart';
import '../../../shared/ui/form/custom_section_tile.dart';
import '../../../shared/ui/form/custom_signature_pad.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/navigation/form_navigation.dart';

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
    final vm = context.watch<ConsentScreenViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Consent Form',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------
            // Venue, Date, Practitioner
            // -------------------------
            KenwellTextField(
              label: 'Venue',
              controller: vm.venueController,
            ),
            const SizedBox(height: 16),
            KenwellDatePickerField(
              controller: vm.dateController,
              label: 'Date',
              displayFormat: DateFormat('dd/MM/yyyy'),
            ),
            const SizedBox(height: 16),
            KenwellTextField(
              label: 'Name of Healthcare Practitioner',
              controller: vm.practitionerController,
            ),
            const SizedBox(height: 24),

            // -------------------------
            // Consent Information
            // -------------------------
            const KenwellSectionTitle('Consent Information'),
            const SizedBox(height: 8),
            const Text(
              'I hereby declare that I have read and understood the information below. By signing, I confirm my understanding of:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            ..._consentBullets.map((text) => _buildBullet(text)).toList(),
            const SizedBox(height: 20),

            // -------------------------
            // Screening Selection
            // -------------------------
            const KenwellSectionTitle('Select applicable screenings:'),
            const SizedBox(height: 8),
            KenwellCheckbox(
              title: 'HRA',
              value: vm.hra,
              onChanged: (val) => vm.toggleCheckbox('hra', val),
            ),
            KenwellCheckbox(
              title: 'VCT',
              value: vm.vct,
              onChanged: (val) => vm.toggleCheckbox('vct', val),
            ),
            KenwellCheckbox(
              title: 'TB',
              value: vm.tb,
              onChanged: (val) => vm.toggleCheckbox('tb', val),
            ),
            KenwellCheckbox(
              title: 'HIV',
              value: vm.hiv,
              onChanged: (val) => vm.toggleCheckbox('hiv', val),
            ),
            const SizedBox(height: 20),

            // -------------------------
            // Signature
            // -------------------------
            const KenwellSectionTitle('Signature'),
            const SizedBox(height: 8),
            KenwellSignaturePad(
              controller: vm.signatureController,
              height: 150,
            ),
            const SizedBox(height: 16),

            // -------------------------
            // Navigation
            // -------------------------
            KenwellFormNavigation(
              onPrevious: onCancel,
              onNext: () async {
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
              isNextEnabled: vm.isFormValid && !vm.isSubmitting,
              isNextBusy: vm.isSubmitting,
              previousLabel: 'Cancel',
              nextLabel: 'Next',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Static Consent Bullet Texts
  // ---------------------------
  static const List<String> _consentBullets = [
    'HIV, glucose, cholesterol, blood pressure, BMI, TB, and stress/psychological screenings may take place.',
    'The screening process was explained to me.',
    'These are screening tests and not diagnostic. Further testing may be needed.',
    'A finger prick will be used for testing and may cause temporary discomfort.',
    'My privacy will be respected, and I consent to data sharing with relevant health partners.',
    'Participation is voluntary.',
    'I have been offered HIV pre- and post-test counselling.',
  ];

  // ---------------------------
  // Bullet Point Widget
  // ---------------------------
  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 20)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
