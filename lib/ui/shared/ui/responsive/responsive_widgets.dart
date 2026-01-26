import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Provides responsive padding based on screen size following Material Design guidelines
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.compact = const EdgeInsets.all(16),
    this.medium,
    this.expanded,
    this.large,
  });

  final Widget child;
  final EdgeInsets compact;
  final EdgeInsets? medium;
  final EdgeInsets? expanded;
  final EdgeInsets? large;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenSize = ResponsiveBreakpoints.getScreenSize(width);

    EdgeInsets padding;
    switch (screenSize) {
      case ScreenSize.compact:
        padding = compact;
        break;
      case ScreenSize.medium:
        padding = medium ?? const EdgeInsets.all(24);
        break;
      case ScreenSize.expanded:
        padding = expanded ?? const EdgeInsets.all(32);
        break;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        padding =
            large ?? const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
        break;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Centers content with a maximum width for better readability on large screens
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Provides responsive column count for grid layouts
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.compactColumns = 1,
    this.mediumColumns = 2,
    this.expandedColumns = 3,
    this.largeColumns = 4,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> children;
  final int compactColumns;
  final int mediumColumns;
  final int expandedColumns;
  final int largeColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenSize = ResponsiveBreakpoints.getScreenSize(width);

    int columns;
    switch (screenSize) {
      case ScreenSize.compact:
        columns = compactColumns;
        break;
      case ScreenSize.medium:
        columns = mediumColumns;
        break;
      case ScreenSize.expanded:
        columns = expandedColumns;
        break;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        columns = largeColumns;
        break;
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: (width - (spacing * (columns - 1))) / columns - spacing,
          child: child,
        );
      }).toList(),
    );
  }
}
