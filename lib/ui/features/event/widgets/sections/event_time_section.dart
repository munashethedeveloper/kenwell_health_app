import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../view_model/event_view_model.dart';

/// Event time details form section.
///
/// Contains four [KenwellTextField] fields (Setup, Start, End, Strike-Down).
/// Each field is read-only and opens a 24-hour [showTimePicker] when tapped.
///
/// The picker is shown here (UI layer) and the selected value is forwarded to
/// [EventViewModel.setTime] which handles formatting.  This keeps all
/// [BuildContext]-dependent UI calls out of the ViewModel.
class EventTimeSection extends StatelessWidget {
  const EventTimeSection({
    super.key,
    required this.viewModel,
    required this.requiredField,
  });

  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredField;

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: 'Time Details',
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Setup Time
          KenwellTextField(
            label: 'Setup Time',
            controller: viewModel.setUpTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(Icons.access_time, color: KenwellColors.primaryGreen),
            validator: (value) => requiredField('Setup Time', value),
            onTap: () => _showTimePicker(context, viewModel.setUpTimeController),
          ),
          KenwellFormStyles.fieldSpacing,

          // Start Time
          KenwellTextField(
            label: 'Start Time',
            controller: viewModel.startTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(Icons.access_time, color: KenwellColors.primaryGreen),
            validator: (value) => requiredField('Start Time', value),
            onTap: () => _showTimePicker(context, viewModel.startTimeController),
          ),
          KenwellFormStyles.fieldSpacing,

          // End Time
          KenwellTextField(
            label: 'End Time',
            controller: viewModel.endTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(Icons.access_time, color: KenwellColors.primaryGreen),
            validator: (value) => requiredField('End Time', value),
            onTap: () => _showTimePicker(context, viewModel.endTimeController),
          ),
          KenwellFormStyles.fieldSpacing,

          // Strike Down Time
          KenwellTextField(
            label: 'Strike Down Time',
            controller: viewModel.strikeDownTimeController,
            padding: EdgeInsets.zero,
            readOnly: true,
            suffixIcon: const Icon(Icons.access_time, color: KenwellColors.primaryGreen),
            validator: (value) => requiredField('Strike Down Time', value),
            onTap: () => _showTimePicker(context, viewModel.strikeDownTimeController),
          ),
        ],
      ),
    );
  }

  /// Shows a 24-hour [showTimePicker] dialog and forwards the result to
  /// [EventViewModel.setTime].  Does nothing when the user cancels.
  Future<void> _showTimePicker(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        // Force 24-hour clock regardless of device locale so the stored
        // HH:mm string is always unambiguous.
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null && context.mounted) {
      viewModel.setTime(controller, picked, context);
    }
  }
}
