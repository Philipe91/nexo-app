import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_provider.dart';

class DailyLoad {
  final DateTime date;
  final int load;

  DailyLoad({required this.date, required this.load});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'load': load,
    };
  }

  factory DailyLoad.fromMap(Map<String, dynamic> map) {
    return DailyLoad(
      date: DateTime.parse(map['date']),
      load: map['load'],
    );
  }
}

class MentalLoadProvider extends ChangeNotifier {
  List<DailyLoad> _history = [];
  List<DailyLoad> get history => _history;

  MentalLoadProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('mental_load_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _history = decoded.map((e) => DailyLoad.fromMap(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveDailySnapshot(TaskProvider taskProvider) async {
    final now = DateTime.now();
    final todayLoad = taskProvider.totalMentalLoad.toInt();

    // Check if we already have an entry for today
    final index = _history.indexWhere((item) => 
      item.date.year == now.year && 
      item.date.month == now.month && 
      item.date.day == now.day
    );

    if (index != -1) {
      // Update today's entry
      _history[index] = DailyLoad(date: now, load: todayLoad);
    } else {
      // Add new entry
      _history.add(DailyLoad(date: now, load: todayLoad));
      
      // Keep only last 90 days to save space
      if (_history.length > 90) {
        _history.removeAt(0);
      }
    }
    
    // Sort by date just in case
    _history.sort((a, b) => a.date.compareTo(b.date));

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_history.map((e) => e.toMap()).toList());
    await prefs.setString('mental_load_history', encoded);
  }

  // --- MOCK DATA GENERATOR (For testing/filling gaps) ---
  void generateMockHistory() {
     if (_history.isNotEmpty) return; // Don't overwrite real data

     final now = DateTime.now();
     for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        // Random load between 30 and 80, but consistent for the seed
        final load = (date.day * 7) % 50 + 30; 
        _history.add(DailyLoad(date: date, load: load));
     }
     notifyListeners();
  }
}
