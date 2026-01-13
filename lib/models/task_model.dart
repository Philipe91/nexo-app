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

  Task({
    required this.id,
    required this.title,
    required this.effort,
    required this.frequency,
    required this.whoRemembers,
    required this.whoDecides,
    required this.whoExecutes,
    required this.createdAt, // <--- ELE ESTÁ AQUI!
    this.days = const [], 
    this.lastCompletedDate,
    this.notifyAtTime = false,
    this.notify1hBefore = false,
    this.notify1dBefore = false,
    this.scheduledTime,
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
      'createdAt': createdAt.toIso8601String(),
      'days': days,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'notifyAtTime': notifyAtTime,
      'notify1hBefore': notify1hBefore,
      'notify1dBefore': notify1dBefore,
      'scheduledTime': scheduledTime?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      effort: map['effort'] ?? 1,
      frequency: map['frequency'] ?? 'Semanal',
      whoRemembers: map['whoRemembers'] ?? '',
      whoDecides: map['whoDecides'] ?? '',
      whoExecutes: map['whoExecutes'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      days: List<String>.from(map['days'] ?? []), 
      lastCompletedDate: map['lastCompletedDate'] != null 
          ? DateTime.tryParse(map['lastCompletedDate']) 
          : null,
      notifyAtTime: map['notifyAtTime'] ?? false,
      notify1hBefore: map['notify1hBefore'] ?? false,
      notify1dBefore: map['notify1dBefore'] ?? false,
      scheduledTime: map['scheduledTime'] != null 
          ? DateTime.tryParse(map['scheduledTime']) 
          : null,
    );
  }
}