import 'package:flutter/material.dart';
import '../colours/kenwell_colours.dart';

/// AppBar with Kenwell default styling and sensible customization hooks.
class KenwellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KenwellAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.titleColor,
    this.titleStyle,
    this.actions,
    this.bottom,
  });

  final String title;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackground =
        backgroundColor ?? KenwellColors.primaryGreen;
    final Color resolvedTitleColor = titleColor ?? KenwellColors.secondaryNavy;
    final TextStyle resolvedTitleStyle = titleStyle ??
        TextStyle(
          color: resolvedTitleColor,
          fontWeight: FontWeight.bold,
        );

    return AppBar(
      title: Text(
        title,
        style: resolvedTitleStyle,
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
