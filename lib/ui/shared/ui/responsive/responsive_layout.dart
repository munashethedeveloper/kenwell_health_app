import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Adaptive builder that provides different layouts based on screen size
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  /// Layout for compact screens (< 600px) - Required
  final Widget compact;

  /// Layout for medium screens (600-840px) - Falls back to compact
  final Widget? medium;

  /// Layout for expanded screens (840-1200px) - Falls back to medium or compact
  final Widget? expanded;

  /// Layout for large screens (1200-1600px) - Falls back to expanded, medium, or compact
  final Widget? large;

  /// Layout for extra large screens (> 1600px) - Falls back to large, expanded, medium, or compact
  final Widget? extraLarge;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize =
            ResponsiveBreakpoints.getScreenSize(constraints.maxWidth);

        switch (screenSize) {
          case ScreenSize.compact:
            return compact;
          case ScreenSize.medium:
            return medium ?? compact;
          case ScreenSize.expanded:
            return expanded ?? medium ?? compact;
          case ScreenSize.large:
            return large ?? expanded ?? medium ?? compact;
          case ScreenSize.extraLarge:
            return extraLarge ?? large ?? expanded ?? medium ?? compact;
        }
      },
    );
  }
}

/// Adaptive value selector based on screen size
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  final T compact;
  final T? medium;
  final T? expanded;
  final T? large;
  final T? extraLarge;

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenSize = ResponsiveBreakpoints.getScreenSize(width);

    switch (screenSize) {
      case ScreenSize.compact:
        return compact;
      case ScreenSize.medium:
        return medium ?? compact;
      case ScreenSize.expanded:
        return expanded ?? medium ?? compact;
      case ScreenSize.large:
        return large ?? expanded ?? medium ?? compact;
      case ScreenSize.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact;
    }
  }
}
