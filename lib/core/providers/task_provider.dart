import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';
import '../services/notification_service.dart'; // <--- Import Novo

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
    DateTime? scheduledTime,
    bool notifyAtTime = false,
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
      scheduledTime: scheduledTime,
      notifyAtTime: notifyAtTime,
    );

    _tasks.add(newTask);
    saveTasks();
    notifyListeners();

    // Agendar Notificação
    if (notifyAtTime && scheduledTime != null) {
      // Usamos o hashCode do ID como ID da notificação (convertendo string para int seguro)
      int notificationId = int.parse(newTask.id.substring(newTask.id.length - 8)); 
      
      NotificationService().scheduleNotification(
        id: notificationId,
        title: "Hora de: ${newTask.title}",
        body: "Ei $whoExecutes, sua tarefa te espera!",
        scheduledDate: scheduledTime,
      );
    }
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index >= 0) {
      _tasks[index] = updatedTask;
      saveTasks();
      notifyListeners();

      // Cancelar e/ou Reagendar
      // Usa os últimos 8 dígitos do ID como ID da notificação
      int notificationId = int.parse(updatedTask.id.substring(updatedTask.id.length - 8));
      
      NotificationService().cancelNotification(notificationId);

      if (updatedTask.notifyAtTime && updatedTask.scheduledTime != null) {
         NotificationService().scheduleNotification(
          id: notificationId,
          title: "Hora de: ${updatedTask.title}",
          body: "Ei ${updatedTask.whoExecutes}, sua tarefa te espera!",
          scheduledDate: updatedTask.scheduledTime!,
        );
      }
    }
  }

  // --- NOVO: COMPLETAR/DESCOMPLETAR TAREFA (CHECK) ---
  bool toggleTaskCompletion(String taskId) {
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

      final bool isCompleting = !isDoneToday; // Se não fez, está completando agora

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
        lastCompletedDate: isCompleting ? now : null,
        scheduledTime: task.scheduledTime,
        notifyAtTime: task.notifyAtTime, 
      );

      _tasks[index] = updatedTask;
      saveTasks();
      notifyListeners();
      
      return isCompleting;
    }
    return false;
  }

  void reassignTask(String taskId, String newMemberId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      // Atualiza quem executa. O Model espera String, não List<String>.
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        whoRemembers: newMemberId, // Corrigido: String
        whoDecides: newMemberId,   // Corrigido: String
        whoExecutes: newMemberId,  // Corrigido: String
        effort: task.effort,
        frequency: task.frequency,
        days: task.days,
        createdAt: task.createdAt,
        lastCompletedDate: task.lastCompletedDate,
        scheduledTime: task.scheduledTime,
        notifyAtTime: task.notifyAtTime,
      );
      _tasks[index] = updatedTask;
      saveTasks();
      notifyListeners();
    }
  }

  // Helper para o Check-in
  int getMemberMentalLoad(String memberId) {
    final memberTasks = _tasks.where((t) => t.whoExecutes == memberId || t.whoRemembers == memberId || t.whoDecides == memberId);
    if (memberTasks.isEmpty) return 0;
    return memberTasks.fold(0, (sum, t) => sum + t.effort);
  }

  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    saveTasks();
    notifyListeners();
    
    // Cancelar notificação associada
    if (id.length >= 8) {
       int notificationId = int.parse(id.substring(id.length - 8));
       NotificationService().cancelNotification(notificationId);
    }
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
