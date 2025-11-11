import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(
        title: const Text(
          'TB: Nurse Intervention',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Referral Nursing Interventions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Member not referred – reason?'),
              value: viewModel.memberNotReferred,
              onChanged: viewModel.toggleMemberNotReferred,
            ),
            if (viewModel.memberNotReferred)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: TextField(
                  controller: viewModel.reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Enter reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),
            const Text(
              'Please make the relevant notes of your session below:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: viewModel.sessionNotesController,
              decoration: const InputDecoration(
                hintText: 'Enter session notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
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
                    onPressed: () => viewModel.saveIntervention(onNext: onNext),
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
}
