import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_radius.dart';
import 'app_sizes.dart';
import 'med_ref_colors.dart';

/// Builds the light/dark [ThemeData] pair from the MedRef design tokens.
///
/// Widgets must read colors and type only through `Theme.of(context)` and
/// `context.medRefColors` — never hex literals — so both themes stay in sync
/// and golden tests can snapshot either one from the same widget tree.
abstract final class AppTheme {
  static ThemeData get light => _build(_lightScheme, MedRefColors.light);
  static ThemeData get dark => _build(_darkScheme, MedRefColors.dark);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0B6E69),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDFF1EF),
    onPrimaryContainer: Color(0xFF0A5A56),
    secondary: Color(0xFF0B6E69),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDECEB),
    onErrorContainer: Color(0xFFB42318),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111A1A),
    surfaceContainerHighest: Color(0xFFEDF1F1),
    outlineVariant: Color(0xFFDDE3E3),
    outline: Color(0xFFDDE3E3),
    scrim: Color(0x66111A1A),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4FD1C5),
    onPrimary: Color(0xFF042220),
    primaryContainer: Color(0xFF113331),
    onPrimaryContainer: Color(0xFF7FE0D6),
    secondary: Color(0xFF4FD1C5),
    onSecondary: Color(0xFF042220),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF3A1A18),
    errorContainer: Color(0xFF3A1A18),
    onErrorContainer: Color(0xFFFF8A80),
    surface: Color(0xFF172020),
    onSurface: Color(0xFFEEF3F3),
    surfaceContainerHighest: Color(0xFF212B2B),
    outlineVariant: Color(0xFF2C3838),
    outline: Color(0xFF2C3838),
    scrim: Color(0x99000000),
  );

  static const _bgLight = Color(0xFFF4F6F6);
  static const _bgDark = Color(0xFF0E1313);

  static ThemeData _build(ColorScheme scheme, MedRefColors tokens) {
    final baseTextTheme = GoogleFonts.interTextTheme(
      scheme.brightness == Brightness.light
          ? Typography.blackMountainView
          : Typography.whiteMountainView,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final textTheme = baseTextTheme.copyWith(
      displaySmall: GoogleFonts.inter(
        fontSize: 34,
        height: 41 / 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: scheme.onSurface,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        height: 25 / 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: tokens.inkMuted,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: tokens.inkMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w600,
      ),
    );

    final scaffoldBg =
        scheme.brightness == Brightness.light ? _bgLight : _bgDark;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      extensions: [tokens],
      splashFactory: NoSplash.splashFactory,
      dividerColor: scheme.outlineVariant,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            scheme.brightness == Brightness.light ? _bgLight : _bgDark,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.displaySmall,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.inkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonH),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          textStyle: textTheme.labelLarge,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.7),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppSizes.tapMin),
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color:
                states.contains(WidgetState.selected)
                    ? scheme.primary
                    : tokens.inkSubtle,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSizes.iconMd,
            color:
                states.contains(WidgetState.selected)
                    ? scheme.primary
                    : tokens.inkSubtle,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.surface),
        actionTextColor: scheme.primary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
