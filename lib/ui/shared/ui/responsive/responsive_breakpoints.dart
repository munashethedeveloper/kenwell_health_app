import 'package:flutter/material.dart';

/// Material Design breakpoints for responsive layouts
class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  /// Compact: < 600 (phones in portrait)
  static const double compact = 600;

  /// Medium: 600 - 840 (tablets, phones in landscape)
  static const double medium = 840;

  /// Expanded: 840 - 1200 (tablets in landscape, small desktops)
  static const double expanded = 1200;

  /// Large: 1200 - 1600 (desktops)
  static const double large = 1600;

  /// Extra Large: > 1600 (ultra-wide displays)
  static const double extraLarge = 1600;

  static ScreenSize getScreenSize(double width) {
    if (width < compact) {
      return ScreenSize.compact;
    } else if (width < medium) {
      return ScreenSize.medium;
    } else if (width < expanded) {
      return ScreenSize.expanded;
    } else if (width < extraLarge) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compact;
  }

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= medium && width < expanded;
  }

  static bool isLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= expanded && width < extraLarge;
  }

  static bool isExtraLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= extraLarge;
  }

  /// Returns true for tablet and larger screens
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= compact;
  }

  /// Returns true for desktop screens
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= medium;
  }
}

enum ScreenSize {
  compact,
  medium,
  expanded,
  large,
  extraLarge,
}
