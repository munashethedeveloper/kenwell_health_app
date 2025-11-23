import 'package:flutter/widgets.dart';

import 'custom_yes_no_question.dart';

class KenwellYesNoItem<T> {
  final String question;
  final T? value;
  final ValueChanged<T?> onChanged;
  final T yesValue;
  final T noValue;

  const KenwellYesNoItem({
    required this.question,
    required this.value,
    required this.onChanged,
    required this.yesValue,
    required this.noValue,
  });
}

/// Renders a vertical list of KenwellYesNoQuestion widgets with consistent spacing.
class KenwellYesNoList<T> extends StatelessWidget {
  final List<KenwellYesNoItem<T>> items;
  final double spacing;

  const KenwellYesNoList({
    super.key,
    required this.items,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          KenwellYesNoQuestion<T>(
            question: items[i].question,
            value: items[i].value,
            onChanged: items[i].onChanged,
            yesValue: items[i].yesValue,
            noValue: items[i].noValue,
          ),
          if (i != items.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}
