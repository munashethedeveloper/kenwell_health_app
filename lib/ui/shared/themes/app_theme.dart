import 'package:flutter/material.dart';

import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Material 3 theme definitions tuned for Kenwell's green + navy brand palette.
class AppTheme {
  const AppTheme._();

  static final ColorScheme _lightColorScheme = ColorScheme.light(
    primary: KenwellColors.primaryGreen,
    onPrimary: KenwellColors.neutralWhite,
    secondary: KenwellColors.secondaryNavy,
    onSecondary: KenwellColors.neutralWhite,
    tertiary: KenwellColors.primaryGreenLight,
    onTertiary: KenwellColors.secondaryNavy,
    surface: KenwellColors.neutralWhite,
    onSurface: KenwellColors.secondaryNavy,
    surfaceVariant: KenwellColors.neutralSurface,
    onSurfaceVariant: KenwellColors.neutralGrey,
    background: KenwellColors.neutralBackground,
    onBackground: KenwellColors.secondaryNavy,
    error: KenwellColors.error,
    onError: KenwellColors.neutralWhite,
    outline: KenwellColors.neutralDivider,
    outlineVariant: KenwellColors.neutralGrey,
    inverseSurface: KenwellColors.secondaryNavy,
    onInverseSurface: KenwellColors.neutralWhite,
    inversePrimary: KenwellColors.primaryGreenDark,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: KenwellColors.secondaryNavy,
    onPrimary: KenwellColors.neutralWhite,
    secondary: KenwellColors.primaryGreen,
    onSecondary: KenwellColors.secondaryNavyDark,
    tertiary: KenwellColors.secondaryNavyLight,
    onTertiary: KenwellColors.neutralWhite,
    surface: KenwellColors.secondaryNavyDark,
    onSurface: KenwellColors.neutralSurface,
    surfaceVariant: KenwellColors.secondaryNavy,
    onSurfaceVariant: KenwellColors.primaryGreenLight,
    background: const Color(0xFF0E1024),
    onBackground: KenwellColors.neutralSurface,
    error: KenwellColors.error,
    onError: KenwellColors.neutralWhite,
    outline: KenwellColors.secondaryNavyLight,
    outlineVariant: KenwellColors.secondaryNavyLight,
    inverseSurface: KenwellColors.neutralSurface,
    onInverseSurface: KenwellColors.secondaryNavy,
    inversePrimary: KenwellColors.primaryGreenLight,
  );

  static ThemeData get lightTheme => _baseTheme(_lightColorScheme);

  static ThemeData get darkTheme => _baseTheme(_darkColorScheme);

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _buildTextTheme(colorScheme, isDark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          side: BorderSide(color: colorScheme.secondary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? KenwellColors.secondaryNavy : KenwellColors.neutralWhite,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color:
            isDark ? KenwellColors.secondaryNavy : KenwellColors.neutralWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: colorScheme.outline.withOpacity(0.5),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.secondary.withOpacity(0.2),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? KenwellColors.secondaryNavyLight : colorScheme.secondary,
        contentTextStyle: TextStyle(
          color: isDark
              ? KenwellColors.secondaryNavyDark
              : colorScheme.onSecondary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme, bool isDark) {
    final Color baseColor = isDark ? Colors.black : colorScheme.onBackground;
    final Color secondaryTextColor =
        isDark ? Colors.black : colorScheme.onSurfaceVariant;
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: secondaryTextColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.black : colorScheme.onPrimary,
      ),
    );
  }
}
