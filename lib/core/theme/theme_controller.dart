import 'package:flutter/material.dart';

// Esta classe gerencia o estado do tema (Claro ou Escuro) para todo o app
class ThemeController extends ChangeNotifier {
  // Singleton para acesso global simples (opcional, mas facilita sem Provider)
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Avisa o app para redesenhar as cores
  }
}