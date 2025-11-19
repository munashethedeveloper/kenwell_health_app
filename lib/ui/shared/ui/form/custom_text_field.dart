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
    this.hintText,
    this.validator,
  });

  final String label;
  final String? hintText;
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
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = decoration ??
        InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        );

    return Padding(
      padding: padding,
      child: TextFormField(
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
        validator: validator,
      ),
    );
  }
}
