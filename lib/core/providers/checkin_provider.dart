import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/checkin_model.dart';

class CheckInProvider extends ChangeNotifier {
  List<CheckIn> _history = [];

  List<CheckIn> get history => _history;

  CheckInProvider() {
    loadHistory();
  }

  // Salvar um novo Check-in
  void addCheckIn(Map<String, int> memberFeelings, int currentTotalLoad) {
    final newCheckIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      feelings: memberFeelings,
      totalLoadSnapshot: currentTotalLoad,
    );

    // Adiciona no topo da lista (mais recente primeiro)
    _history.insert(0, newCheckIn);
    saveHistory();
    notifyListeners();
  }

  // Limpar histórico (útil para testes)
  void clearHistory() {
    _history.clear();
    saveHistory();
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_history.map((c) => c.toMap()).toList());
    await prefs.setString('checkin_history', data);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('checkin_history')) {
      final String data = prefs.getString('checkin_history')!;
      final List<dynamic> decodedList = jsonDecode(data);
      _history = decodedList.map((item) => CheckIn.fromMap(item)).toList();
      notifyListeners();
    }
  }
}