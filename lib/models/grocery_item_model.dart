class GroceryItem {
  final String id;
  final String name;
  final String category; // Ex: Hortifruti, Laticínios, Limpeza
  final bool isCompleted;
  final int quantity;
  final String addedBy; // ID do membro

  GroceryItem({
    required this.id,
    required this.name,
    this.category = 'Geral',
    this.isCompleted = false,
    this.quantity = 1,
    required this.addedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isCompleted': isCompleted,
      'quantity': quantity,
      'addedBy': addedBy,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Geral',
      isCompleted: map['isCompleted'] ?? false,
      quantity: map['quantity'] ?? 1,
      addedBy: map['addedBy'] ?? '',
    );
  }
  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    bool? isCompleted,
    int? quantity,
    String? addedBy,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      quantity: quantity ?? this.quantity,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
