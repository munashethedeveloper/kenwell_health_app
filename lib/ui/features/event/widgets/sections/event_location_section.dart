import 'package:flutter/material.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../view_model/event_view_model.dart';

/// Event location information form section
class EventLocationSection extends StatelessWidget {
  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredField;

  // Constructor
  const EventLocationSection({
    super.key,
    required this.viewModel,
    required this.requiredField,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Address field
        KenwellTextField(
          label: 'Address',
          controller: viewModel.addressController,
          padding: EdgeInsets.zero,
          validator: (value) => requiredField('Address', value),
        ),
        const SizedBox(height: 24),
        // Town/City field
        KenwellTextField(
          label: 'Town/City',
          controller: viewModel.townCityController,
          padding: EdgeInsets.zero,
          validator: (value) => requiredField('Town/City', value),
        ),
        const SizedBox(height: 24),
        // Province dropdown field
        KenwellDropdownField<String>(
          label: 'Province',
          value: viewModel.province,
          items: const [
            'Gauteng',
            'Western Cape',
            'KwaZulu-Natal',
            'Eastern Cape',
            'Limpopo',
            'Mpumalanga',
            'North West',
            'Free State',
            'Northern Cape'
          ],
          onChanged: (val) {
            if (val != null) viewModel.updateProvince(val);
          },
          decoration: KenwellFormStyles.decoration(
            label: 'Province',
            hint: 'Select Province',
          ),
        ),
        const SizedBox(height: 24),
        // Venue field
        KenwellTextField(
          label: 'Venue',
          controller: viewModel.venueController,
          padding: EdgeInsets.zero,
          validator: (value) => requiredField('Venue', value),
        ),
      ],
    );
  }
}
