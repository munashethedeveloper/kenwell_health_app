import 'package:flutter/material.dart';

import 'kenwell_checkbox_group.dart';
import 'kenwell_form_card.dart';

/// Convenience widget for rendering checkbox lists inside a Kenwell form card.
class KenwellCheckboxListCard extends StatelessWidget {
  final String title;
  final List<KenwellCheckboxOption> options;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;

  const KenwellCheckboxListCard({
    super.key,
    required this.title,
    required this.options,
    this.footer,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: title,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KenwellCheckboxGroup(options: options),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}
