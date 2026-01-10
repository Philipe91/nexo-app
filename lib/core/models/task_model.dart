class Task {
  final String id;
  final String title;
  final String whoRemembers;
  final String whoDecides;
  final String whoExecutes;
  final int effort;
  final String frequency;
  final List<String> days; // <--- NOVO CAMPO
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.whoRemembers,
    required this.whoDecides,
    required this.whoExecutes,
    required this.effort,
    required this.frequency,
    required this.days, // <--- NOVO
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'whoRemembers': whoRemembers,
      'whoDecides': whoDecides,
      'whoExecutes': whoExecutes,
      'effort': effort,
      'frequency': frequency,
      'days': days, // <--- NOVO
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      whoRemembers: map['whoRemembers'] ?? '',
      whoDecides: map['whoDecides'] ?? '',
      whoExecutes: map['whoExecutes'] ?? '',
      effort: map['effort'] ?? 1,
      frequency: map['frequency'] ?? 'Semanal',
      // Garante que leia como lista de strings, mesmo se vier null
      days: List<String>.from(map['days'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
