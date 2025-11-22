import 'package:flutter/material.dart';

class KenwellCheckboxOption {
  const KenwellCheckboxOption({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget? subtitle;
  final bool enabled;
}

/// Helper widget to keep checkbox groups visually consistent.
class KenwellCheckboxGroup extends StatelessWidget {
  const KenwellCheckboxGroup({
    super.key,
    required this.options,
    this.dense = false,
    this.separator,
    this.padding = EdgeInsets.zero,
  });

  final List<KenwellCheckboxOption> options;
  final bool dense;
  final Widget? separator;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: dense,
              title: Text(options[i].label),
              subtitle: options[i].subtitle,
              value: options[i].value,
              onChanged: options[i].enabled ? options[i].onChanged : null,
            ),
            if (separator != null && i != options.length - 1) separator!,
          ],
        ],
      ),
    );
  }
}
