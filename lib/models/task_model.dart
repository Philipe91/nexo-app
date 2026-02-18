import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final int effort; // 1 a 3
  final String frequency; // "Diário", "Semanal"
  final String whoRemembers;
  final String whoDecides;
  final String whoExecutes;

  // --- Campos Essenciais ---
  final List<String> days; // Ex: ['SEG', 'QUA']
  final DateTime? lastCompletedDate; // Para saber se já fez hoje
  final DateTime createdAt; // <--- O CAMPO QUE O ERRO ESTÁ PEDINDO

  // --- Campos de Notificação ---
  final bool notifyAtTime;    
  final bool notify1hBefore; 
  final bool notify1dBefore;  
  final DateTime? scheduledTime; 

  // --- Campos de Prova (Fotos) ---
  final String? photoBefore;
  final String? photoAfter; 
  
  // --- Áudio ---
  final String? audioPath;

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
        lastCompletedDate!.month == now.month &&
        lastCompletedDate!.day == now.day;
  }

  Task({
    required this.id,
    required this.title,
    required this.effort,
    required this.frequency,
    required this.whoRemembers,
    required this.whoDecides,
    required this.whoExecutes,
    required this.createdAt, 
    this.days = const [], 
    this.lastCompletedDate,
    this.notifyAtTime = false,
    this.notify1hBefore = false,
    this.notify1dBefore = false,
    this.scheduledTime,
    this.photoBefore,
    this.photoAfter,
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'effort': effort,
      'frequency': frequency,
      'whoRemembers': whoRemembers,
      'whoDecides': whoDecides,
      'whoExecutes': whoExecutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'days': days,
      'lastCompletedDate': lastCompletedDate != null ? Timestamp.fromDate(lastCompletedDate!) : null,
      'notifyAtTime': notifyAtTime,
      'notify1hBefore': notify1hBefore,
      'notify1dBefore': notify1dBefore,
      'scheduledTime': scheduledTime != null ? Timestamp.fromDate(scheduledTime!) : null,
      'photoBefore': photoBefore,
      'photoAfter': photoAfter,
      'audioPath': audioPath,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime? toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      effort: map['effort'] ?? 1,
      frequency: map['frequency'] ?? 'Semanal',
      whoRemembers: map['whoRemembers'] ?? '',
      whoDecides: map['whoDecides'] ?? '',
      whoExecutes: map['whoExecutes'] ?? '',
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
    );
  }
}