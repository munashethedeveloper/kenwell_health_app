import 'package:flutter/material.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../view_model/event_view_model.dart';

/// Event location information form section
class EventLocationSection extends StatefulWidget {
  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredField;

  // Constructor
  const EventLocationSection({
    super.key,
    required this.viewModel,
    required this.requiredField,
  });

  @override
  State<EventLocationSection> createState() => _EventLocationSectionState();
}

class _EventLocationSectionState extends State<EventLocationSection> {
  final FocusNode _addressFocusNode = FocusNode();
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    // Listen for focus changes on address field
    _addressFocusNode.addListener(_onAddressFocusChange);
  }

  @override
  void dispose() {
    _addressFocusNode.removeListener(_onAddressFocusChange);
    _addressFocusNode.dispose();
    super.dispose();
  }

  /// Handle address field focus change
  void _onAddressFocusChange() {
    if (!_addressFocusNode.hasFocus && !_isGeocoding) {
      _geocodeAddress();
    }
  }

  /// Geocode the address and auto-fill fields
  Future<void> _geocodeAddress() async {
    final address = widget.viewModel.addressController.text.trim();
    if (address.isEmpty) return;

    setState(() {
      _isGeocoding = true;
    });

    try {
      await widget.viewModel.geocodeAddress(address);
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Address field
        KenwellTextField(
          label: 'Address',
          controller: widget.viewModel.addressController,
          padding: EdgeInsets.zero,
          validator: (value) => widget.requiredField('Address', value),
          focusNode: _addressFocusNode,
          textInputAction: TextInputAction.done,
          onEditingComplete: () {
            // When user presses enter/done, geocode the address
            _geocodeAddress();
          },
          suffixIcon: _isGeocoding
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 24),
        // Town/City field
        KenwellTextField(
          label: 'Town/City',
          controller: widget.viewModel.townCityController,
          padding: EdgeInsets.zero,
          validator: (value) => widget.requiredField('Town/City', value),
        ),
        const SizedBox(height: 24),
        // Province dropdown field
        KenwellDropdownField<String>(
          label: 'Province',
          value: widget.viewModel.province,
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
            if (val != null) widget.viewModel.updateProvince(val);
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
          controller: widget.viewModel.venueController,
          padding: EdgeInsets.zero,
          validator: (value) => widget.requiredField('Venue', value),
        ),
      ],
    );
  }
}
