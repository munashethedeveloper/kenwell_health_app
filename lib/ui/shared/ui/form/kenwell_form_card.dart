import 'package:flutter/material.dart';

/// Consistent card wrapper for grouped form content.
class KenwellFormCard extends StatelessWidget {
  const KenwellFormCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16),
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF201C58),
        );

    return Card(
      margin: margin,
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || subtitle != null || trailing != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: titleStyle,
                            ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}
