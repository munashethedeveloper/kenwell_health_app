import 'package:flutter/material.dart';

/// Simple bullet list used across form screens for consistent styling.
class KenwellBulletList extends StatelessWidget {
  final List<String> items;
  final TextStyle? textStyle;
  final double spacing;

  const KenwellBulletList({
    super.key,
    required this.items,
    this.textStyle,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? const TextStyle(fontSize: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(item, style: style)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
