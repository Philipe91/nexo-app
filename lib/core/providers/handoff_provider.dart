import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/handoff_session_model.dart';
import '../services/notification_service.dart';

/// Gerencia "passagens de bastão" — transferências temporárias de
/// responsabilidade de uma tarefa entre membros da família.
class HandoffProvider extends ChangeNotifier {
  HandoffProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot>? _sub;
  String? _familyId;

  List<HandoffSession> _sessions = [];
  List<HandoffSession> get sessions => _sessions;

  /// Sessão ativa pra uma tarefa (se houver).
  HandoffSession? activeFor(String taskId) {
    for (final s in _sessions) {
      if (s.taskId == taskId && s.isActive) return s;
    }
    return null;
  }

  /// Sessões pendentes (começam no futuro) pra uma tarefa.
  HandoffSession? pendingFor(String taskId) {
    for (final s in _sessions) {
      if (s.taskId == taskId && s.isPending) return s;
    }
    return null;
  }

  void init(String familyId, String _userId) {
    if (_familyId == familyId) return;
    _familyId = familyId;
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    if (_familyId == null) return;

    _sub = _firestore
        .collection('families')
        .doc(_familyId)
        .collection('handoffs')
        .snapshots()
        .listen((snap) {
      _sessions = snap.docs
          .map((d) => HandoffSession.fromMap({...d.data(), 'id': d.id}))
          .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ HandoffProvider stream: $e');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Cria uma nova sessão. `days` precisa ser entre 1 e 14.
  Future<HandoffSession?> start({
    required String taskId,
    required String taskTitle,
    required String fromMemberName,
    required String toMemberName,
    required int days,
  }) async {
    if (_familyId == null) return null;
    final clamped = days.clamp(1, 14);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: clamped - 1, hours: 23, minutes: 59));

    final id = const Uuid().v4();
    final session = HandoffSession(
      id: id,
      taskId: taskId,
      taskTitle: taskTitle,
      fromMemberName: fromMemberName,
      toMemberName: toMemberName,
      startDate: start,
      endDate: end,
      createdAt: now,
    );

    try {
      await _firestore
          .collection('families')
          .doc(_familyId)
          .collection('handoffs')
          .doc(id)
          .set(session.toMap());

      // Notificações: avisa o destinatário no início e o original no fim.
      await NotificationService().scheduleNotification(
        id: 'handoff-start-$id'.hashCode,
        title: 'Bastão recebido',
        body: '$toMemberName, você cuida de "$taskTitle" pelos próximos $clamped ${clamped == 1 ? "dia" : "dias"}.',
        scheduledDate: start,
      );
      await NotificationService().scheduleNotification(
        id: 'handoff-end-$id'.hashCode,
        title: 'Turno encerrado',
        body: 'O bastão de "$taskTitle" volta pra $fromMemberName.',
        scheduledDate: end,
      );
    } catch (e) {
      debugPrint('❌ HandoffProvider.start: $e');
      return null;
    }
    return session;
  }

  /// Cancela uma sessão (marca como cancelled).
  Future<void> cancel(String id) async {
    if (_familyId == null) return;
    try {
      await _firestore
          .collection('families')
          .doc(_familyId)
          .collection('handoffs')
          .doc(id)
          .update({'cancelled': true});
      await NotificationService().cancelNotification('handoff-start-$id'.hashCode);
      await NotificationService().cancelNotification('handoff-end-$id'.hashCode);
    } catch (e) {
      debugPrint('❌ HandoffProvider.cancel: $e');
    }
  }
}
