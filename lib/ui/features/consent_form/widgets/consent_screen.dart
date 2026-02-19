import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_checkbox_group.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/form/custom_text_field.dart';
import '../../../shared/ui/form/kenwell_bullet_list.dart';
import '../../../shared/ui/form/kenwell_checkbox_list_card.dart';
import '../../../shared/ui/form/kenwell_date_field.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_step.dart';
import '../../../shared/ui/form/kenwell_signature_actions.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/consent_screen_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../wellness/view_model/wellness_flow_view_model.dart';

// ConsentScreen displays the consent form for a wellness event
class ConsentScreen extends StatelessWidget {
  final VoidCallback onNext;
  final WellnessEvent event;
  final PreferredSizeWidget? appBar;

  // Constructor
  const ConsentScreen({
    super.key,
    required this.onNext,
    required this.event,
    this.appBar,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ConsentScreenViewModel>(context);
    final profileVm = Provider.of<ProfileViewModel>(context);

    // Get memberId and eventId from WellnessFlowViewModel if available
    String? memberId;
    String? eventId = event.id;
    try {
      final wellnessFlowVm =
          Provider.of<WellnessFlowViewModel>(context, listen: false);
      memberId = wellnessFlowVm.currentMember?.id;
    } catch (e) {
      // WellnessFlowViewModel not available in this context
    }

    // Pass event & profile data into VM
    vm.initialise(
      event,
      firstName: profileVm.firstName,
      lastName: profileVm.lastName,
      memberId: memberId,
      eventId: eventId,
    );
    // Initialise the VM with event data
    //vm.initialise(event);

    // Build form steps
    final steps = _buildFormSteps(vm);

    // Return the form page
    return KenwellFormPage(
      title: 'Consent Form',
      sectionTitle: 'Section B: Informed Consent',
      subtitle:
          'Please complete the form below to provide your informed consent.',
      formKey: vm.formKey,
      appBar: appBar,
      children: [
        // Build each form step
        for (final step in steps) ...[
          step.builder(context),
          SizedBox(height: step.spacingAfter),
        ],
        // Signature actions
        KenwellSignatureActions(
          controller: vm.signatureController,
          onClear: vm.clearSignature,
          navigation: _buildActionButtons(context, vm),
          title: 'Patient Signature',
        ),
      ],
    );
  }

  // Build action buttons
  Widget _buildActionButtons(BuildContext context, ConsentScreenViewModel vm) {
    return KenwellFormNavigation(
      nextLabel: 'Submit',
      onNext: () async {
        if (!vm.hasAtLeastOneScreening) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please select at least one screening option.',
                ),
              ),
            );
          }
          return;
        }

        // Validate and submit the form
        if (vm.formKey.currentState!.validate() && vm.isFormValid) {
          await vm.submitConsent();
          // FIX: Always use markConsentCompleted() to update and notify listeners
          try {
            if (context.mounted) {
              final wellnessFlowVm =
                  Provider.of<WellnessFlowViewModel>(context, listen: false);
              wellnessFlowVm.markConsentCompleted();
            }
          } catch (e) {
            // Optionally log error
          }
          if (context.mounted) {
            onNext();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please complete all fields and sign before proceeding.',
                ),
              ),
            );
          }
        }
      },
      isNextBusy: vm.isSubmitting,
      isNextEnabled: !vm.isSubmitting,
    );
  }

  // Build form steps
  List<KenwellFormStep> _buildFormSteps(ConsentScreenViewModel vm) {
    return [
      KenwellFormStep(
        builder: (_) => KenwellFormCard(
          title: 'Event Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event details fields
              KenwellTextField(
                label: 'Venue',
                controller: vm.venueController,
                enabled: false,
                readOnly: true, // <-- make read-only
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please enter Venue' : null,
              ),
              const SizedBox(height: 16),
              // Date field
              KenwellDateField(
                label: 'Date',
                controller: vm.dateController,
                enabled: false,
                readOnly: true, // <-- make read-only
              ),
              const SizedBox(height: 16),
              // Healthcare practitioner field
              KenwellTextField(
                label: 'Name of Healthcare Practitioner',
                enabled: false,
                readOnly: true,
                controller: vm.practitionerController,
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter Name of Healthcare Practitioner'
                    : null,
              ),
            ],
          ),
        ),
      ),
      // Information and screening options
      KenwellFormStep(
        builder: (_) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I hereby declare that I have read and understood the information below. By signing, I confirm my understanding of:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF201C58),
              ),
            ),
            SizedBox(height: 12),
            // Bullet list of information
            KenwellBulletList(items: _informationBullets),
          ],
        ),
      ),
      // Screening options
      KenwellFormStep(
        builder: (_) => KenwellCheckboxListCard(
          title: 'Please select applicable screenings',
          options: _screeningOptions(vm),
        ),
      ),
    ];
  }

  // Information bullets
  static const List<String> _informationBullets = [
    'HIV, glucose, cholesterol, blood pressure, BMI, TB, stress / psychological screenings, and a lifestyle assessment, amongst others, will take place'
        'The process of these screening tests was explained to me',
    'These tests to be done are screening tests, and not diagnostic tests, and further testing may be required to conclude the diagnostic process',
    'A finger prick will be used to collect a few drops of blood. The finger prick may cause some short-term discomfort like pain and / or swelling or other complications',
    'I have the opportunity to ask questions about these screening tests and processes',
    'My privacy will be respected, and I give consent for my screening test results to be shared with my medical scheme, it’s administrator, and / or managed health care organization, or other parties involved (doctors and nurses), in the management of my health',
    'The health screening tests are entirely voluntary',
    'I have been offered pre-test and post-test counselling for the HIV test',
    'I have the legal capacity to give informed consent',
    'I understand and agree that all health information supplied by me in connection with my personal health will be used by Kenwell Consulting to assess my health risk and I agree that the information can be sent to my Medical Aid to suggest appropriate intervention programmes aimed at improving my health risk and that this information will be kept confidential. I understand that my employer will receive a statistical report with no personal information.',
    'I understand and agree that information relevant to my current health can be disclosed to third parties, for the purposes of analysis without the disclosure of my identity.',
    'I also accept that anonymous data will be shared with my employer to help them understand health trends in my company and to further help me and my colleagues.',
    'I understand and agree that I may receive a follow up regarding my medical condition.',
  ];

  // Screening options
  List<KenwellCheckboxOption> _screeningOptions(ConsentScreenViewModel vm) {
    final screenings = [
      {'label': 'HIV', 'value': vm.hiv, 'field': 'hiv'},
      {'label': 'HRA', 'value': vm.hra, 'field': 'hra'},
      {'label': 'TB', 'value': vm.tb, 'field': 'tb'},
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
