import 'package:flutter/material.dart';

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
  final ValueChanged<T> onChanged;
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
    final ValueChanged<T?> effectiveOnChanged = (T? val) {
      if (enabled && val != null) onChanged(val);
    };

    final tiles = [
      _KenwellRadioTile<T>(label: yesLabel, value: yesValue),
      _KenwellRadioTile<T>(label: noLabel, value: noValue),
    ];

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: textStyle),
          RadioGroup<T>(
            groupValue: value,
            onChanged: effectiveOnChanged,
            child: axis == Axis.horizontal
                ? Row(
                    children: tiles
                        .map((tile) => Expanded(child: tile))
                        .toList(growable: false),
                  )
                : Column(children: tiles),
          ),
        ],
      ),
    );
  }
}

class _KenwellRadioTile<T> extends StatelessWidget {
  const _KenwellRadioTile({
    required this.label,
    required this.value,
  });

  final String label;
  final T value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(label),
      value: value,
      dense: true,
      toggleable: false,
    );
  }
}
