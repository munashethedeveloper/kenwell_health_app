import 'package:flutter/material.dart';

import 'kenwell_colors.dart';

/// AppBar with Kenwell default styling and sensible customization hooks.
class KenwellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KenwellAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.titleColor,
    this.actions,
    this.bottom,
  });

  final String title;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? titleColor;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackground =
        backgroundColor ?? KenwellColors.primaryGreen;
    final Color resolvedTitleColor =
        titleColor ?? KenwellColors.secondaryNavy;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: resolvedTitleColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: resolvedBackground,
      actions: actions,
      bottom: bottom,
      iconTheme: IconThemeData(color: resolvedTitleColor),
    );
  }

  @override
  Size get preferredSize {
    final double height = kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    return Size.fromHeight(height);
  }
}
