import 'package:cloud_firestore/cloud_firestore.dart';

/// Subtarefa "iceberg" — trabalho invisível por trás da tarefa visível.
///
/// Ex: "Cozinhar o almoço" tem subtarefas como "decidir cardápio",
/// "checar geladeira", "fazer lista", "ir ao mercado". Essas peças contam
/// menos no esforço bruto (peso 0.5) mas aparecem na carga mental real.
class SubTask {
  SubTask({
    required this.id,
    required this.title,
    this.isInvisible = true,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final bool isInvisible;
  final DateTime? completedAt;
  final DateTime createdAt;

  bool get isDone => completedAt != null;

  SubTask copyWith({String? title, bool? isInvisible, DateTime? completedAt}) {
    return SubTask(
      id: id,
      title: title ?? this.title,
      isInvisible: isInvisible ?? this.isInvisible,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isInvisible': isInvisible,
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory SubTask.fromMap(Map<String, dynamic> map) {
    DateTime? toDateTime(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isInvisible: map['isInvisible'] ?? true,
      completedAt: toDateTime(map['completedAt']),
      createdAt: toDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }
}

/// Frequências aceitas. Mantemos String pra retrocompatibilidade.
class TaskFrequency {
  TaskFrequency._();
  static const String diaria = 'Diária';
  static const String semanal = 'Semanal';
  static const String quinzenal = 'Quinzenal';
  static const String mensal = 'Mensal';
  static const String trimestral = 'Trimestral';
  static const String semestral = 'Semestral';
  static const String anual = 'Anual';
  static const String pontual = 'Pontual';

  static const List<String> all = [
    diaria,
    semanal,
    quinzenal,
    mensal,
    trimestral,
    semestral,
    anual,
    pontual,
  ];

  /// Frequências consideradas sazonais (aparecem na aba "Sazonais").
  static const List<String> sazonais = [trimestral, semestral, anual, pontual];

  static bool isSazonal(String f) => sazonais.contains(f);
}

class Task {
  Task({
    required this.id,
    required this.title,
    required this.effort,
    required this.frequency,
    required this.whoRemembers,
    required this.whoDecides,
    required this.whoExecutes,
    required this.createdAt,
    this.createdBy = '',
    this.familyId = '',
    this.days = const [],
    this.lastCompletedDate,
    this.notifyAtTime = false,
    this.notify1hBefore = false,
    this.notify1dBefore = false,
    this.scheduledTime,
    this.photoBefore,
    this.photoAfter,
    this.audioPath,
    this.hiddenSubtasks = const [],
  });

  final String id;
  final String title;
  final int effort; // 1 a 3
  final String frequency;
  final String whoRemembers;
  final String whoDecides;
  final String whoExecutes;

  // Autoria/família
  final String createdBy;
  final String familyId;

  // Recorrência
  final List<String> days;
  final DateTime? lastCompletedDate;
  final DateTime createdAt;

  // Notificações
  final bool notifyAtTime;
  final bool notify1hBefore;
  final bool notify1dBefore;
  final DateTime? scheduledTime;

  // Provas
  final String? photoBefore;
  final String? photoAfter;

  // Áudio
  final String? audioPath;

  /// Subtarefas invisíveis (trabalho-iceberg).
  final List<SubTask> hiddenSubtasks;

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
        lastCompletedDate!.month == now.month &&
        lastCompletedDate!.day == now.day;
  }

  /// Esforço total = visible (effort 1-3) + soma das invisíveis × 0.5.
  /// Devolve double — converta com .round() onde precisar de int.
  double get totalEffort {
    final invisible = hiddenSubtasks.where((s) => s.isInvisible).length;
    return effort + invisible * 0.5;
  }

  int get invisibleCount => hiddenSubtasks.where((s) => s.isInvisible).length;
  int get invisibleDoneCount =>
      hiddenSubtasks.where((s) => s.isInvisible && s.isDone).length;

  bool get isSazonal => TaskFrequency.isSazonal(frequency);

  Task copyWith({
    String? title,
    int? effort,
    String? frequency,
    String? whoRemembers,
    String? whoDecides,
    String? whoExecutes,
    List<String>? days,
    DateTime? lastCompletedDate,
    bool? notifyAtTime,
    bool? notify1hBefore,
    bool? notify1dBefore,
    DateTime? scheduledTime,
    String? photoBefore,
    String? photoAfter,
    String? audioPath,
    List<SubTask>? hiddenSubtasks,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      effort: effort ?? this.effort,
      frequency: frequency ?? this.frequency,
      whoRemembers: whoRemembers ?? this.whoRemembers,
      whoDecides: whoDecides ?? this.whoDecides,
      whoExecutes: whoExecutes ?? this.whoExecutes,
      createdAt: createdAt,
      createdBy: createdBy,
      familyId: familyId,
      days: days ?? this.days,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      notifyAtTime: notifyAtTime ?? this.notifyAtTime,
      notify1hBefore: notify1hBefore ?? this.notify1hBefore,
      notify1dBefore: notify1dBefore ?? this.notify1dBefore,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      photoBefore: photoBefore ?? this.photoBefore,
      photoAfter: photoAfter ?? this.photoAfter,
      audioPath: audioPath ?? this.audioPath,
      hiddenSubtasks: hiddenSubtasks ?? this.hiddenSubtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'effort': effort,
      'frequency': frequency,
      'whoRemembers': whoRemembers,
      'whoDecides': whoDecides,
      'whoExecutes': whoExecutes,
      'createdBy': createdBy,
      'familyId': familyId,
      'createdAt': Timestamp.fromDate(createdAt),
      'days': days,
      'lastCompletedDate':
          lastCompletedDate != null ? Timestamp.fromDate(lastCompletedDate!) : null,
      'notifyAtTime': notifyAtTime,
      'notify1hBefore': notify1hBefore,
      'notify1dBefore': notify1dBefore,
      'scheduledTime': scheduledTime != null ? Timestamp.fromDate(scheduledTime!) : null,
      'photoBefore': photoBefore,
      'photoAfter': photoAfter,
      'audioPath': audioPath,
      'hiddenSubtasks': hiddenSubtasks.map((s) => s.toMap()).toList(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime? toDateTime(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final rawSubs = map['hiddenSubtasks'];
    final subs = <SubTask>[];
    if (rawSubs is List) {
      for (final raw in rawSubs) {
        if (raw is Map) {
          subs.add(SubTask.fromMap(Map<String, dynamic>.from(raw)));
        }
      }
    }

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      effort: map['effort'] ?? 1,
      frequency: map['frequency'] ?? TaskFrequency.semanal,
      whoRemembers: map['whoRemembers'] ?? '',
      whoDecides: map['whoDecides'] ?? '',
      whoExecutes: map['whoExecutes'] ?? '',
      createdBy: map['createdBy'] ?? '',
      familyId: map['familyId'] ?? '',
      createdAt: toDateTime(map['createdAt']) ?? DateTime.now(),
      days: List<String>.from(map['days'] ?? []),
      lastCompletedDate: toDateTime(map['lastCompletedDate']),
      notifyAtTime: map['notifyAtTime'] ?? false,
      notify1hBefore: map['notify1hBefore'] ?? false,
      notify1dBefore: map['notify1dBefore'] ?? false,
      scheduledTime: toDateTime(map['scheduledTime']),
      photoBefore: map['photoBefore'],
      photoAfter: map['photoAfter'],
      audioPath: map['audioPath'],
      hiddenSubtasks: subs,
    );
  }
}
