import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// AppBar with Kenwell default styling and sensible customization hooks.
///
/// Uses a branded gradient background (navy → purple → dark-green) by default,
/// matching the Registration Management screen header. Pass [useGradient: false]
/// to opt out of the gradient and fall back to [backgroundColor].
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
    this.useGradient = true,
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

  /// When true (default) the app bar shows the branded gradient.
  final bool useGradient;

  // Brand gradient shared by every KenwellAppBar
  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      KenwellColors.secondaryNavy,
      Color(0xFF2E2880),
      KenwellColors.primaryGreenDark,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget = subtitle != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
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
        : Text(title, style: titleStyle);

    return AppBar(
      title: titleWidget,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      // When gradient is active the background must be transparent so the
      // flexibleSpace gradient shows through.
      backgroundColor: useGradient
          ? Colors.transparent
          : (backgroundColor ?? KenwellColors.primaryGreen),
      foregroundColor: titleColor ?? Colors.white,
      elevation: 0,
      actions: actions,
      bottom: bottom,
      // Gradient painted behind everything via flexibleSpace
      flexibleSpace: useGradient
          ? Container(decoration: const BoxDecoration(gradient: _gradient))
          : null,
    );
  }

  @override
  Size get preferredSize {
    final double height = kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    return Size.fromHeight(height);
  }
}
