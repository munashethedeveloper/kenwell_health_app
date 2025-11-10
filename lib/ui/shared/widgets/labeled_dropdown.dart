import 'package:flutter/material.dart';

typedef OptionTextBuilder<T> = String Function(T value);

class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.displayText,
    this.validator,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<T> options;
  final ValueChanged<T?> onChanged;
  final OptionTextBuilder<T>? displayText;
  final FormFieldValidator<T>? validator;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final optionText = displayText ?? (T value) => value.toString();

    return Padding(
      padding: padding,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        validator: validator,
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem<T>(
                value: option,
                child: Text(optionText(option)),
              ),
            )
            .toList(),
      ),
    );
  }
}
