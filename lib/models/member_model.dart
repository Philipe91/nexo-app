class Member {
  final String id;
  final String name;
  final String color;
  final int xp;
  final int level;
  final List<String> badges;

  Member({
    required this.id,
    required this.name,
    required this.color,
    this.xp = 0,
    this.level = 1,
    this.badges = const [],
  });

  // Converte para Mapa (Salvar no banco/local)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'xp': xp,
      'level': level,
      'badges': badges,
    };
  }

  // Cria a partir de Mapa (Ler do banco/local)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      color: map['color'] ?? '0xFF4D5BCE',
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      badges: List<String>.from(map['badges'] ?? []),
    );
  }
}