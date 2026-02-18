class Reward {
  final String id;
  final String name;
  final int cost;
  final String icon; // Emoji ou caminho de asset
  final int stock; // -1 se infinito
  final bool isApproved; // Novo: Para sugestões das crianças

  Reward({
    required this.id,
    required this.name,
    required this.cost,
    required this.icon,
    this.stock = -1,
    this.isApproved = true, // Padrão true (criado pelos pais)
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'icon': icon,
      'stock': stock,
      'isApproved': isApproved,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cost: map['cost'] ?? 0,
      icon: map['icon'] ?? '🎁',
      stock: map['stock'] ?? -1,
      isApproved: map['isApproved'] ?? true,
    );
  }
}
