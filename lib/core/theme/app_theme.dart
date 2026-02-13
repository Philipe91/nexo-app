import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores Moon Heart
  static const Color primary = Color(0xFF4E5AE8);    // Azul Índigo Vibrante
  static const Color secondary = Color(0xFF8E9EFE);  // Azul Percal / Light
  static const Color accent = Color(0xFFFFD740);     // Amarelo para destaques (estrelas, etc)
  
  static const Color background = Color(0xFFF8F9FE); // Branco com leve tint azul
  static const Color surface = Colors.white;         
  static const Color textPrimary = Color(0xFF2D3142); // Cinza Escuro Azulado
  static const Color textSecondary = Color(0xFF9C9DB9); // Cinza Claro

  // Cores Dark Mode (Adaptadas)
  static const Color darkBackground = Color(0xFF2D3142); 
  static const Color darkSurface = Color(0xFF393D5E);    
  static const Color darkText = Color(0xFFE0E0E0);       

  // Gradient Principal (Para uso nos widgets)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4E5AE8), Color(0xFF8E9EFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- TEMA CLARO ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      
      // Definição de Cores
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
        surface: surface,
        onSurface: textPrimary,
        primary: primary,
        secondary: secondary,
        tertiary: accent, 
        brightness: Brightness.light,
      ),

      // Tipografia Nunito (Estilo Avenir)
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: textPrimary),
        displayMedium: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: textPrimary),
        bodyLarge: GoogleFonts.nunito(color: textPrimary),
        bodyMedium: GoogleFonts.nunito(color: textPrimary),
      ),

      // Botões Arredondados
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Bem redondo
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Inputs Modernos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        hintStyle: GoogleFonts.nunito(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), 
          borderSide: BorderSide.none, // Sem borda visível por padrão (estilo clean)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.transparent), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Color(0x264E5AE8), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
        margin: EdgeInsets.all(8),
      ),
    );
  }

  // --- TEMA ESCURO ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: darkBackground,
        surface: darkSurface,
        onSurface: darkText,
        primary: const Color(0xFF8E9EFE), // Usamos o tom mais claro no dark
        secondary: const Color(0xFF4E5AE8),
        brightness: Brightness.dark,
      ),

      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF4E5AE8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: GoogleFonts.nunito(color: Colors.white38),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
      
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
    );
  }
}