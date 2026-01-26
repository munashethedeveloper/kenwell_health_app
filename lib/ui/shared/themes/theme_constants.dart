import 'package:flutter/material.dart';

/// Theme spacing constants
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const verticalMd = EdgeInsets.symmetric(vertical: md);
  static const verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const verticalXl = EdgeInsets.symmetric(vertical: xl);

  static const paddingXs = EdgeInsets.all(xs);
  static const paddingSm = EdgeInsets.all(sm);
  static const paddingMd = EdgeInsets.all(md);
  static const paddingLg = EdgeInsets.all(lg);
  static const paddingXl = EdgeInsets.all(xl);
}

/// Theme radius constants
class AppRadius {
  const AppRadius._();

  static const double sm = 4.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}
