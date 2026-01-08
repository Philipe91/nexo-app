import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores Clean & Modernas
  static const Color primary = Color(0xFF4D5BCE);    // Azul NEXO
  static const Color secondary = Color(0xFF6C63FF);  // Roxo Suave
  static const Color background = Color(0xFFF5F7FA); // Cinza super claro (Gelo)
  static const Color surface = Colors.white;         // Branco puro para cards
  static const Color textPrimary = Color(0xFF1E293B); // Cinza escuro (quase preto)
  static const Color textSecondary = Color(0xFF64748B); // Cinza médio

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
        surface: surface,
        primary: primary,
        secondary: secondary,
      ),

      // Tipografia Limpa (Google Fonts)
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      // Botões Arredondados
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Inputs brancos e limpos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}