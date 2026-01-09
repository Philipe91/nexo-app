class Agreement {
  final String id;
  final String title;
  final String description; // Opcional, para detalhes
  final DateTime createdAt;

  Agreement({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  // Salvar (JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Carregar (JSON)
  factory Agreement.fromMap(Map<String, dynamic> map) {
    return Agreement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}