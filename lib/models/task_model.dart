class Task {
  final String id;
  final String title;
  final String whoRemembers;
  final String whoDecides;
  final String whoExecutes;
  final int effort;
  final String frequency;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.whoRemembers,
    required this.whoDecides,
    required this.whoExecutes,
    required this.effort,
    required this.frequency,
    required this.createdAt,
  });

  // Converte para Mapa (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'whoRemembers': whoRemembers,
      'whoDecides': whoDecides,
      'whoExecutes': whoExecutes,
      'effort': effort,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Cria a partir do Mapa (JSON)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      whoRemembers: map['whoRemembers'] ?? '',
      whoDecides: map['whoDecides'] ?? '',
      whoExecutes: map['whoExecutes'] ?? '',
      effort: map['effort'] ?? 1,
      frequency: map['frequency'] ?? 'Semanal',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}