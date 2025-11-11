import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/survey_view_model.dart';

class SurveyScreen extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const SurveyScreen(
      {super.key, required this.onPrevious, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SurveyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wellness Day Client Satisfaction Survey',
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
            const Text(
              'Welcome to Kenwell Consulting Wellness Day Survey.\n'
              'Your contact number and answers will be used for administrative purposes only.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            // 1. How did you hear about this Wellness Day?
            const Text(
              '1. How did you hear about this Wellness Day?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildRadioGroup(vm, 'heardAbout', [
              'Intranet',
              'Flyer',
              'Wellness Team',
              'Poster',
              'Meeting',
              'Bathroom Reads'
            ]),
            const SizedBox(height: 16),

            // 2. Province
            const Text(
              '2. In which province did you attend the Wellness Day?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildDropdown(
              'Province',
              [
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
              vm.province,
              (val) {
                if (val != null) vm.updateProvince(val);
              },
            ),
            const Divider(height: 32),

            // 3–8. Ratings
            const Text(
              'Please rate the following (0 = Disappointed, 5 = Extremely Satisfied):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
            const Divider(height: 32),

            // 9. Contact Consent
            const Text(
              '9. Would you like Kenwell Consulting to contact you regarding your experience?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            RadioGroup<String>(
              groupValue: vm.contactConsent,
              onChanged: (val) {
                if (val != null) vm.updateContactConsent(val);
              },
              child: const Row(
                children: <Widget>[
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Yes'),
                      value: 'Yes',
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('No'),
                      value: 'No',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrevious,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: vm.isFormValid
                        ? () => vm.submitSurvey(context, onNext: onSubmit)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90C048),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: const Text(
                      'Submit Survey',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Thank you for completing this survey.\nYour feedback helps us improve.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildRadioGroup(SurveyViewModel vm, String _, List<String> options) {
    String? groupValue = vm.heardAbout;
    return RadioGroup<String>(
        groupValue: groupValue,
        onChanged: (val) {
          if (val != null) {
            vm.updateHeardAbout(val);
          }
        },
        child: Column(
          children: options
              .map(
                (option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                ),
              )
              .toList(),
        ));
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRatingRow(SurveyViewModel vm, String question, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          RadioGroup<int>(
            groupValue: vm.ratings[key],
            onChanged: (val) {
              if (val != null) {
                vm.updateRating(key, val);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => Expanded(
                  child: RadioListTile<int>(
                    dense: true,
                    title: Text('$index'),
                    value: index,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
