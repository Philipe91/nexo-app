import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// AppTheme — versão "SaaS Boutique + Cinema Dark".
///
/// Tipografia dual: Plus Jakarta Sans (display) + Inter (body) +
/// JetBrains Mono (números tabulares).
class AppTheme {
  AppTheme._();

  // Compatibilidade retroativa — vários arquivos legados ainda referenciam
  // `AppTheme.primary`, `AppTheme.primaryGradient`, etc. Mantemos os símbolos
  // apontando para os tokens novos pra não quebrar build durante a migração.
  static const Color primary = NexoColors.indigo;
  static const Color secondary = NexoColors.indigoSoft;
  static const Color accent = NexoColors.warning;
  static const Color background = NexoColors.lightBg;
  static const Color surface = NexoColors.lightSurface;
  static const Color textPrimary = NexoColors.lightFg;
  static const Color textSecondary = NexoColors.lightFgMuted;
  static const Color darkBackground = NexoColors.darkBg;
  static const Color darkSurface = NexoColors.darkSurface;
  static const Color darkText = NexoColors.darkFg;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [NexoColors.indigo, NexoColors.indigoSoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Type styles (light) ───────────────────────────────────────────────────
  static TextStyle _display(double size, {FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: 1.15,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle _body(double size, {FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: 1.45,
        color: color,
      );

  static TextTheme _textTheme({required Color fg, required Color fgMuted}) {
    return TextTheme(
      displayLarge: _display(NexoText.xxxl, weight: FontWeight.w800, color: fg),
      displayMedium: _display(NexoText.xxl, weight: FontWeight.w800, color: fg),
      displaySmall: _display(NexoText.xl, weight: FontWeight.w700, color: fg),
      headlineMedium: _display(NexoText.lg, weight: FontWeight.w700, color: fg),
      headlineSmall: _display(NexoText.base, weight: FontWeight.w700, color: fg),
      titleLarge: _body(NexoText.base, weight: FontWeight.w600, color: fg),
      titleMedium: _body(NexoText.md, weight: FontWeight.w600, color: fg),
      bodyLarge: _body(NexoText.base, color: fg),
      bodyMedium: _body(NexoText.md, color: fg),
      bodySmall: _body(NexoText.sm, color: fgMuted),
      labelLarge: _body(NexoText.md, weight: FontWeight.w600, color: fg),
      labelMedium: _body(NexoText.sm, weight: FontWeight.w500, color: fgMuted),
      labelSmall: _body(NexoText.xs, weight: FontWeight.w500, color: fgMuted),
    );
  }

  // ── Light ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: NexoColors.indigo,
      onPrimary: Colors.white,
      secondary: NexoColors.indigoSoft,
      onSecondary: Colors.white,
      tertiary: NexoColors.warning,
      onTertiary: Colors.white,
      error: NexoColors.danger,
      onError: Colors.white,
      surface: NexoColors.lightSurface,
      onSurface: NexoColors.lightFg,
      surfaceContainerHighest: NexoColors.lightSurfaceMuted,
      outline: NexoColors.lightBorder,
      outlineVariant: NexoColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NexoColors.lightBg,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _textTheme(fg: NexoColors.lightFg, fgMuted: NexoColors.lightFgMuted),

      iconTheme: const IconThemeData(color: NexoColors.lightFg, size: 22),

      appBarTheme: AppBarTheme(
        backgroundColor: NexoColors.lightBg,
        foregroundColor: NexoColors.lightFg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _display(NexoText.lg, weight: FontWeight.w700, color: NexoColors.lightFg),
      ),

      cardTheme: CardThemeData(
        color: NexoColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NexoRadius.lg),
          side: const BorderSide(color: NexoColors.lightBorder),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NexoColors.indigo,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexoRadius.md)),
          textStyle: _body(NexoText.base, weight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NexoColors.lightFg,
          side: const BorderSide(color: NexoColors.lightBorder),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexoRadius.md)),
          textStyle: _body(NexoText.base, weight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NexoColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: _body(NexoText.md, color: NexoColors.lightFgMuted),
        labelStyle: _body(NexoText.md, color: NexoColors.lightFgMuted),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexoRadius.md),
          borderSide: const BorderSide(color: NexoColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexoRadius.md),
          borderSide: const BorderSide(color: NexoColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexoRadius.md),
          borderSide: const BorderSide(color: NexoColors.indigo, width: 1.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: NexoColors.lightBorder,
        thickness: 1,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NexoColors.lightSurface.withOpacity(0.92),
        indicatorColor: NexoColors.indigoGlow,
        height: 64,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          _body(NexoText.xs, weight: FontWeight.w600, color: NexoColors.lightFg),
        ),
        iconTheme: WidgetStatePropertyAll(
          const IconThemeData(color: NexoColors.lightFgMuted, size: 22),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: NexoColors.lightFg,
        contentTextStyle: _body(NexoText.md, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexoRadius.md)),
      ),
    );
  }

  // ── Dark (Cinema) ─────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: NexoColors.indigoSoft,
      onPrimary: Colors.white,
      secondary: NexoColors.indigo,
      onSecondary: Colors.white,
      tertiary: NexoColors.warningDark,
      onTertiary: Colors.black,
      error: NexoColors.dangerDark,
      onError: Colors.white,
      surface: NexoColors.darkSurface,
      onSurface: NexoColors.darkFg,
      surfaceContainerHighest: NexoColors.darkSurfaceMuted,
      outline: NexoColors.darkBorder,
      outlineVariant: NexoColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NexoColors.darkBg,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _textTheme(fg: NexoColors.darkFg, fgMuted: NexoColors.darkFgMuted),

      iconTheme: const IconThemeData(color: NexoColors.darkFg, size: 22),

      appBarTheme: AppBarTheme(
        backgroundColor: NexoColors.darkBg,
        foregroundColor: NexoColors.darkFg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _display(NexoText.lg, weight: FontWeight.w700, color: NexoColors.darkFg),
      ),

      cardTheme: CardThemeData(
        color: NexoColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NexoRadius.lg),
          side: const BorderSide(color: NexoColors.darkBorder),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NexoColors.indigoSoft,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexoRadius.md)),
          textStyle: _body(NexoText.base, weight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NexoColors.darkFg,
          side: const BorderSide(color: NexoColors.darkBorder),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NexoRadius.md)),
          textStyle: _body(NexoText.base, weight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NexoColors.darkSurfaceMuted,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: _body(NexoText.md, color: NexoColors.darkFgMuted),
        labelStyle: _body(NexoText.md, color: NexoColors.darkFgMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexoRadius.md),
          borderSide: const BorderSide(color: NexoColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexoRadius.md),
          borderSide: const BorderSide(color: NexoColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NexoRadius.md),
          borderSide: const BorderSide(color: NexoColors.indigoSoft, width: 1.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: NexoColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NexoColors.darkSurface.withOpacity(0.92),
        indicatorColor: NexoColors.indigoGlow,
        height: 64,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          _body(NexoText.xs, weight: FontWeight.w600, color: NexoColors.darkFg),
        ),
        iconTheme: WidgetStatePropertyAll(
          const IconThemeData(color: NexoColors.darkFgMuted, size: 22),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: NexoColors.darkSurface,
        contentTextStyle: _body(NexoText.md, color: NexoColors.darkFg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NexoRadius.md),
          side: const BorderSide(color: NexoColors.darkBorder),
        ),
      ),
    );
  }

  /// Texto monoespaçado pra números, códigos de convite, valores tabulares.
  static TextStyle mono({double size = NexoText.md, FontWeight weight = FontWeight.w500, Color? color}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color, letterSpacing: 0);

  /// Helper de display (Plus Jakarta Sans) — pra hero/títulos especiais.
  static TextStyle display({double size = NexoText.xxl, FontWeight weight = FontWeight.w800, Color? color}) =>
      _display(size, weight: weight, color: color);
}
