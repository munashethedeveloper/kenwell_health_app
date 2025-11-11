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
    final effectiveOnChanged = enabled ? onChanged : null;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: textStyle),
          RadioGroup<T>(
            groupValue: value,
            onChanged: effectiveOnChanged,
            builder: (groupValue, handler) {
              final tiles = [
                _KenwellRadioTile<T>(
                  label: yesLabel,
                  value: yesValue,
                  groupValue: groupValue,
                  onChanged: handler,
                ),
                _KenwellRadioTile<T>(
                  label: noLabel,
                  value: noValue,
                  groupValue: groupValue,
                  onChanged: handler,
                ),
              ];

              return axis == Axis.horizontal
                  ? Row(
                      children: tiles
                          .map((tile) => Expanded(child: tile))
                          .toList(growable: false),
                    )
                  : Column(children: tiles);
            },
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
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      dense: true,
    );
  }
}

class RadioGroup<T> extends StatelessWidget {
  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.builder,
  });

  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget Function(T? groupValue, ValueChanged<T?>? onChanged) builder;

  @override
  Widget build(BuildContext context) => builder(groupValue, onChanged);
}
