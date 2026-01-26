import 'package:flutter/material.dart';

/// AppBar with Kenwell default styling and sensible customization hooks.
class KenwellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KenwellAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.titleColor,
    this.titleStyle,
    this.actions,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: subtitle != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle,
                ),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: titleStyle,
            ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: titleColor,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final double height = kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    return Size.fromHeight(height);
  }
}
