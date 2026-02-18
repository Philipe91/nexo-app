class Meal {
  final String id;
  final DateTime date;
  final String type; // Almoço, Jantar, Lanche
  final String description;
  final String chefId; // Quem vai cozinhar (ID do membro)
  final List<String> ingredients;

  Meal({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    required this.chefId,
    this.ingredients = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'chefId': chefId,
      'ingredients': ingredients,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      type: map['type'] ?? 'Jantar',
      description: map['description'] ?? '',
      chefId: map['chefId'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
    );
  }
}
