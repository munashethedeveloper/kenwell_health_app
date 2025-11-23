import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:kenwell_health_app/utils/input_formatters.dart';

import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_bullet_list.dart';
import '../../../shared/ui/form/kenwell_checkbox_group.dart';
import '../../../shared/ui/form/kenwell_checkbox_list_card.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_step.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
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

    final steps = _buildFormSteps(vm);

    return KenwellFormPage(
      title: 'Consent Form',
      sectionTitle: 'Section A: Informed Consent',
      formKey: vm.formKey,
      children: [
        for (final step in steps) ...[
          step.builder(context),
          SizedBox(height: step.spacingAfter),
        ],
        KenwellSignatureActions(
          controller: vm.signatureController,
          onClear: vm.clearSignature,
          navigation: _buildActionButtons(context, vm),
          title: 'Signature',
        ),
      ],
    );
  }

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

  List<KenwellFormStep> _buildFormSteps(ConsentScreenViewModel vm) {
    return [
      KenwellFormStep(
        builder: (_) => KenwellFormCard(
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
        ),
      ),
      KenwellFormStep(
        builder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'I hereby declare that I have read and understood the information below. By signing, I confirm my understanding of:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF201C58),
              ),
            ),
            SizedBox(height: 12),
            KenwellBulletList(items: _informationBullets),
          ],
        ),
      ),
      KenwellFormStep(
        builder: (_) => KenwellCheckboxListCard(
          title: 'Select applicable screenings',
          options: _screeningOptions(vm),
        ),
      ),
    ];
  }

  static const List<String> _informationBullets = [
    'HIV, glucose, cholesterol, blood pressure, BMI, TB, and stress/psychological screenings may take place.',
    'The screening process was explained to me.',
    'These are screening tests and not diagnostic. Further testing may be needed.',
    'A finger prick will be used for testing and may cause temporary discomfort.',
    'My privacy will be respected, and I consent to data sharing with relevant health partners.',
    'Participation is voluntary.',
    'I have been offered HIV pre- and post-test counselling.',
  ];

  List<KenwellCheckboxOption> _screeningOptions(ConsentScreenViewModel vm) {
    final screenings = [
      {'label': 'HRA', 'value': vm.hra, 'field': 'hra'},
      {'label': 'VCT', 'value': vm.vct, 'field': 'vct'},
      {'label': 'TB', 'value': vm.tb, 'field': 'tb'},
      {'label': 'HIV', 'value': vm.hiv, 'field': 'hiv'},
    ];

    return screenings
        .map(
          (s) => KenwellCheckboxOption(
            label: s['label'] as String,
            value: s['value'] as bool,
            onChanged: (val) => vm.toggleCheckbox(s['field'] as String, val),
          ),
        )
        .toList();
  }
}
