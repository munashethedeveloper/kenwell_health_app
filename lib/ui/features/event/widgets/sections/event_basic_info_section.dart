import 'package:flutter/material.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_date_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../view_model/event_view_model.dart';

/// Event basic information form section (date and title only)
class EventBasicInfoSection extends StatelessWidget {
  final EventViewModel viewModel;
  final DateTime date;
  final String? Function(String?, String?) requiredField;

  // Constructor
  const EventBasicInfoSection({
    super.key,
    required this.viewModel,
    required this.date,
    required this.requiredField,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Event Date (read-only)
        KenwellDateField(
          label: 'Event Date',
          controller: viewModel.dateController,
          dateFormat: 'yyyy-MM-dd',
          initialDate: date,
          enabled: false,
        ),
        const SizedBox(height: 24),
        // Client Organization
        KenwellFormCard(
          title: 'Client Organization',
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Organization Name
              KenwellTextField(
                label: 'Event Title',
                controller: viewModel.titleController,
                padding: EdgeInsets.zero,
                validator: (value) => requiredField('Event Title', value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
