import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Consistent card wrapper for grouped form content.
///
/// By default, cards with a [title] automatically receive the brand purple
/// gradient border so every form card looks uniform across the app.
/// Pass [useGradient: false] to opt out and render a plain white card instead.
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
    this.borderColor,
    this.useGradient = true,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  /// When provided the card gets a 2-px gradient border and a subtle glow.
  /// Defaults to the brand purple–navy gradient when [useGradient] is true.
  final Gradient? accentBorderGradient;

  /// Optional icon shown next to the title in the card header.
  final IconData? titleIcon;
  final Color? borderColor;

  /// Set to false to suppress the gradient border even when [title] is set.
  final bool useGradient;

  // Default brand gradient used for all titled form cards.
  static const _defaultGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [KenwellColors.secondaryNavyLight, KenwellColors.secondaryNavy],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Resolve the effective accent gradient:
    //  1. Caller-supplied gradient takes highest priority.
    //  2. When useGradient == true and a title is present, use the default brand gradient.
    //  3. Otherwise no gradient (plain card).
    final Gradient? effectiveGradient = accentBorderGradient ??
        (useGradient && title != null ? _defaultGradient : null);

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF201C58),
    );

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          effectiveGradient != null ? 13 : 12,
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
                    if (titleIcon != null && effectiveGradient != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: effectiveGradient,
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
                          if (title != null) Text(title!, style: titleStyle),
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
    if (effectiveGradient != null) {
      return Padding(
        padding: margin,
        child: Container(
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: KenwellColors.secondaryNavy.withValues(alpha: 0.14),
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

    // ── Plain card (no title, or useGradient == false) ────────────────────
    return Card(
      margin: margin,
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
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
                          if (title != null) Text(title!, style: titleStyle),
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
