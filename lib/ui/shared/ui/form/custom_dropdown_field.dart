import 'package:flutter/material.dart';

import 'kenwell_form_styles.dart';

class KenwellDropdownField<T> extends StatelessWidget {
  const KenwellDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.optionLabelBuilder,
    this.decoration,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.isExpanded = true,
    this.hint,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.alwaysFloatLabel = true,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final EdgeInsetsGeometry padding;
  final String Function(T value)? optionLabelBuilder;
  final InputDecoration? decoration;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final bool enabled;
  final bool isExpanded;
  final Widget? hint;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool alwaysFloatLabel;

  @override
  Widget build(BuildContext context) {
    final InputDecoration inputDecoration = decoration ??
        KenwellFormStyles.decoration(
          label: label,
          hint: hintText ?? 'Select $label',
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          alwaysFloat: alwaysFloatLabel,
        );

    return Padding(
      padding: padding,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: inputDecoration,
        validator: validator,
        onSaved: onSaved,
        isExpanded: isExpanded,
        hint: hint,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(optionLabelBuilder?.call(item) ?? item.toString()),
              ),
            )
            .toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
