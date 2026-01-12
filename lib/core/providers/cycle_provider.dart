import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cycle_model.dart';

class CycleProvider extends ChangeNotifier {
  List<Cycle> _cycles = [];

  CycleProvider() {
    loadCycles();
  }

  // --- LÓGICA DE NEGÓCIO ---

  // Retorna o ciclo de um membro específico
  Cycle? getCycleByMember(String memberId) {
    try {
      return _cycles.firstWhere((c) => c.memberId == memberId);
    } catch (e) {
      return null;
    }
  }

  // Calcula a fase atual e retorna um Objeto com infos úteis
  Map<String, dynamic> getCurrentPhaseInfo(String memberId) {
    final cycle = getCycleByMember(memberId);
    if (cycle == null) return {};

    final now = DateTime.now();
    // Dias passados desde o último início
    final difference = now.difference(cycle.lastPeriodDate).inDays;
    
    // Dia atual do ciclo (1 a 28...)
    final currentDay = (difference % cycle.cycleLength) + 1;

    String phaseName = "";
    String empathyTip = "";
    Color phaseColor = Colors.grey;
    IconData icon = Icons.help_outline;

    if (currentDay <= cycle.periodLength) {
      // MENSTRUAÇÃO
      phaseName = "Fase Menstrual (Dia $currentDay)";
      empathyTip = "Energia baixa. Priorize descanso e evite sobrecarga.";
      phaseColor = const Color(0xFFEF5350); // Vermelho Suave
      icon = Icons.water_drop;
    } else if (currentDay <= 11) {
      // FOLICULAR
      phaseName = "Fase Folicular (Dia $currentDay)";
      empathyTip = "Energia subindo! Ótimo momento para planejar e resolver pendências.";
      phaseColor = const Color(0xFF66BB6A); // Verde
      icon = Icons.grass;
    } else if (currentDay <= 16) {
      // OVULATÓRIA
      phaseName = "Ovulação (Dia $currentDay)";
      empathyTip = "Pico de energia e comunicação. Bom para conversas importantes.";
      phaseColor = const Color(0xFFFFA726); // Laranja
      icon = Icons.wb_sunny;
    } else {
      // LÚTEA (TPM)
      phaseName = "Fase Lútea (Dia $currentDay)";
      empathyTip = "Energia diminuindo. Tenha paciência e ofereça acolhimento.";
      phaseColor = const Color(0xFFAB47BC); // Roxo
      icon = Icons.nights_stay;
    }

    return {
      'hasData': true,
      'day': currentDay,
      'phase': phaseName,
      'tip': empathyTip,
      'color': phaseColor,
      'icon': icon,
    };
  }

  // --- CRUD ---

  void setCycle({required String memberId, required DateTime lastPeriod, int cycleLen = 28, int periodLen = 5}) {
    // Remove anterior se existir
    _cycles.removeWhere((c) => c.memberId == memberId);

    final newCycle = Cycle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: memberId,
      lastPeriodDate: lastPeriod,
      cycleLength: cycleLen,
      periodLength: periodLen,
    );

    _cycles.add(newCycle);
    saveCycles();
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---

  Future<void> saveCycles() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_cycles.map((c) => c.toMap()).toList());
    await prefs.setString('cycles_data', data);
  }

  Future<void> loadCycles() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('cycles_data')) {
      final String data = prefs.getString('cycles_data')!;
      final List<dynamic> decodedList = jsonDecode(data);
      _cycles = decodedList.map((item) => Cycle.fromMap(item)).toList();
      notifyListeners();
    }
  }
}