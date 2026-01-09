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

  // --- AÇÕES ---

  void addTask({
    required String title,
    required String whoRemembers,
    required String whoDecides,
    required String whoExecutes,
    required int effort,
    required String frequency,
  }) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      whoRemembers: whoRemembers,
      whoDecides: whoDecides,
      whoExecutes: whoExecutes,
      effort: effort,
      frequency: frequency,
      createdAt: DateTime.now(),
    );

    _tasks.add(newTask);
    saveTasks();
    notifyListeners();
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