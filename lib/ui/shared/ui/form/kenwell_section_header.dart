import 'package:flutter/material.dart';

/// Standardised section heading used across Kenwell forms.
class KenwellSectionHeader extends StatelessWidget {
  const KenwellSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.only(bottom: 24),
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.uppercase = false,
  });

  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final int? maxLines;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme.titleMedium;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: _alignmentFrom(textAlign),
        children: [
          Text(
            uppercase ? title.toUpperCase() : title,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style: theme?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 34,
              color: const Color(0xFF201C58),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C5C5C),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  CrossAxisAlignment _alignmentFrom(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.start;
    }
  }
}
