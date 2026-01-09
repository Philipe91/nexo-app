import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  // Lista privada de tarefas
  final List<Task> _tasks = [];

  // Getter para quem quiser ler a lista (protege a lista original)
  List<Task> get tasks => _tasks;

  // Getter para calcular a Carga Mental Total (soma dos esforços)
  int get totalMentalLoad {
    if (_tasks.isEmpty) return 0;
    return _tasks.fold(0, (sum, item) => sum + item.effort);
  }

  // Adicionar nova tarefa
  void addTask({
    required String title,
    required String whoRemembers,
    required String whoDecides,
    required String whoExecutes,
    required int effort,
    required String frequency,
  }) {
    final newTask = Task(
      id: DateTime.now().toString(), // ID único baseado na hora
      title: title,
      whoRemembers: whoRemembers,
      whoDecides: whoDecides,
      whoExecutes: whoExecutes,
      effort: effort,
      frequency: frequency,
      createdAt: DateTime.now(),
    );

    _tasks.add(newTask);
    
    // O Mágico: Avisa todas as telas que a lista mudou!
    notifyListeners(); 
  }

  // Remover tarefa
  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}