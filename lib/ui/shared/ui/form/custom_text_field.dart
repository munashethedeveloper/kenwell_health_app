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
