import 'package:flutter/material.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_date_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../../domain/constants/provinces.dart';
import '../../view_model/event_view_model.dart';

/// Event basic information form section
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
        // Event Location
        KenwellFormCard(
          title: 'Event Location',
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Venue
              KenwellTextField(
                label: 'Venue',
                controller: viewModel.venueController,
                padding: EdgeInsets.zero,
                validator: (value) => requiredField('Venue', value),
              ),
              const SizedBox(height: 24),
              // Address
              KenwellTextField(
                label: 'Address',
                controller: viewModel.addressController,
                padding: EdgeInsets.zero,
                validator: (value) => requiredField('Address', value),
              ),
              const SizedBox(height: 24),
              KenwellTextField(
                // Town/City
                label: 'Town/City',
                controller: viewModel.townCityController,
                padding: EdgeInsets.zero,
                validator: (value) => requiredField('Town/City', value),
              ),
              const SizedBox(height: 24),
              //  Province
              KenwellDropdownField<String>(
                label: 'Province',
                value: viewModel.province,
                items: SouthAfricanProvinces.all,
                onChanged: (val) {
                  if (val != null) viewModel.updateProvince(val);
                },
                decoration: KenwellFormStyles.decoration(
                  label: 'Province',
                  hint: 'Select Province',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
