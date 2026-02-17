import 'package:flutter/material.dart';

/// Standardised modern section heading used across Kenwell forms.
/// Features a gradient background, optional icon, and enhanced typography.
class KenwellSectionHeader extends StatelessWidget {
  const KenwellSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.padding = const EdgeInsets.only(bottom: 24),
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.uppercase = false,
    this.showBackground = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final int? maxLines;
  final bool uppercase;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Modern design with background
    if (showBackground) {
      return Padding(
        padding: padding,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.08),
                theme.primaryColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: _alignmentFrom(textAlign),
            children: [
              Row(
                mainAxisAlignment: _mainAxisAlignmentFrom(textAlign),
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      uppercase ? title.toUpperCase() : title,
                      textAlign: textAlign,
                      maxLines: maxLines,
                      overflow: maxLines != null ? TextOverflow.ellipsis : null,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: textAlign,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Legacy design without background (for backward compatibility)
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: _alignmentFrom(textAlign),
        children: [
          Row(
            mainAxisAlignment: _mainAxisAlignmentFrom(textAlign),
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xFF201C58),
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  uppercase ? title.toUpperCase() : title,
                  textAlign: textAlign,
                  maxLines: maxLines,
                  overflow: maxLines != null ? TextOverflow.ellipsis : null,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: const Color(0xFF201C58),
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: textAlign,
              style: theme.textTheme.bodyMedium?.copyWith(
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

  MainAxisAlignment _mainAxisAlignmentFrom(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.right:
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }
}
