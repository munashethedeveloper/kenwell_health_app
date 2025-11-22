import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_checkbox_group.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_signature_field.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';
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
              const KenwellSectionHeader(
                title: 'Section A: Informed Consent',
                uppercase: true,
              ),
              _buildEventInfoCard(context, vm),
              const SizedBox(height: 24),
              _buildInformationSection(),
              const SizedBox(height: 24),
              _buildScreeningSection(vm),
              const SizedBox(height: 24),
              KenwellFormCard(
                //title: 'Signature',
                child: _buildSignatureSection(vm),
              ),
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
    return KenwellFormCard(
      title: 'Event Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KenwellTextField(
            label: 'Venue',
            controller: vm.venueController,
            validator: (val) =>
                (val == null || val.isEmpty) ? 'Please enter Venue' : null,
          ),
          const SizedBox(height: 16),
          KenwellDateField(
            label: 'Date',
            controller: vm.dateController,
          ),
          const SizedBox(height: 16),
          KenwellTextField(
            label: 'Name of Healthcare Practitioner',
            controller: vm.practitionerController,
            inputFormatters: AppTextInputFormatters.lettersOnly(
              allowHyphen: true,
            ),
            validator: (val) => (val == null || val.isEmpty)
                ? 'Please enter Name of Healthcare Practitioner'
                : null,
          ),
        ],
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
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF201C58)),
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

    return KenwellFormCard(
      title: 'Select applicable screenings',
      child: KenwellCheckboxGroup(
        options: screenings
            .map(
              (s) => KenwellCheckboxOption(
                label: s['label'] as String,
                value: s['value'] as bool,
                onChanged: (val) =>
                    vm.toggleCheckbox(s['field'] as String, val),
              ),
            )
            .toList(),
      ),
    );
  }

  // ===== Signature Section =====
  Widget _buildSignatureSection(ConsentScreenViewModel viewModel) {
    return KenwellSignatureField(
      controller: viewModel.signatureController,
      onClear: viewModel.clearSignature,
    );
  }

  // ===== Action Buttons =====
  Widget _buildActionButtons(BuildContext context, ConsentScreenViewModel vm) {
    return KenwellFormNavigation(
      previousLabel: 'Cancel',
      onPrevious: onCancel,
      onNext: () async {
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
      isNextBusy: vm.isSubmitting,
      isNextEnabled: !vm.isSubmitting,
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
