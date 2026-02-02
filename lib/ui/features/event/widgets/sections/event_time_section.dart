import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../view_model/event_view_model.dart';

/// Event time details form section
class EventTimeSection extends StatelessWidget {
  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredField;

  // Constructor
  const EventTimeSection({
    super.key,
    required this.viewModel,
    required this.requiredField,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    // Return a form card with time detail fields
    return KenwellFormCard(
      title: 'Time Details',
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          KenwellTextField(
            // Setup Time
            label: 'Setup Time',
            controller: viewModel.setUpTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(
              Icons.access_time,
              color: KenwellColors.primaryGreen,
            ),
            validator: (value) => requiredField('Setup Time', value),
            onTap: () =>
                viewModel.pickTime(context, viewModel.setUpTimeController),
          ),
          KenwellFormStyles.fieldSpacing,
          // Start Time
          KenwellTextField(
            label: 'Start Time',
            controller: viewModel.startTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(
              Icons.access_time,
              color: KenwellColors.primaryGreen,
            ),
            validator: (value) => requiredField('Start Time', value),
            onTap: () =>
                viewModel.pickTime(context, viewModel.startTimeController),
          ),
          KenwellFormStyles.fieldSpacing,
          // End Time
          KenwellTextField(
            label: 'End Time',
            controller: viewModel.endTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(
              Icons.access_time,
              color: KenwellColors.primaryGreen,
            ),
            validator: (value) => requiredField('End Time', value),
            onTap: () =>
                viewModel.pickTime(context, viewModel.endTimeController),
          ),
          KenwellFormStyles.fieldSpacing,
          // Strike Down Time
          KenwellTextField(
            label: 'Strike Down Time',
            controller: viewModel.strikeDownTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(
              Icons.access_time,
              color: KenwellColors.primaryGreen,
            ),
            validator: (value) => requiredField('Strike Down Time', value),
            onTap: () =>
                viewModel.pickTime(context, viewModel.strikeDownTimeController),
          ),
        ],
      ),
    );
  }
}
