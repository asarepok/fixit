import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Brand colors. primary drives the whole tonal ColorScheme (nav selection,
// links, focus rings), accent is reserved for the one highest-emphasis
// action on a screen (PrimaryButton) so it stays meaningful instead of
// being painted everywhere. Deliberately not mixed into ColorScheme.seed,
// see AppTheme._build.
class AppColors {
  AppColors._();

  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF5B9BEA);
  static const Color accentLight = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFFFA733);
  static const Color onAccent = Color(0xFF241300);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFC47F0A);
  static const Color error = Color(0xFFC22A2A);

  // The accent shade for whichever brightness is currently active, for the
  // handful of one-off spots (star ratings) that want the brand accent
  // without going through PrimaryButton.
  static Color accentOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? accentDark : accentLight;
}

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = _build(Brightness.light);
  static final ThemeData darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final seed = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final baseTextTheme = (isDark
            ? Typography.whiteMountainView
            : Typography.blackMountainView)
        .apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface);

    final textTheme = GoogleFonts.interTextTheme(baseTextTheme).copyWith(
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: colorScheme.onSurface),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: colorScheme.onSurfaceVariant),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,

      // A quiet, surface-colored bar rather than a solid block of brand
      // color on every single screen. Keeps the accent color meaningful
      // when it does show up, instead of fighting for attention on every
      // AppBar. scrolledUnderElevation gives the standard M3 "content
      // scrolled under the bar" cue instead of a permanent shadow.
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        scrolledUnderElevation: 3,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Shape and type only, deliberately no color/minimumSize here so a
      // FilledButton.tonal keeps its own automatic secondary-container
      // color, and an inline button (like the mode-switch pill) doesn't
      // get forced to full width. PrimaryButton sets accent color and
      // width itself for the one-CTA-per-screen case.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14.5),
          shape: const StadiumBorder(),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.outlineVariant),
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.55 : 0.7,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        height: 66,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
