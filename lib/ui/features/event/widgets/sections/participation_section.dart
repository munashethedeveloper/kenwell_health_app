import 'package:flutter/material.dart';
import '../../view_model/event_view_model.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_spinbox_field.dart';

class ParticipationSection extends StatelessWidget {
  final EventViewModel viewModel;

  const ParticipationSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: 'Participation Numbers',
      margin: const EdgeInsets.only(bottom: 16),
      child: KenwellSpinBoxField(
        label: 'Expected Participation',
        controller: viewModel.expectedParticipationController,
      ),
    );
  }
}
