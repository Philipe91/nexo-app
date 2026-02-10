import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalmTheme {
  // --- PALETA DE CORES "SERENITY" ---
  static const Color backgroundDates = Color(0xFF0D1B2A); // Azul Noite Profunda
  static const Color backgroundLight = Color(0xFF1B263B); // Azul Crepúsculo
  static const Color primaryBlue = Color(0xFF415A77);     // Azul Aço
  static const Color accentGold = Color(0xFFF4A261);      // Dourado Pôr do Sol
  static const Color accentCoral = Color(0xFFE76F51);     // Coral Suave
  static const Color accentSage = Color(0xFF2A9D8F);      // Verde Sálvia
  static const Color textWhite = Color(0xFFE0E1DD);       // Branco Opaco
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDates,
      primaryColor: primaryBlue,
      
      // Esquema de Cores Material 3
      colorScheme: const ColorScheme.dark(
        primary: accentGold,      // Ações principais (Botões, FABs)
        secondary: accentSage,    // Sucesso, Checkboxes
        surface: backgroundLight, // Cards, Dialogs
        error: accentCoral,       // Erros, Deletar
        onPrimary: Colors.black,
        onSurface: textWhite,
      ),

      // Tipografia (Lato + Fredoka)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.bold, color: textWhite),
        displayMedium: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600, color: textWhite),
        bodyLarge: GoogleFonts.lato(fontSize: 16, color: textWhite),
        bodyMedium: GoogleFonts.lato(fontSize: 14, color: textWhite.withOpacity(0.8)),
        labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
      ),

      // Estilo de Cards (Glassmorphism Base)
      cardTheme: CardThemeData(
        color: backgroundLight.withOpacity(0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: textWhite.withOpacity(0.1), width: 1),
        ),
      ),

      // Estilo de Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.lato(color: textWhite.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      
      // Estilo de Ícones
      iconTheme: IconThemeData(
        color: textWhite.withOpacity(0.8),
        size: 24,
      ),
    );
  }
}
