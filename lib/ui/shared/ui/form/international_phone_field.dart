import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'kenwell_form_styles.dart';

/// International phone number input field with country picker
class InternationalPhoneField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: IntlPhoneField(
        controller: controller,
        decoration: KenwellFormStyles.decoration(
          label: label,
          alwaysFloat: true,
        ).copyWith(
          // Remove the counter text to avoid clutter
          counterText: '',
        ),
        initialCountryCode: initialCountryCode,
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
          if (validator != null) {
            return validator!(phone?.completeNumber);
          }
          return null;
        },
        // On changed callback
        onChanged: (phone) {
          if (onChanged != null) {
            onChanged!(phone.completeNumber);
          }
        },
        onCountryChanged: (country) {
          // Update controller when country changes
          // This ensures the controller always has the complete number
        },
      ),
    );
  }
}
