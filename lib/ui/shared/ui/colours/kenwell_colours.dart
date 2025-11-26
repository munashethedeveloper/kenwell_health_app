import 'package:flutter/material.dart';

/// Central place for Kenwell-specific color constants.
/// Contains brand palette + full Material 3 light/dark color schemes.
class KenwellColors {
  const KenwellColors._();

  // ---------------------------------------------------------------------------
  // BRAND COLORS
  // ---------------------------------------------------------------------------

  static const Color primaryGreen = Color(0xFF90C048);
  static const Color primaryGreenDark = Color(0xFF5E8C1F);
  static const Color primaryGreenLight = Color(0xFFCDE8A0);

  static const Color secondaryNavy = Color(0xFF201C58);
  static const Color secondaryNavyDark = Color(0xFF111235);
  static const Color secondaryNavyLight = Color(0xFF3B3F86);

  // ---------------------------------------------------------------------------
  // NEUTRALS
  // ---------------------------------------------------------------------------

  static const Color neutralWhite = Colors.white;
  static const Color neutralBackground = Color(0xFFF6F8F2);
  static const Color neutralSurface = Color(0xFFE9EFE1);
  static const Color neutralGrey = Color(0xFF6B7280);
  static const Color neutralDarkGrey = Color(0xFF1F2933);
  static const Color neutralDivider = Color(0xFFE5E7EB);

  // ---------------------------------------------------------------------------
  // FEEDBACK
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFB3261E);

  // ---------------------------------------------------------------------------
  // FULL MATERIAL 3 LIGHT COLOR SCHEME
  // ---------------------------------------------------------------------------

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryGreen,
    onPrimary: Colors.white,
    primaryContainer: primaryGreenLight,
    onPrimaryContainer: Color(0xFF253600),
    secondary: secondaryNavy,
    onSecondary: Colors.white,
    secondaryContainer: secondaryNavyLight,
    onSecondaryContainer: Colors.white,
    tertiary: primaryGreenDark,
    onTertiary: Colors.white,
    tertiaryContainer: primaryGreenLight,
    onTertiaryContainer: Colors.black,
    error: error,
    onError: Colors.white,
    errorContainer: Color(0xFFFCDAD6),
    onErrorContainer: Color(0xFF370907),
    background: neutralBackground,
    onBackground: Color(0xFF1A1C1A),
    surface: neutralWhite,
    onSurface: Color(0xFF1A1C1A),
    surfaceVariant: neutralSurface,
    onSurfaceVariant: Color(0xFF42494F),
    outline: Color(0xFFD1D5DB),
    outlineVariant: neutralDivider,
    shadow: Colors.black12,
    scrim: Colors.black12,
    inverseSurface: Color(0xFF303034),
    onInverseSurface: Colors.white,
    inversePrimary: primaryGreenDark,
  );

  // ---------------------------------------------------------------------------
  // FULL MATERIAL 3 DARK COLOR SCHEME
  // ---------------------------------------------------------------------------

  static final ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryGreenLight,
    onPrimary: Color(0xFF0E2000),
    primaryContainer: secondaryNavyLight,
    onPrimaryContainer: Color(0xFFEAF7F0),
    secondary: secondaryNavy,
    onSecondary: Color(0xFFE6E6F7),
    secondaryContainer: secondaryNavyDark,
    onSecondaryContainer: Colors.white70,
    tertiary: Color(0xFFA6C77B),
    onTertiary: Color(0xFF111F05),
    error: error,
    onError: Color(0xFFFFF1F1),
    errorContainer: Color(0xFF8C1D13),
    onErrorContainer: Color(0xFFFFF1F1),
    background: Color(0xFF0B0F1A),
    onBackground: Color(0xFFE6EEF2),
    surface: Color(0xFF0F1724),
    onSurface: Color(0xFFE6EEF2),
    surfaceVariant: Color(0xFF1A2434),
    onSurfaceVariant: Color(0xFF9DA7B4),
    outline: Color(0xFF2A3845),
    outlineVariant: Color(0xFF3C4757),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE6EEF2),
    onInverseSurface: Color(0xFF111418),
    inversePrimary: primaryGreen,
  );
}
