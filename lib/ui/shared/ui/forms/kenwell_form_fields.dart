import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KenwellTextField extends StatelessWidget {
  const KenwellTextField({
    super.key,
    required this.label,
    required this.controller,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.enabled,
    this.inputFormatters,
    this.decoration,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.expands = false,
  });

  final String label;
  final TextEditingController controller;
  final EdgeInsetsGeometry padding;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool expands;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = decoration ??
        InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        );

    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        obscureText: obscureText,
        maxLines: expands ? null : maxLines,
        minLines: expands ? null : minLines,
        expands: expands,
        focusNode: focusNode,
        enabled: enabled,
        inputFormatters: inputFormatters,
        decoration: inputDecoration,
        textCapitalization: textCapitalization,
        autofocus: autofocus,
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final inputDecoration = decoration ??
        InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        );

    return Padding(
      padding: padding,
      child: DropdownButtonFormField<T>(
        value: value,
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

class KenwellYesNoQuestion<T> extends StatelessWidget {
  const KenwellYesNoQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    required this.yesValue,
    required this.noValue,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.axis = Axis.horizontal,
    this.textStyle,
    this.yesLabel = 'Yes',
    this.noLabel = 'No',
    this.enabled = true,
  });

  final String question;
  final T? value;
  final ValueChanged<T?> onChanged;
  final T yesValue;
  final T noValue;
  final EdgeInsetsGeometry padding;
  final Axis axis;
  final TextStyle? textStyle;
  final String yesLabel;
  final String noLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: textStyle),
          if (axis == Axis.horizontal)
            Row(
              children: [
                Expanded(
                  child: RadioListTile<T>(
                    title: Text(yesLabel),
                    value: yesValue,
                    groupValue: value,
                    onChanged: enabled ? onChanged : null,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<T>(
                    title: Text(noLabel),
                    value: noValue,
                    groupValue: value,
                    onChanged: enabled ? onChanged : null,
                    dense: true,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                RadioListTile<T>(
                  title: Text(yesLabel),
                  value: yesValue,
                  groupValue: value,
                  onChanged: enabled ? onChanged : null,
                  dense: true,
                ),
                RadioListTile<T>(
                  title: Text(noLabel),
                  value: noValue,
                  groupValue: value,
                  onChanged: enabled ? onChanged : null,
                  dense: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
