import 'package:flutter/material.dart';

/// Consistent card wrapper for grouped form content.
///
/// Supply [accentBorderGradient] (and optionally [titleIcon]) to get a premium
/// gradient-bordered card.  All existing callers without these parameters
/// retain the original Card appearance.
class KenwellFormCard extends StatelessWidget {
  const KenwellFormCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16),
    // Premium accent options
    this.accentBorderGradient,
    this.titleIcon,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  /// When provided the card gets a 2-px gradient border and a subtle glow.
  /// Use brand-purple gradient for form cards, e.g.:
  /// ```dart
  /// accentBorderGradient: const LinearGradient(
  ///   colors: [Color(0xFF7C3AED), Color(0xFF201C58)],
  /// )
  /// ```
  final Gradient? accentBorderGradient;

  /// Optional icon shown next to the title in the card header.
  final IconData? titleIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF201C58),
    );

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          accentBorderGradient != null ? 13 : 12,
        ),
      ),
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
                    if (titleIcon != null && accentBorderGradient != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: accentBorderGradient,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(titleIcon, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(title!, style: titleStyle),
                          if (subtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6B7280),
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

    // ── Premium gradient-border card ─────────────────────────────────────
    if (accentBorderGradient != null) {
      return Padding(
        padding: margin,
        child: Container(
          decoration: BoxDecoration(
            gradient: accentBorderGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: cardContent,
        ),
      );
    }

    // ── Default Card (unchanged appearance) ──────────────────────────────
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
                            Text(title!, style: titleStyle),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
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
