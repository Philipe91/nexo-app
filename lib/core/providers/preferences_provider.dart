import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  // Estado Inicial
  ThemeMode _themeMode = ThemeMode.system;
  String _familyName = "Nossa Família";

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get familyName => _familyName;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  PreferencesProvider() {
    _loadPreferences();
  }

  // --- AÇÕES ---

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  void updateFamilyName(String newName) {
    _familyName = newName;
    _saveFamilyName();
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Salva 0 para Light, 1 para Dark, 2 para System
    int themeIndex = 0;
    if (_themeMode == ThemeMode.dark) themeIndex = 1;
    if (_themeMode == ThemeMode.system) themeIndex = 2;
    
    await prefs.setInt('theme_mode', themeIndex);
  }

  Future<void> _saveFamilyName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('family_name', _familyName);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carregar Tema
    if (prefs.containsKey('theme_mode')) {
      final index = prefs.getInt('theme_mode') ?? 0;
      if (index == 1) _themeMode = ThemeMode.dark;
      else if (index == 2) _themeMode = ThemeMode.system;
      else _themeMode = ThemeMode.light;
    }

    // Carregar Nome da Família
    if (prefs.containsKey('family_name')) {
      _familyName = prefs.getString('family_name')!;
    }
    
    notifyListeners();
  }
}