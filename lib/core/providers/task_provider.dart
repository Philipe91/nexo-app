import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';
import '../models/member_model.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  StreamSubscription<QuerySnapshot>? _tasksSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _familyId;
  String? _currentUserId;

  List<Task> get tasks => _tasks;

  int get totalMentalLoad {
    if (_tasks.isEmpty) return 0;
    return _tasks.fold(0, (sum, item) => sum + item.effort);
  }

  // ------------------------------------------------------------------ //
  // INICIALIZAÇÃO — Chamado após o login, com o familyId real
  // ------------------------------------------------------------------ //
  void init(String familyId, String userId) {
    if (_familyId == familyId) return; // já está escutando essa família
    _familyId = familyId;
    _currentUserId = userId;
    _subscribeToTasks();
  }

  void _subscribeToTasks() {
    _tasksSubscription?.cancel();
    if (_familyId == null) return;

    _tasksSubscription = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      _tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();

      notifyListeners();
      NotificationService().syncNotifications(_tasks);
    }, onError: (e) {
      debugPrint('❌ Erro no Stream de Tarefas: $e');
    });
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------------ //
  // GUARDS DE PERMISSÃO
  // ------------------------------------------------------------------ //

  /// Admin pode tudo. Adult só altera as próprias. Child nunca.
  bool canEditTask(Task task, Member currentMember) {
    if (currentMember.role == 'admin') return true;
    if (currentMember.role == 'adult') {
      return task.createdBy == currentMember.userId;
    }
    return false;
  }

  bool canDeleteTask(Task task, Member currentMember) =>
      canEditTask(task, currentMember);

  // ------------------------------------------------------------------ //
  // QUERIES
  // ------------------------------------------------------------------ //

  List<Task> getTasksForDay(String dayCode) =>
      _tasks.where((t) => t.days.contains(dayCode)).toList();

  Map<String, int> calculateMentalLoad(String memberName) {
    int remember = 0, decide = 0, execute = 0;
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

  Map<String, int> calculateWeeklyStats() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    Map<String, int> stats = {};
    for (var task in _tasks) {
      if (task.lastCompletedDate != null &&
          task.lastCompletedDate!.isAfter(sevenDaysAgo)) {
        final executor = task.whoExecutes;
        stats[executor] = (stats[executor] ?? 0) + 1;
      }
    }
    return stats;
  }

  int getMemberMentalLoad(String memberId) {
    final memberTasks = _tasks.where((t) =>
        t.whoExecutes == memberId ||
        t.whoRemembers == memberId ||
        t.whoDecides == memberId);
    if (memberTasks.isEmpty) return 0;
    return memberTasks.fold(0, (sum, t) => sum + t.effort);
  }

  // ------------------------------------------------------------------ //
  // AÇÕES
  // ------------------------------------------------------------------ //

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
    if (_familyId == null) return;

    final newTask = Task(
      id: '',
      title: title,
      whoRemembers: whoRemembers,
      whoDecides: whoDecides,
      whoExecutes: whoExecutes,
      effort: effort,
      frequency: frequency,
      days: days,
      createdAt: DateTime.now(),
      createdBy: _currentUserId ?? '',
      familyId: _familyId!,
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
    } catch (e) {
      debugPrint('❌ Erro ao adicionar tarefa: $e');
    }
  }

  Future<void> updateTask(Task updatedTask, {Member? currentMember}) async {
    // Guard: verifica permissão se um membro foi fornecido
    if (currentMember != null && !canEditTask(updatedTask, currentMember)) {
      debugPrint('🚫 Sem permissão para editar essa tarefa.');
      return;
    }
    if (_familyId == null) return;

    try {
      await _firestore
          .collection('families')
          .doc(_familyId)
          .collection('tasks')
          .doc(updatedTask.id)
          .update(updatedTask.toMap());
    } catch (e) {
      debugPrint('❌ Erro ao atualizar tarefa: $e');
    }
  }

  Future<bool> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) return false;

    final task = _tasks[index];
    final now = DateTime.now();
    final isDoneToday = task.lastCompletedDate != null &&
        task.lastCompletedDate!.year == now.year &&
        task.lastCompletedDate!.month == now.month &&
        task.lastCompletedDate!.day == now.day;

    final isCompleting = !isDoneToday;

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
      createdBy: task.createdBy,
      familyId: task.familyId,
      lastCompletedDate: isCompleting ? now : null,
      scheduledTime: task.scheduledTime,
      notifyAtTime: task.notifyAtTime,
    );

    await updateTask(updatedTask); // sem guard: qualquer um pode completar
    return isCompleting;
  }

  Future<void> reassignTask(String taskId, String newMemberId,
      {Member? currentMember}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) return;

    final task = _tasks[index];
    if (currentMember != null && !canEditTask(task, currentMember)) {
      debugPrint('🚫 Sem permissão para reatribuir essa tarefa.');
      return;
    }

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
      createdBy: task.createdBy,
      familyId: task.familyId,
      lastCompletedDate: task.lastCompletedDate,
      scheduledTime: task.scheduledTime,
      notifyAtTime: task.notifyAtTime,
    );
    await updateTask(updatedTask);
  }

  Future<void> removeTask(String id, {Member? currentMember}) async {
    if (_familyId == null) return;

    // Guard de permissão
    if (currentMember != null) {
      final task = _tasks.firstWhere((t) => t.id == id,
          orElse: () => Task(
              id: id,
              title: '',
              effort: 1,
              frequency: '',
              whoRemembers: '',
              whoDecides: '',
              whoExecutes: '',
              createdAt: DateTime.now()));
      if (!canDeleteTask(task, currentMember)) {
        debugPrint('🚫 Sem permissão para excluir essa tarefa.');
        return;
      }
    }

    try {
      await _firestore
          .collection('families')
          .doc(_familyId)
          .collection('tasks')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('❌ Erro ao remover task: $e');
    }
  }
}
