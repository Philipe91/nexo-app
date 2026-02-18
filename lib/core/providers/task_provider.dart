import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  StreamSubscription<QuerySnapshot>? _tasksSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // TODO: Em um app real, usar ID da família do usuário logado
  String get _familyId => 'default_family'; 

  List<Task> get tasks => _tasks;

  int get totalMentalLoad {
    if (_tasks.isEmpty) return 0;
    return _tasks.fold(0, (sum, item) => sum + item.effort);
  }

  TaskProvider() {
    subscribeToTasks();
  }

  // --- ESCUTAR DO FIREBASE (REAL-TIME) ---
  void subscribeToTasks() {
    _tasksSubscription = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      
      _tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Garante que o ID do modelo é o mesmo do Doc
        return Task.fromMap(data);
      }).toList();

      notifyListeners();

      // Sincronizar Notificações (Smart Sync)
      // Sempre que chegarem dados novos, atualiza os agendamentos
      NotificationService().syncNotifications(_tasks);
      
    }, onError: (e) {
      print("❌ Erro no Stream de Tarefas: $e");
    });
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
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

  // Estatísticas Semanais (Últimos 7 dias)
  Map<String, int> calculateWeeklyStats() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    Map<String, int> stats = {};

    for (var task in _tasks) {
      if (task.lastCompletedDate != null && task.lastCompletedDate!.isAfter(sevenDaysAgo)) {
        // Atribui pontos para quem executou
        final executor = task.whoExecutes;
        stats[executor] = (stats[executor] ?? 0) + 1; // 1 ponto por tarefa (pode ser + task.effort)
      }
    }
    return stats;
  }

  // --- AÇÕES ---

  Future<void> addTask({
    required String title,
    required String whoRemembers,
    required String whoDecides,
    required String whoExecutes,
    required int effort,
    required String frequency,
    required List<String> days,
    DateTime? scheduledTime,
    bool notifyAtTime = false,
    String? audioPath,
  }) async {
    final newTask = Task(
      id: '', // Firestore vai gerar
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
      audioPath: audioPath,
    );

    try {
      await _firestore
          .collection('families')
          .doc(_familyId)
          .collection('tasks')
          .add(newTask.toMap());
      // O listener vai atualizar a UI e Notificações automaticamente
    } catch (e) {
      print("❌ Erro ao adicionar tarefa: $e");
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    try {
      await _firestore
          .collection('families')
          .doc(_familyId)
          .collection('tasks')
          .doc(updatedTask.id)
          .update(updatedTask.toMap());
    } catch (e) {
      print("❌ Erro ao atualizar tarefa: $e");
    }
  }

  // --- COMPLETAR/DESCOMPLETAR TAREFA (CHECK) ---
  Future<bool> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      final now = DateTime.now();

      bool isDoneToday = false;
      if (task.lastCompletedDate != null) {
        final last = task.lastCompletedDate!;
        isDoneToday = last.year == now.year &&
            last.month == now.month &&
            last.day == now.day;
      }

      final bool isCompleting = !isDoneToday; 

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

      await updateTask(updatedTask);
      return isCompleting;
    }
    return false;
  }

  Future<void> reassignTask(String taskId, String newMemberId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        whoRemembers: newMemberId,
        whoDecides: newMemberId,  
        whoExecutes: newMemberId, 
        effort: task.effort,
        frequency: task.frequency,
        days: task.days,
        createdAt: task.createdAt,
        lastCompletedDate: task.lastCompletedDate,
        scheduledTime: task.scheduledTime,
        notifyAtTime: task.notifyAtTime,
      );
      await updateTask(updatedTask);
    }
  }

  // Helper para o Check-in
  int getMemberMentalLoad(String memberId) {
    final memberTasks = _tasks.where((t) => t.whoExecutes == memberId || t.whoRemembers == memberId || t.whoDecides == memberId);
    if (memberTasks.isEmpty) return 0;
    return memberTasks.fold(0, (sum, t) => sum + t.effort);
  }

  Future<void> removeTask(String id) async {
    try {
      await _firestore
          .collection('families')
          .doc(_familyId)
          .collection('tasks')
          .doc(id)
          .delete();
       // Cancelamento de notificação é handled pelo syncNotifications no listener, 
       // pois a task sumirá da lista e o sync reagendará (ou limpará) tudo.
    } catch (e) {
      print("❌ Erro ao remover task: $e");
    }
  }
}
