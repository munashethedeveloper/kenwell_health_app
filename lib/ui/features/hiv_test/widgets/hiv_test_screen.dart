import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/hiv_test_view_model.dart';

class HIVTestScreen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const HIVTestScreen({super.key, this.onNext, this.onPrevious});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HIVTestViewModel(),
      child: Consumer<HIVTestViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'HIV Test Screening',
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
                  _buildYesNo(
                    context,
                    'Is this your first HIV test?',
                    viewModel.firstHIVTest,
                    viewModel.setFirstHIVTest,
                  ),
                  if (viewModel.firstHIVTest == 'No') ...[
                    const SizedBox(height: 12),
                    _buildTextField('Month of last test (MM)',
                        viewModel.lastTestMonthController),
                    _buildTextField('Year of last test (YYYY)',
                        viewModel.lastTestYearController),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      'What was the result of your last test?',
                      ['Positive', 'Negative'],
                      viewModel.lastTestResult,
                      viewModel.setLastTestResult,
                    ),
                  ],
                  const Divider(height: 32),
                  _buildYesNo(
                      context,
                      'Have you ever shared used needles or syringes with someone?',
                      viewModel.sharedNeedles,
                      viewModel.setSharedNeedles),
                  _buildYesNo(
                      context,
                      'Have you had unprotected sexual intercourse with more than one partner in the last 12 months?',
                      viewModel.unprotectedSex,
                      viewModel.setUnprotectedSex),
                  _buildYesNo(
                      context,
                      'Have you been diagnosed and/or treated for a sexually transmitted infection during the last 12 months?',
                      viewModel.treatedSTI,
                      viewModel.setTreatedSTI),
                  _buildYesNo(
                      context,
                      'Have you been diagnosed and/or treated for TB during the last 12 months?',
                      viewModel.treatedTB,
                      viewModel.setTreatedTB),
                  _buildYesNo(context, 'Do you sometimes not use a condom?',
                      viewModel.noCondomUse, viewModel.setNoCondomUse),
                  if (viewModel.noCondomUse == 'Yes') ...[
                    _buildTextField(
                        'If yes, why do you sometimes not use a condom?',
                        viewModel.noCondomReasonController),
                  ],
                  const Divider(height: 32),
                  _buildYesNo(
                      context,
                      'Do you know the HIV status of your regular sex partner/s?',
                      viewModel.knowPartnerStatus,
                      viewModel.setKnowPartnerStatus),
                  const SizedBox(height: 12),
                  const Text(
                    'Reasons that may have put you at risk:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildRiskReason(viewModel, 'Partner has been unfaithful'),
                  _buildRiskReason(viewModel,
                      'Exposed to another person’s body fluids while assisting with an injury'),
                  _buildRiskReason(viewModel,
                      'A partner who had a sexually transmitted infection'),
                  _buildRiskReason(viewModel,
                      'A partner who injects drugs and shares needles with other people'),
                  _buildRiskReason(viewModel, 'Rape'),
                  _buildRiskReason(viewModel, 'Other (specify below)'),
                  _buildTextField(
                      'If other, specify', viewModel.otherRiskReasonController),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (onPrevious != null)
                        ElevatedButton(
                          onPressed: onPrevious,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Back'),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              viewModel.isFormValid && !viewModel.isSubmitting
                                  ? () => viewModel.submitHIVTest(onNext)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF201C58),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: viewModel.isSubmitting
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text(
                                  'Submit & Continue',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
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

  Widget _buildYesNo(BuildContext context, String question, String? value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          RadioGroup<String>(
            groupValue: value,
            onChanged: onChanged,
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
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildRiskReason(HIVTestViewModel vm, String label) {
    return CheckboxListTile(
      title: Text(label),
      value: vm.riskReasons.contains(label),
      onChanged: (_) => vm.toggleRiskReason(label),
    );
  }
}
