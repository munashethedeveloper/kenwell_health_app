import 'package:flutter/material.dart';
import 'form_input_borders.dart';
import '../colours/kenwell_colours.dart';

/// Central place for common form styling primitives.
class KenwellFormStyles {
  KenwellFormStyles._();

  static const EdgeInsets defaultContentPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 16);

  static const SizedBox fieldSpacing = SizedBox(height: 12);

  static InputDecoration decoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool alwaysFloat = true,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? 'Enter $label',
      floatingLabelBehavior: alwaysFloat
          ? FloatingLabelBehavior.always
          : FloatingLabelBehavior.auto,
      hintStyle: const TextStyle(color: Color(0xFF757575)),
      contentPadding: defaultContentPadding,
      border: authOutlineInputBorder,
      enabledBorder: authOutlineInputBorder,
      focusedBorder: authOutlineInputBorder.copyWith(
        borderSide: const BorderSide(
          color: KenwellColors.secondaryNavy,
          width: 2,
        ),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}
