import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'kenwell_form_styles.dart';

/// Reusable spinbox field widget for numeric input
class KenwellSpinBoxField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double min;
  final double max;
  final int decimals;
  final double step;
  final String? hint;

  const KenwellSpinBoxField({
    super.key,
    required this.label,
    required this.controller,
    this.min = 0,
    this.max = 300,
    this.decimals = 0,
    this.step = 1,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final initialValue =
        double.tryParse(controller.text.isEmpty ? '0' : controller.text) ?? 0;

    return SpinBox(
      min: min,
      max: max,
      value: initialValue,
      step: step,
      decimals: decimals,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: false, signed: false),
      decoration: KenwellFormStyles.decoration(
        label: label,
        hint: hint ?? 'Please Enter $label',
      ),
      validator: (value) => value == null ? 'Please Enter $label' : null,
      onChanged: (value) {
        controller.text = value.round().toString();
      },
    );
  }
}
