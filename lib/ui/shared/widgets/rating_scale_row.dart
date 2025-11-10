import 'package:flutter/material.dart';

class RatingScaleRow extends StatelessWidget {
  const RatingScaleRow({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 5,
    this.padding = const EdgeInsets.only(bottom: 12),
    this.dense = true,
  }) : assert(min <= max, 'min should be less than or equal to max');

  final String question;
  final int? value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final EdgeInsetsGeometry padding;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final items = List<int>.generate(max - min + 1, (index) => min + index);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          RadioGroup<int>(
            groupValue: value,
            onChanged: (val) {
              if (val != null) {
                onChanged(val);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items
                  .map(
                    (score) => Expanded(
                      child: RadioListTile<int>(
                        dense: dense,
                        title: Text('$score'),
                        value: score,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
