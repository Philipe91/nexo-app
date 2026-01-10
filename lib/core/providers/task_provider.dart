import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  int get totalMentalLoad {
    if (_tasks.isEmpty) return 0;
    return _tasks.fold(0, (sum, item) => sum + item.effort);
  }

  TaskProvider() {
    loadTasks();
  }

  // Filtrar tarefas por dia (ex: "Seg")
  List<Task> getTasksForDay(String dayCode) {
    return _tasks.where((t) => t.days.contains(dayCode)).toList();
  }

  // Calculadora de Carga Mental
  Map<String, int> calculateMentalLoad(String memberName) {
    int remember = 0;
    int decide = 0;
    int execute = 0;

    for (var task in _tasks) {
      if (task.whoRemembers == memberName) remember += task.effort;
      if (task.whoDecides == memberName) decide += task.effort;
      if (task.whoExecutes == memberName) execute += task.effort;
    }

    return {
      'remember': remember,
      'decide': decide,
      'execute': execute,
      'total': remember + decide + execute,
    };
  }

  // --- AÇÕES ---

  void addTask({
    required String title,
    required String whoRemembers,
    required String whoDecides,
    required String whoExecutes,
    required int effort,
    required String frequency,
    required List<String> days,
  }) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      whoRemembers: whoRemembers,
      whoDecides: whoDecides,
      whoExecutes: whoExecutes,
      effort: effort,
      frequency: frequency,
      days: days,
      createdAt: DateTime.now(),
    );

    _tasks.add(newTask);
    saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index >= 0) {
      _tasks[index] = updatedTask;
      saveTasks();
      notifyListeners();
    }
  }

  // --- NOVO: COMPLETAR/DESCOMPLETAR TAREFA (CHECK) ---
  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      final now = DateTime.now();

      // Verifica se já foi feita hoje (compara Dia, Mês e Ano)
      bool isDoneToday = false;
      if (task.lastCompletedDate != null) {
        final last = task.lastCompletedDate!;
        isDoneToday = last.year == now.year &&
            last.month == now.month &&
            last.day == now.day;
      }

      // Se já fez hoje, "desfaz" (null). Se não fez, marca hoje.
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        whoRemembers: task.whoRemembers,
        whoDecides: task.whoDecides,
        whoExecutes: task.whoExecutes,
        effort: task.effort,
        frequency: task.frequency,
        days: task.days,
        createdAt: task.createdAt,
        lastCompletedDate: isDoneToday ? null : now, // Toggle data
      );

      _tasks[index] = updatedTask;
      saveTasks();
      notifyListeners();
    }
  }

  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    saveTasks();
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks_data', data);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('tasks_data')) {
      final String data = prefs.getString('tasks_data')!;
      final List<dynamic> decodedList = jsonDecode(data);
      _tasks = decodedList.map((item) => Task.fromMap(item)).toList();
      notifyListeners();
    }
  }
}
