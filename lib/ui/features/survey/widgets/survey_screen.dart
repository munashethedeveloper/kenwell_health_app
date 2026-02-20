import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/constants/provinces.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_form_page.dart';
import '../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/survey_view_model.dart';

class SurveyScreen extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;
  final PreferredSizeWidget? appBar;

  const SurveyScreen({
    super.key,
    required this.onPrevious,
    required this.onSubmit,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SurveyViewModel>();

    return KenwellFormPage(
      title: 'Survey Form',
      sectionTitle: 'Section D: Survey',
      subtitle:
          'Please complete the form below to provide your feedback on the Wellness Day event.',
      appBar: appBar,
      children: [
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Welcome to Kenwell Consulting Wellness Day Survey.\n'
            'Your contact number and answers will be used for administrative purposes only.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: '1. How did you hear about this Wellness Day?',
          child: _buildRadioGroup(vm, const [
            'Intranet',
            'Flyer',
            'Wellness Team',
            'Poster',
            'Meeting',
            'Bathroom Reads'
          ]),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: '2. In which province did you attend the Wellness Day?',
          child: KenwellDropdownField<String>(
            label: 'Province',
            value: vm.province,
            items: SouthAfricanProvinces.all,
            onChanged: (val) {
              if (val != null) vm.updateProvince(val);
            },
            decoration: KenwellFormStyles.decoration(
              label: 'Province',
              hint: 'Select Province',
            ),
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title:
              '3–8. Please rate the following (0 = Disappointed, 5 = Extremely Satisfied):',
          child: Column(
            children: [
              _buildRatingRow(vm, '3. Overall experience of this wellness day?',
                  'overallExperience'),
              _buildRatingRow(
                  vm,
                  '4. Kenwell representatives were friendly and courteous?',
                  'friendlyStaff'),
              _buildRatingRow(
                  vm,
                  '5. Nurses were knowledgeable, professional and courteous?',
                  'nurseProfessional'),
              _buildRatingRow(
                  vm, '6. Did nurses explain results clearly?', 'clearResults'),
              _buildRatingRow(
                  vm,
                  '7. Did this event help you realise the full value of attending?',
                  'realisedValue'),
              _buildRatingRow(
                  vm,
                  '8. I will encourage colleagues to attend next Wellness Day.',
                  'encourageColleagues'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormCard(
          title: '9. Contact Consent',
          child: KenwellYesNoQuestion<String>(
            question:
                'Would you like Kenwell Consulting to contact you regarding your experience?',
            value: vm.contactConsent,
            onChanged: (value) {
              if (value != null) vm.updateContactConsent(value);
            },
            yesValue: 'Yes',
            noValue: 'No',
          ),
        ),
        const SizedBox(height: 24),
        KenwellFormNavigation(
          onPrevious: onPrevious,
          onNext: () => vm.submitSurvey(context, onNext: onSubmit),
          isNextEnabled: vm.isFormValid,
          nextLabel: 'Submit Survey',
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Thank you for completing this survey.\nYour feedback helps us improve.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // --- Helpers ---
  Widget _buildRadioGroup(SurveyViewModel vm, List<String> options) {
    final groupValue = vm.heardAbout;
    return Column(
      children: options
          .map(
            (option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: groupValue,
              onChanged: (val) {
                if (val != null) vm.updateHeardAbout(val);
              },
              toggleable: false,
            ),
          )
          .toList(),
    );
  }

  Widget _buildRatingRow(SurveyViewModel vm, String question, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) => Expanded(
                child: RadioListTile<int>(
                  dense: true,
                  title: Text('$index'),
                  value: index,
                  groupValue: vm.ratings[key],
                  onChanged: (val) {
                    if (val != null) vm.updateRating(key, val);
                  },
                  toggleable: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
