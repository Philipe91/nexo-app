import 'package:flutter/material.dart';

/// Design tokens for NEXO. Single source of truth for the visual system.
///
/// Direção: SaaS Boutique (light) + Cinema Dark — premium, sofisticado,
/// motion fluida. Inspirações: Linear, Things 3, Arc.
///
/// Uso: `import 'core/theme/tokens.dart';` e acesse via `NexoColors.indigo`
/// ou `context.tokens.colors.surface` (extension abaixo).
class NexoColors {
  NexoColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color indigo = Color(0xFF5E6AD2);
  static const Color indigoStrong = Color(0xFF4955BA);
  static const Color indigoSoft = Color(0xFF7C86E8);
  static const Color indigoGlow = Color(0x265E6AD2); // 0.15

  // ── Semantic (3 tons cada) ────────────────────────────────────────────────
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color success = Color(0xFF16A34A);
  static const Color successStrong = Color(0xFF15803D);
  static const Color successDark = Color(0xFF22C55E);

  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningStrong = Color(0xFFB45309);
  static const Color warningDark = Color(0xFFF59E0B);

  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerStrong = Color(0xFFB91C1C);
  static const Color dangerDark = Color(0xFFEF4444);

  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color info = Color(0xFF2563EB);
  static const Color infoStrong = Color(0xFF1D4ED8);
  static const Color infoDark = Color(0xFF60A5FA);

  // ── Light surfaces (3 camadas) ────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF5F5F7);
  static const Color lightBorder = Color(0xFFE8E8ED);
  static const Color lightBorderStrong = Color(0xFFD1D1D6);
  static const Color lightFg = Color(0xFF0F0F12);
  static const Color lightFgMuted = Color(0xFF6B6B76);
  static const Color lightFgSubtle = Color(0xFF9CA0A8);

  // ── Dark surfaces (Cinema, 3 camadas) ─────────────────────────────────────
  static const Color darkBg = Color(0xFF0A0A0C);
  static const Color darkSurface = Color(0xFF141417);
  static const Color darkSurfaceElevated = Color(0xFF1C1C21);
  static const Color darkSurfaceMuted = Color(0xFF1C1C21);
  static const Color darkBorder = Color(0x14FFFFFF); // 0.08 white
  static const Color darkBorderStrong = Color(0x29FFFFFF);
  static const Color darkFg = Color(0xFFEDEDEF);
  static const Color darkFgMuted = Color(0xFF8A8F98);
  static const Color darkFgSubtle = Color(0xFF5C606A);

  // ── Curated member palette (8 tons) ───────────────────────────────────────
  static const List<Color> memberPalette = [
    Color(0xFF5E6AD2), // indigo
    Color(0xFFEC4899), // pink
    Color(0xFFF59E0B), // amber
    Color(0xFF10B981), // emerald
    Color(0xFF8B5CF6), // violet
    Color(0xFFEF4444), // red
    Color(0xFF06B6D4), // cyan
    Color(0xFFF97316), // orange
  ];
}

class NexoRadius {
  NexoRadius._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20; // padrão de cards
  static const double xl = 28; // hero/sheets
  static const double pill = 999;
}

/// Grid base 4px (8px-friendly).
class NexoSpace {
  NexoSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Type scale — escala par baseada em 14/16.
class NexoText {
  NexoText._();
  static const double xs = 12;
  static const double sm = 13;
  static const double md = 14;
  static const double base = 16;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 28;
  static const double xxxl = 36;
}

class NexoMotion {
  NexoMotion._();
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration ambient = Duration(seconds: 8);

  /// Curva premium — ease-out exponencial. Mesmo "feeling" do Linear app.
  static const Curve standard = Cubic(0.16, 1, 0.3, 1);
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve exit = Cubic(0.4, 0, 1, 1);
}

class NexoElevation {
  NexoElevation._();

  static List<BoxShadow> get card => const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Color(0x05000000),
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get raised => const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> glow(Color color, {double opacity = 0.18}) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ];
}
