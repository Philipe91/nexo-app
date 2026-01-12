import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores Clean & Modernas (Light)
  static const Color primary = Color(0xFF4D5BCE);    
  static const Color secondary = Color(0xFF6C63FF);  
  static const Color background = Color(0xFFF5F7FA); 
  static const Color surface = Colors.white;         
  static const Color textPrimary = Color(0xFF1E293B); 
  
  // Cores Dark Mode
  static const Color darkBackground = Color(0xFF121212); // Preto Suave
  static const Color darkSurface = Color(0xFF1E1E1E);    // Cinza Escuro
  static const Color darkText = Color(0xFFE0E0E0);       // Branco Gelo

  // --- TEMA CLARO ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
        surface: surface,
        onSurface: textPrimary,
        primary: primary,
        secondary: secondary,
        brightness: Brightness.light,
      ),

      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
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
        primary: const Color(0xFF7986CB), // Azul mais claro para contraste
        secondary: const Color(0xFF9FA8DA),
        brightness: Brightness.dark,
      ),

      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),

      // Cards e Dialogs Escuros
      // CORREÇÃO: Usar CardThemeData em vez de CardTheme
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // CORREÇÃO: Usar DialogThemeData em vez de DialogTheme
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        titleTextStyle: GoogleFonts.inter(color: darkText, fontWeight: FontWeight.bold, fontSize: 20),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.bold),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary, // Mantém a identidade
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Input cinza escuro
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}