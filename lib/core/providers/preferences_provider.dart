import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider with ChangeNotifier {
  // --- Variáveis de Estado ---
  bool _isDarkMode = false;
  String _familyName = "Minha Família"; // Valor padrão para não dar erro

  // --- Getters (O que as telas leem) ---
  bool get isDarkMode => _isDarkMode;
  String get familyName => _familyName; // <--- O getter que o erro pediu

  PreferencesProvider() {
    _loadPreferences();
  }

  // --- Funções de Ação ---

  // Agora aceita um valor bool (isOn) para funcionar com o Switch do menu
  void toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Função para mudar o nome da família (útil para as configurações)
  void updateFamilyName(String newName) async {
    _familyName = newName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('familyName', _familyName);
  }

  // --- Carregamento Inicial ---
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carrega Tema
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    // Carrega Nome da Família
    _familyName = prefs.getString('familyName') ?? "Minha Família";
    
    notifyListeners();
  }
}