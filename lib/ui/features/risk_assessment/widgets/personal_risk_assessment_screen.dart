import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/personal_risk_assessment_view_model.dart';

class PersonalRiskAssessmentScreen extends StatelessWidget {
  final PersonalRiskAssessmentViewModel viewModel;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isFemale;

  const PersonalRiskAssessmentScreen({
    super.key,
    required this.viewModel,
    required this.isFemale,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PersonalRiskAssessmentViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: const KenwellAppBar(
                title: 'Personal Risk Assessment',
                automaticallyImplyLeading: false),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Section B: Personal Risk Assessment (previous 12 months)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Section 1: Chronic conditions
                  const Text(
                    '1. Do you suffer or take medication for any of the following conditions?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...vm.chronicConditions.keys.map((condition) {
                    return CheckboxListTile(
                      title: Text(condition),
                      value: vm.chronicConditions[condition],
                      onChanged: (val) => vm.toggleCondition(condition, val),
                    );
                  }).toList(),
                  if (vm.chronicConditions['Other'] == true)
                    TextField(
                      controller: vm.otherConditionController,
                      decoration: const InputDecoration(
                        labelText:
                            'If Other, please specify condition and treatment',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Section 2: Exercise
                  const Text(
                    '2. Over the past month, how many days per week have you exercised for 30 minutes or longer?',
                    style: TextStyle(fontSize: 16),
                  ),
                  _buildStringRadioGroup(
                    selected: vm.exerciseFrequency.isEmpty
                        ? null
                        : vm.exerciseFrequency,
                    options: const [
                      'Never',
                      'Once/week',
                      'Twice/week',
                      'Three times/week or more',
                    ],
                    onChanged: vm.setExerciseFrequency,
                  ),
                  const SizedBox(height: 16),

                  // Section 3: Smoking
                  const Text(
                    '3. How much do you smoke per day?',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextField(
                    controller: vm.dailySmokeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number per day',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('3.1 What do you smoke?',
                      style: TextStyle(fontSize: 16)),
                  _buildStringRadioGroup(
                    selected: vm.smokeType.isEmpty ? null : vm.smokeType,
                    options: const ['Cigarette', 'Pipe', 'Dagga'],
                    onChanged: vm.setSmokeType,
                  ),
                  const SizedBox(height: 16),

                  // Section 4: Alcohol
                  const Text(
                    '4. How often do you use alcoholic beverages?',
                    style: TextStyle(fontSize: 16),
                  ),
                  _buildStringRadioGroup(
                    selected: vm.alcoholFrequency.isEmpty
                        ? null
                        : vm.alcoholFrequency,
                    options: const [
                      'Never',
                      'On occasion',
                      'Two-three drinks per day',
                      'More than 3 drinks per day',
                      'I often drink too much',
                    ],
                    onChanged: vm.setAlcoholFrequency,
                  ),
                  const SizedBox(height: 16),

                  // Women only
                  if (isFemale) ...[
                    const Text(
                        '5. Have you had a pap smear in the last 24 months?',
                        style: TextStyle(fontSize: 16)),
                    _buildBoolRadioGroup(
                      selected: vm.papSmear,
                      onChanged: vm.setPapSmear,
                    ),
                    const SizedBox(height: 12),
                    const Text('6. Do you examine your breasts regularly?',
                        style: TextStyle(fontSize: 16)),
                    _buildBoolRadioGroup(
                      selected: vm.breastExam,
                      onChanged: vm.setBreastExam,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                        '7. If older than 40, have you had a mammogram done?',
                        style: TextStyle(fontSize: 16)),
                    _buildBoolRadioGroup(
                      selected: vm.mammogram,
                      onChanged: vm.setMammogram,
                    ),
                  ],

                  // Men only
                  if (!isFemale) ...[
                    const Text(
                        '8. If > than 40, have you had your prostate checked?',
                        style: TextStyle(fontSize: 16)),
                    _buildBoolRadioGroup(
                      selected: vm.prostateCheck,
                      onChanged: vm.setProstateCheck,
                    ),
                    const SizedBox(height: 12),
                    const Text('9. Have you been tested for prostate cancer?',
                        style: TextStyle(fontSize: 16)),
                    _buildBoolRadioGroup(
                      selected: vm.prostateTested,
                      onChanged: vm.setProstateTested,
                    ),
                  ],

//buttons
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (onPrevious != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onPrevious,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: vm.isSubmitting
                              ? null
                              : () {
                                  if (!vm.isFormValid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please complete all fields')),
                                    );
                                    return;
                                  }
                                  if (onNext != null) onNext!();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF90C048),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: vm.isSubmitting
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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
        },
      ),
    );
  }

  Widget _buildStringRadioGroup({
    required String? selected,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return RadioGroup<String>(
      groupValue: selected,
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
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
      ),
    );
  }

  Widget _buildBoolRadioGroup({
    required bool? selected,
    required ValueChanged<bool?> onChanged,
  }) {
    return RadioGroup<bool>(
      groupValue: selected,
      onChanged: onChanged,
      child: const Row(
        children: <Widget>[
          Expanded(
            child: RadioListTile<bool>(
              title: Text('Yes'),
              value: true,
            ),
          ),
          Expanded(
            child: RadioListTile<bool>(
              title: Text('No'),
              value: false,
            ),
          ),
        ],
      ),
    );
  }
}
