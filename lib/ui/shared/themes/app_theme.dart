import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Material 3 theme definitions tuned for Kenwell's brand palette.
/// Minimal changes from your existing theme, but the dark theme has been
/// adjusted to be much softer, less saturated, and easier on the eyes:
/// - darker, warmer background + slightly lighter surfaces for depth
/// - muted outline/surfaceVariant for low-contrast separators
/// - app bar uses surface in dark mode (reduces bright bars)
/// - button and snackbar colors are toned down in dark mode
class AppTheme {
  const AppTheme._();

  // --------------------------
  // LIGHT COLOR SCHEME (unchanged)
  // --------------------------
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: KenwellColors.primaryGreen,
    brightness: Brightness.light,
    primary: KenwellColors.primaryGreen,
    secondary: KenwellColors.secondaryNavy,
    tertiary: KenwellColors.primaryGreenLight,
    error: KenwellColors.error,
    //surface: KenwellColors.neutralBackground,

    //background: KenwellColors.neutralBackground,
    surface: KenwellColors.neutralWhite,
  );

  // --------------------------
  // DARK COLOR SCHEME (adjusted for comfort)
  // --------------------------
  // Build on ColorScheme.dark() and override a few tokens so we keep
  // accessible contrast but avoid very bright surfaces/accents.
  static final ColorScheme _darkColorScheme = const ColorScheme.dark().copyWith(
    brightness: Brightness.dark,
    // Keep Kenwell accents but use the lighter green for primary (friendly accent)
    primary: KenwellColors.primaryGreenLight,
    // Use a muted navy-green for secondary accents (less punchy than full navy)
    secondary: KenwellColors.secondaryNavyLight,
    // Surface slightly lighter than background to create comfortable depth
    surface: const Color(0xFF0F1724),
    // Slightly lifted variant for cards and panels
    surfaceContainerHighest: const Color(0xFF172231),
    // Muted outlines for dividers and boundaries
    outline: const Color(0xFF2A3845),
    // Softer onSurface/onBackground so text isn't pure white
    onSurface: const Color(0xFFE6EEF2),
    // Keep your configured error color
    error: KenwellColors.error,
    onPrimary: const Color(0xFF05140E),
    onSecondary: const Color(0xFFEAF7F0),
    tertiary: KenwellColors.secondaryNavyLight,
  );

  static ThemeData get lightTheme => _baseTheme(_lightColorScheme);
  static ThemeData get darkTheme => _baseTheme(_darkColorScheme);

  // --------------------------
  // BASE THEME
  // --------------------------
  static ThemeData _baseTheme(ColorScheme colorScheme) {
    const double cornerRadius = 12;
    const EdgeInsetsGeometry buttonPadding =
        EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // --------------------------
      // APP BAR (Material 3 Compliant)
      // - In dark mode we use surface for the app bar background to avoid a bright
      //   color stripe across the UI which can be harsh. In light mode we keep
      //   the primary color as before.
      // --------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? colorScheme.surface
            : colorScheme.primary,
        foregroundColor: colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: _buildTextTheme(colorScheme).titleLarge,
      ),

      // --------------------------
      // TEXT
      // --------------------------
      textTheme: _buildTextTheme(colorScheme),

      // --------------------------
      // BUTTONS (Material 3)
      // - Use toned-down backgrounds in dark mode so buttons don't glow.
      // --------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((_) {
            if (colorScheme.brightness == Brightness.dark) {
              // slightly muted accent for dark theme
              return colorScheme.primary.withAlpha(220);
            }
            return colorScheme.secondary;
          }),
          foregroundColor: WidgetStateProperty.all(colorScheme.onSecondary),
          padding: WidgetStateProperty.all(buttonPadding),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(colorScheme.secondary),
          side: WidgetStateProperty.all(
            BorderSide(color: colorScheme.outline),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
          padding: WidgetStateProperty.all(buttonPadding),
        ),
      ),

      // --------------------------
      // INPUT FIELDS
      // --------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.72),

          //color: colorScheme.onSurface.withOpacity(0.72)
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.80),

          //color: colorScheme.onSurface.withOpacity(0.80)
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),

      // --------------------------
      // CARDS
      // --------------------------
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // --------------------------
      // DIVIDERS
      // --------------------------
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.6),
        //colorScheme.outline.withOpacity(0.6),
        thickness: 1,
      ),

      // --------------------------
      // CHIPS
      // --------------------------
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        disabledColor: colorScheme.surface,
        selectedColor: colorScheme.primary.withValues(alpha: 0.14),

        //colorScheme.primary.withOpacity(0.14),
        secondarySelectedColor: colorScheme.primary.withValues(alpha: 0.18),
        //colorScheme.primary.withOpacity(0.18),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // --------------------------
      // SNACKBAR
      // --------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.secondary,
        contentTextStyle: TextStyle(
            color: colorScheme.brightness == Brightness.dark
                ? colorScheme.onSurface
                : colorScheme.onSecondary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // --------------------------
  // TEXT THEME (CLEAN MATERIAL 3)
  // --------------------------
  static TextTheme _buildTextTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: scheme.onSurface.withValues(alpha: 0.92),

        // color: scheme.onSurface.withOpacity(0.92),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onPrimary,
      ),
    );
  }
}
