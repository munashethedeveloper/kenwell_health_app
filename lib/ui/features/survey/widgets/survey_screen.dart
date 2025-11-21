import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../shared/ui/form/custom_yes_no_question.dart';
import '../../../shared/ui/form/form_input_borders.dart';
import '../../../shared/ui/navigation/form_navigation.dart';
import '../view_model/survey_view_model.dart';

class SurveyScreen extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const SurveyScreen({
    super.key,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SurveyViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'Survey',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section K: Survey',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF201C58),
                  ),
            ),
            const SizedBox(height: 24),

            const Center(
              child: Text(
                'Welcome to Kenwell Consulting Wellness Day Survey.\n'
                'Your contact number and answers will be used for administrative purposes only.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // 1. How did you hear about this Wellness Day?
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. How did you hear about this Wellness Day?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF201C58)),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioGroup(vm, [
                    'Intranet',
                    'Flyer',
                    'Wellness Team',
                    'Poster',
                    'Meeting',
                    'Bathroom Reads'
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Province
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2. In which province did you attend the Wellness Day?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF201C58)),
                  ),
                  const SizedBox(height: 8),
                  KenwellDropdownField<String>(
                    label: 'Province',
                    value: vm.province,
                    items: const [
                      'Gauteng',
                      'Western Cape',
                      'KwaZulu-Natal',
                      'Eastern Cape',
                      'Limpopo',
                      'Mpumalanga',
                      'North West',
                      'Free State',
                      'Northern Cape'
                    ],
                    onChanged: (val) {
                      if (val != null) vm.updateProvince(val);
                    },
                    decoration:
                        _profileFieldDecoration('Province', 'Select Province'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3–8. Ratings
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please rate the following (0 = Disappointed, 5 = Extremely Satisfied):',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF201C58)),
                  ),
                  const SizedBox(height: 8),
                  _buildRatingRow(
                      vm,
                      '3. Overall experience of this wellness day?',
                      'overallExperience'),
                  _buildRatingRow(
                      vm,
                      '4. Kenwell representatives were friendly and courteous?',
                      'friendlyStaff'),
                  _buildRatingRow(
                      vm,
                      '5. Nurses were knowledgeable, professional and courteous?',
                      'nurseProfessional'),
                  _buildRatingRow(vm, '6. Did nurses explain results clearly?',
                      'clearResults'),
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

            // 9. Contact Consent
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KenwellYesNoQuestion<String>(
                    question:
                        '9. Would you like Kenwell Consulting to contact you regarding your experience?',
                    value: vm.contactConsent,
                    onChanged: (value) {
                      if (value != null) vm.updateContactConsent(value);
                    },
                    yesValue: 'Yes',
                    noValue: 'No',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
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
        ),
      ),
    );
  }

  // --- Card Wrapper ---
  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _profileFieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: authOutlineInputBorder,
      enabledBorder: authOutlineInputBorder,
      focusedBorder: authOutlineInputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFF7643)),
      ),
    );
  }
}
