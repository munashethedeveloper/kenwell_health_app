import 'package:flutter/material.dart';

class RadioOption<T> {
  const RadioOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class QuestionRadioGroup<T> extends StatelessWidget {
  const QuestionRadioGroup({
    super.key,
    this.question,
    required this.value,
    required this.onChanged,
    required this.options,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.direction = Axis.horizontal,
    this.dense = false,
  }) : assert(options.length > 1, 'Provide at least two options.');

  final String? question;
  final T? value;
  final ValueChanged<T?> onChanged;
  final List<RadioOption<T>> options;
  final EdgeInsetsGeometry padding;
  final Axis direction;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tiles = options
        .map(
          (option) => RadioListTile<T>(
            dense: dense,
            title: Text(option.label),
            value: option.value,
          ),
        )
        .toList();

    Widget groupChild;
    if (direction == Axis.horizontal) {
      groupChild = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tiles.map((tile) => Expanded(child: tile)).toList(),
      );
    } else {
      groupChild = Column(children: tiles);
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question != null) ...[
            Text(question!),
            const SizedBox(height: 8),
          ],
          RadioGroup<T>(
            groupValue: value,
            onChanged: onChanged,
            child: groupChild,
          ),
        ],
      ),
    );
  }
}
