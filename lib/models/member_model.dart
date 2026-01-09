class Member {
  final String id;
  final String name;
  final String color;

  Member({
    required this.id,
    required this.name,
    required this.color,
  });

  // Converte para Mapa (Salvar no banco/local)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  // Cria a partir de Mapa (Ler do banco/local)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      color: map['color'] ?? '0xFF4D5BCE',
    );
  }
}