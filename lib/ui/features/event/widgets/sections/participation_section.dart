import 'package:flutter/material.dart';
import '../../view_model/event_view_model.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_spinbox_field.dart';

/// Event participation numbers form section
class ParticipationSection extends StatelessWidget {
  final EventViewModel viewModel;

  // Constructor for ParticipationSection
  const ParticipationSection({
    super.key,
    required this.viewModel,
  });

  // Build method for ParticipationSection
  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      // Title of the form card
      title: 'Participation Numbers',
      margin: const EdgeInsets.only(bottom: 16),
      child: KenwellSpinBoxField(
        label: 'Expected Participation',
        controller: viewModel.expectedParticipationController,
      ),
    );
  }
}
