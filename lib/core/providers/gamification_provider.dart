import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationProvider with ChangeNotifier {
  int _currentXp = 0;
  int _currentLevel = 1;
  
  int get currentXp => _currentXp;
  int get currentLevel => _currentLevel;

  // Quanto de XP precisa para o próximo nível?
  // Ex: Nível 1 precisa de 100, Nível 2 precisa de 200...
  int get xpToNextLevel => _currentLevel * 100;

  // Porcentagem para a barra de progresso (0.0 a 1.0)
  double get progress => _currentXp / xpToNextLevel;

  GamificationProvider() {
    _loadProgress();
  }

  // Função principal: Ganhar XP
  void addXp(int amount) {
    _currentXp += amount;
    checkLevelUp();
    _saveProgress();
    notifyListeners();
  }

  // Função para remover XP (se desmarcar a tarefa)
  void removeXp(int amount) {
    _currentXp -= amount;
    if (_currentXp < 0) _currentXp = 0;
    // Lógica simples: não rebaixamos nível por enquanto para não frustrar
    _saveProgress();
    notifyListeners();
  }

  void checkLevelUp() {
    // Enquanto o XP atual for maior que o necessário para subir...
    while (_currentXp >= xpToNextLevel) {
      _currentXp -= xpToNextLevel; // Subtrai o custo do nível
      _currentLevel++; // Sobe de nível
      // Aqui poderíamos disparar um som ou alerta de "LEVEL UP!"
    }
  }

  // --- Persistência (Salvar no celular) ---
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('user_xp', _currentXp);
    prefs.setInt('user_level', _currentLevel);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _currentXp = prefs.getInt('user_xp') ?? 0;
    _currentLevel = prefs.getInt('user_level') ?? 1;
    notifyListeners();
  }
}