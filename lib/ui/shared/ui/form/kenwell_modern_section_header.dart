import 'package:flutter/material.dart';

/// Modern section header widget extracted from User Management Screen's Create User Tab.
/// Features a gradient icon container, bold title, and descriptive subtitle.
class KenwellModernSectionHeader extends StatelessWidget {
  const KenwellModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.list_alt_rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.textAlign = TextAlign.start,
    this.uppercase = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: _mainAxisAlignmentFrom(textAlign),
        children: [
          Container(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: _alignmentFrom(textAlign),
              children: [
                Text(
                  uppercase ? title.toUpperCase() : title,
                  textAlign: textAlign,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF201C58),
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
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
          ),
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
