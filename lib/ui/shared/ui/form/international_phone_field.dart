import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'kenwell_form_styles.dart';

/// International phone number input field with country picker
/// 
/// This widget wraps IntlPhoneField and manages storing the complete
/// international phone number (with country code) in the provided controller.
class InternationalPhoneField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final EdgeInsetsGeometry padding;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String initialCountryCode;

  const InternationalPhoneField({
    super.key,
    required this.label,
    required this.controller,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.validator,
    this.onChanged,
    this.initialCountryCode = 'ZA', // Default to South Africa
  });

  @override
  State<InternationalPhoneField> createState() => _InternationalPhoneFieldState();
}

class _InternationalPhoneFieldState extends State<InternationalPhoneField> {
  // Internal controller for the IntlPhoneField widget
  // This prevents conflicts with the external controller
  late TextEditingController _internalController;
  String _completeNumber = '';

  @override
  void initState() {
    super.initState();
    // Create internal controller
    _internalController = TextEditingController();
    
    // If the external controller has initial value, parse it
    if (widget.controller.text.isNotEmpty) {
      _completeNumber = widget.controller.text;
      // Extract national number from complete number if it starts with +
      if (_completeNumber.startsWith('+')) {
        // Remove country code for display
        // This is a simple approach - IntlPhoneField will handle parsing
        _internalController.text = _completeNumber;
      }
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: IntlPhoneField(
        // Use internal controller to avoid conflicts
        controller: _internalController,
        decoration: KenwellFormStyles.decoration(
          label: widget.label,
          alwaysFloat: true,
        ).copyWith(
          // Remove the counter text to avoid clutter
          counterText: '',
        ),
        initialCountryCode: widget.initialCountryCode,
        // Show country code selector
        showCountryFlag: true,
        showDropdownIcon: true,
        // Enable search
        searchText: 'Search country',
        // Styling
        dropdownIconPosition: IconPosition.trailing,
        flagsButtonPadding: const EdgeInsets.only(left: 12),
        dropdownTextStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF201C58),
        ),
        // Validation
        invalidNumberMessage: 'Invalid phone number',
        validator: (phone) {
          if (widget.validator != null) {
            return widget.validator!(phone?.completeNumber);
          }
          return null;
        },
        // On changed callback - store complete number without interfering with input
        onChanged: (phone) {
          // Store the complete international number
          _completeNumber = phone.completeNumber;
          
          // Update the external controller without triggering rebuilds
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.controller.text != _completeNumber) {
              widget.controller.text = _completeNumber;
            }
          });
          
          // Notify parent if callback provided
          if (widget.onChanged != null) {
            widget.onChanged!(_completeNumber);
          }
        },
      ),
    );
  }
}
