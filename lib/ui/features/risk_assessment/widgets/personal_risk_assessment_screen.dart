import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            appBar: AppBar(
              title: const Text(
                'Personal Health Risk Assessment',
                style: TextStyle(
                  color: Color(0xFF201C58),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF90C048),
              centerTitle: true,
            ),
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
                  _buildRadio(vm, 'Never', vm.exerciseFrequency,
                      (val) => vm.exerciseFrequency = val),
                  _buildRadio(vm, 'Once/week', vm.exerciseFrequency,
                      (val) => vm.exerciseFrequency = val),
                  _buildRadio(vm, 'Twice/week', vm.exerciseFrequency,
                      (val) => vm.exerciseFrequency = val),
                  _buildRadio(
                      vm,
                      'Three times/week or more',
                      vm.exerciseFrequency,
                      (val) => vm.exerciseFrequency = val),
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
                  _buildRadio(vm, 'Cigarette', vm.smokeType,
                      (val) => vm.smokeType = val),
                  _buildRadio(
                      vm, 'Pipe', vm.smokeType, (val) => vm.smokeType = val),
                  _buildRadio(
                      vm, 'Dagga', vm.smokeType, (val) => vm.smokeType = val),
                  const SizedBox(height: 16),

                  // Section 4: Alcohol
                  const Text(
                    '4. How often do you use alcoholic beverages?',
                    style: TextStyle(fontSize: 16),
                  ),
                  _buildRadio(vm, 'Never', vm.alcoholFrequency,
                      (val) => vm.alcoholFrequency = val),
                  _buildRadio(vm, 'On occasion', vm.alcoholFrequency,
                      (val) => vm.alcoholFrequency = val),
                  _buildRadio(vm, 'Two-three drinks per day',
                      vm.alcoholFrequency, (val) => vm.alcoholFrequency = val),
                  _buildRadio(vm, 'More than 3 drinks per day',
                      vm.alcoholFrequency, (val) => vm.alcoholFrequency = val),
                  _buildRadio(vm, 'I often drink too much', vm.alcoholFrequency,
                      (val) => vm.alcoholFrequency = val),
                  const SizedBox(height: 16),

                  // Women only
                  if (isFemale) ...[
                    const Text(
                        '5. Have you had a pap smear in the last 24 months?',
                        style: TextStyle(fontSize: 16)),
                    _buildYesNoRadio(vm, 'papSmear'),
                    const SizedBox(height: 12),
                    const Text('6. Do you examine your breasts regularly?',
                        style: TextStyle(fontSize: 16)),
                    _buildYesNoRadio(vm, 'breastExam'),
                    const SizedBox(height: 12),
                    const Text(
                        '7. If older than 40, have you had a mammogram done?',
                        style: TextStyle(fontSize: 16)),
                    _buildYesNoRadio(vm, 'mammogram'),
                  ],

                  // Men only
                  if (!isFemale) ...[
                    const Text(
                        '8. If > than 40, have you had your prostate checked?',
                        style: TextStyle(fontSize: 16)),
                    _buildYesNoRadio(vm, 'prostateCheck'),
                    const SizedBox(height: 12),
                    const Text('9. Have you been tested for prostate cancer?',
                        style: TextStyle(fontSize: 16)),
                    _buildYesNoRadio(vm, 'prostateTested'),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (onPrevious != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onPrevious,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                      const SizedBox(width: 12),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: vm.isSubmitting
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text('Next'),
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

  Widget _buildRadio(PersonalRiskAssessmentViewModel vm, String value,
      String groupValue, Function(String) onChanged) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: groupValue,
      onChanged: (val) {
        if (val != null) onChanged(val);
        vm.notifyListeners();
      },
    );
  }

  Widget _buildYesNoRadio(
      PersonalRiskAssessmentViewModel vm, String fieldName) {
    bool? currentValue;
    void Function(bool?)? onChanged;

    switch (fieldName) {
      case 'papSmear':
        currentValue = vm.papSmear;
        onChanged = (val) => vm.papSmear = val;
        break;
      case 'breastExam':
        currentValue = vm.breastExam;
        onChanged = (val) => vm.breastExam = val;
        break;
      case 'mammogram':
        currentValue = vm.mammogram;
        onChanged = (val) => vm.mammogram = val;
        break;
      case 'prostateCheck':
        currentValue = vm.prostateCheck;
        onChanged = (val) => vm.prostateCheck = val;
        break;
      case 'prostateTested':
        currentValue = vm.prostateTested;
        onChanged = (val) => vm.prostateTested = val;
        break;
    }

    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Yes'),
            value: true,
            groupValue: currentValue,
            onChanged: (val) {
              onChanged?.call(val);
              vm.notifyListeners();
            },
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('No'),
            value: false,
            groupValue: currentValue,
            onChanged: (val) {
              onChanged?.call(val);
              vm.notifyListeners();
            },
          ),
        ),
      ],
    );
  }
}
