import 'package:cloud_firestore/cloud_firestore.dart';

/// Sessão de "passagem de bastão" — uma transferência temporária da
/// responsabilidade de uma tarefa pra outro membro, por N dias.
class HandoffSession {
  HandoffSession({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.fromMemberName,
    required this.toMemberName,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.cancelled = false,
  });

  final String id;
  final String taskId;
  final String taskTitle;
  final String fromMemberName;
  final String toMemberName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final bool cancelled;

  bool get isActive {
    if (cancelled) return false;
    final now = DateTime.now();
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  bool get isPending {
    if (cancelled) return false;
    return DateTime.now().isBefore(startDate);
  }

  bool get isFinished {
    if (cancelled) return true;
    return DateTime.now().isAfter(endDate);
  }

  int get totalDays => endDate.difference(startDate).inDays + 1;
  int get daysRemaining {
    if (!isActive) return 0;
    return endDate.difference(DateTime.now()).inDays + 1;
  }

  HandoffSession copyWith({bool? cancelled}) => HandoffSession(
        id: id,
        taskId: taskId,
        taskTitle: taskTitle,
        fromMemberName: fromMemberName,
        toMemberName: toMemberName,
        startDate: startDate,
        endDate: endDate,
        createdAt: createdAt,
        cancelled: cancelled ?? this.cancelled,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'fromMemberName': fromMemberName,
        'toMemberName': toMemberName,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'createdAt': Timestamp.fromDate(createdAt),
        'cancelled': cancelled,
      };

  factory HandoffSession.fromMap(Map<String, dynamic> map) {
    DateTime toDt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return HandoffSession(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      taskTitle: map['taskTitle'] ?? '',
      fromMemberName: map['fromMemberName'] ?? '',
      toMemberName: map['toMemberName'] ?? '',
      startDate: toDt(map['startDate']),
      endDate: toDt(map['endDate']),
      createdAt: toDt(map['createdAt']),
      cancelled: map['cancelled'] ?? false,
    );
  }
}
