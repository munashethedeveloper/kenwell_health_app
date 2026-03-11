import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';

/// Modern section header widget used across all screens.
/// Mirrors the canonical gradient-header pattern: KenwellSectionLabel pill →
/// bold title (28 px / w800) → descriptive subtitle (14 px).
///
/// Pass [label] to show the green pill badge (recommended for all screens).
/// [showIcon] is kept for legacy callers but defaults to false.
class KenwellModernSectionHeader extends StatelessWidget {
  const KenwellModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.label,
    this.icon = Icons.list_alt_rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.textAlign = TextAlign.start,
    this.uppercase = false,
    this.color,
    this.fontStyle,
    this.fontFamily,
    this.showIcon = false,
  });

  final String title;
  final String? subtitle;

  /// Optional green pill badge label shown above the title, matching the
  /// canonical KenwellSectionLabel pattern used on all gradient headers.
  /// Recommended for all screens. When provided, [showIcon] is not used.
  final String? label;

  final IconData icon;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final bool uppercase;
  final Color? color;
  final FontStyle? fontStyle;
  final String? fontFamily;

  /// Legacy icon-container toggle. Only used when [label] is null.
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: _alignmentFrom(textAlign),
        children: [
          // ── Green pill badge (preferred) ────────────────────────────────
          if (label != null) ...[
            KenwellSectionLabel(label: label!),
            const SizedBox(height: 10),
          ]
          // ── Legacy icon container (only when no label provided) ─────────
          else if (showIcon) ...[
            Align(
              alignment: _alignFrom(textAlign),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.15),
                      theme.primaryColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // ── Title ───────────────────────────────────────────────────────
          Text(
            uppercase ? title.toUpperCase() : title,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color ?? const Color(0xFF201C58),
              letterSpacing: -0.5,
              height: 1.2,
              fontStyle: fontStyle,
              fontFamily: fontFamily,
            ),
          ),
          // ── Subtitle ────────────────────────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: textAlign,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
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

  Alignment _alignFrom(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}
