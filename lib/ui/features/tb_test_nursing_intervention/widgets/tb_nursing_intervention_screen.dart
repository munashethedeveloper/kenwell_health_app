import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/form_input_borders.dart';

import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/tb_nursing_intervention_view_model.dart';

class TBNursingInterventionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const TBNursingInterventionScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TBNursingInterventionViewModel>(context);

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'TB Test Nursing Intervention',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section J: TB Screening Nursing Interventions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF201C58),
                  ),
            ),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nursing Referrals',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF201C58)),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Member not referred – reason?'),
                    value: viewModel.memberNotReferred,
                    onChanged: viewModel.toggleMemberNotReferred,
                  ),
                  if (viewModel.memberNotReferred)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 8.0, bottom: 8.0),
                      child: TextField(
                        controller: viewModel.reasonController,
                        decoration: _profileFieldDecoration(
                          'Enter reason',
                          'Provide additional detail',
                        ),
                        maxLines: 2,
                      ),
                    ),
                  CheckboxListTile(
                    title: const Text('Member referred to GP'),
                    value: viewModel.referredToGP,
                    onChanged: viewModel.toggleReferredToGP,
                  ),
                  CheckboxListTile(
                    title: const Text('Member referred to state HIV clinic'),
                    value: viewModel.referredToStateHIVClinic,
                    onChanged: viewModel.toggleReferredToStateHIVClinic,
                  ),
                  CheckboxListTile(
                    title: const Text('Member referred for OH consultation'),
                    value: viewModel.referredToOHConsultation,
                    onChanged: viewModel.toggleReferredToOHConsultation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please make the relevant notes of your session below:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF201C58)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: viewModel.sessionNotesController,
                    decoration: _profileFieldDecoration(
                      'Session notes',
                      'Enter session notes...',
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: _buildSignatureSection(viewModel),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (!viewModel.hasSignature) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please capture a signature first.'),
                          ),
                        );
                        return;
                      }
                      viewModel.saveIntervention(onNext: onNext);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Save and Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90C048),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                  ),
                ),
              ],
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

  Widget _buildSignatureSection(TBNursingInterventionViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signature:',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF201C58)),
        ),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(8),
            height: 160,
            child: Signature(
              controller: viewModel.signatureController,
              backgroundColor: Colors.grey[100]!,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: viewModel.clearSignature,
            child: const Text('Clear Signature'),
          ),
        ),
      ],
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
